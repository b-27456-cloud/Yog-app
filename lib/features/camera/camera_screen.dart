import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../session/session_service.dart';
import '../../core/network/api_client.dart';

class CameraScreen extends StatefulWidget {
  final String poseId;
  const CameraScreen({Key? key, required this.poseId}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final SessionService _sessionService = SessionService();
  String? _sessionId;
  
  CameraController? _cameraController;
  CameraDescription? _frontCamera;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  
  bool _isDetecting = false;
  DateTime _lastProcessTime = DateTime.now();
  Pose? _latestPose;
  Size _imageSize = Size.zero;

  // Audio Beep
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // State
  double _pulseOpacity = 1.0;
  int _accuracy = 0;
  String _feedback = 'Initializing session...';
  final String _poseName = 'Detecting...';
  bool _sessionStarted = false;
  bool _isBeeping = false;
  String? _sessionError;

  static const int _goodAccuracyThreshold = 60;

  @override
  void initState() {
    super.initState();
    Future.microtask(_animatePulse);
    _initSession();
    _initCamera();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      _cameraController = CameraController(
        _frontCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (mounted) setState(() => _sessionError = 'Failed to initialize camera: $e');
    }
  }

  Future<void> _initSession() async {
    try {
      final response = await _sessionService.startSession(poseId: widget.poseId, musicId: 'none');
      final sessionData = response['data']?['session'];
      if (sessionData != null && mounted) {
        setState(() {
          _sessionId = sessionData['session_id'];
          _sessionStarted = true;
          _feedback = 'Session started! Strike the pose.';
        });
        _startImageStream();
      }
    } on SessionExpiredException {
      if (mounted) setState(() => _sessionError = 'Session expired. Please log in again.');
    } on ApiException catch (e) {
      if (mounted) setState(() => _sessionError = e.message);
    } catch (e) {
      if (mounted) setState(() => _sessionError = 'Failed to start session. Please try again.');
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      
      final now = DateTime.now();
      if (now.difference(_lastProcessTime).inMilliseconds < 1000) return;
      
      _isDetecting = true;
      _lastProcessTime = now;
      
      try {
        final inputImage = _inputImageFromCameraImage(image, _frontCamera!);
        if (inputImage == null) {
          _isDetecting = false;
          return;
        }

        final rotation = inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;
        _imageSize = (rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg)
            ? Size(image.height.toDouble(), image.width.toDouble())
            : Size(image.width.toDouble(), image.height.toDouble());

        final poses = await _poseDetector.processImage(inputImage);
        
        if (poses.isNotEmpty) {
          final pose = poses.first;
          setState(() {
            _latestPose = pose;
          });
          
          if (_sessionId != null) {
             _sendLogFrame(pose, _imageSize);
          }
        } else {
          setState(() {
             _latestPose = null;
          });
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image, CameraDescription camera) {
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

    if (image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Force NV21 metadata for Android, regardless of the YUV420 camera output
    final InputImageFormat inputImageFormat = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: inputImageFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _sendLogFrame(Pose pose, Size imageSize) async {
    try {
      final w = imageSize.width > 0 ? imageSize.width : 480.0;
      final h = imageSize.height > 0 ? imageSize.height : 640.0;
      
      final landmarks = <Map<String, dynamic>>[];
      for (int i = 0; i < 33; i++) {
        final landmark = pose.landmarks[PoseLandmarkType.values[i]];
        if (landmark != null) {
          landmarks.add({
            'x': landmark.x / w,
            'y': landmark.y / h,
            'z': landmark.z / w,
            'visibility': landmark.likelihood,
          });
        } else {
           landmarks.add({'x': 0.0, 'y': 0.0, 'z': 0.0, 'visibility': 0.0});
        }
      }

      final response = await _sessionService.logFrame(
        sessionId: _sessionId!,
        landmarks: landmarks,
      );
      
      final data = response['data'];
      if (data != null && mounted) {
        setState(() {
          _accuracy = (data['accuracy'] as num?)?.toInt() ?? _accuracy;
          final feedbackList = data['feedback'] as List<dynamic>?;
          if (feedbackList != null && feedbackList.isNotEmpty) {
            _feedback = feedbackList.first.toString();
          }
        });
        _updateBeepState(_accuracy);
      }
    } catch (_) {}
  }

  void _updateBeepState(int accuracy) async {
    final poseIsWrong = accuracy < _goodAccuracyThreshold && _sessionStarted;
    if (poseIsWrong) {
      if (!_isBeeping) {
        setState(() => _isBeeping = true);
        await _audioPlayer.play(AssetSource('audio/beep.wav'));
      }
    } else {
      if (_isBeeping) {
        setState(() => _isBeeping = false);
      }
    }
  }

  Future<void> _endSession() async {
    _cameraController?.stopImageStream();
    if (_sessionId != null) {
      try {
        await _sessionService.endSession(sessionId: _sessionId!);
      } catch (_) {}
    }
    if (mounted) context.pop();
  }

  void _animatePulse() async {
    while (mounted) {
      setState(() => _pulseOpacity = 0.3);
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) break;
      setState(() => _pulseOpacity = 1.0);
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    _audioPlayer.dispose();
    if (_sessionId != null) {
      _sessionService.endSession(sessionId: _sessionId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _sessionError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 15, color: AppColors.kNavy),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.kPrimary),
                onPressed: () => context.pop(),
                child: const Text('Go Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.kPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1 — Camera viewfinder
          SizedBox.expand(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: CameraPreview(_cameraController!),
            ),
          ),
          
          // LAYER 2 — Skeleton CustomPaint
          if (_latestPose != null && _imageSize.width > 0 && _imageSize.height > 0)
            Positioned.fill(
              child: CustomPaint(
                painter: _SkeletonPainter(
                  pose: _latestPose!,
                  imageSize: _imageSize,
                ),
              ),
            ),

          // LAYER 3 — TOP BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _endSession,
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.kNavy, size: 20),
                      ),
                      Text(
                        'Pose Detection',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kNavy,
                        ),
                      ),
                      _sessionStarted
                          ? const Icon(Icons.more_vert, color: AppColors.kNavy, size: 20)
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.kSkyBlue),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BEEP ALERT BANNER (shown when pose is wrong)
          if (_isBeeping)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(_pulseOpacity * 0.7), width: 5),
                  ),
                ),
              ),
            ),

          // WRONG POSE TOOLTIP
          if (_isBeeping)
            Positioned(
              top: 100,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_pulseOpacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Adjust your pose!',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // CONFIDENCE BADGE
          Positioned(
            top: 110,
            right: 20,
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Text(
                    '$_accuracy%',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isBeeping
                          ? Colors.red
                          : _accuracy >= 80 ? AppColors.kTeal : _accuracy >= _goodAccuracyThreshold ? AppColors.kSkyBlue : Colors.orange,
                    ),
                  ),
                  Text('Accuracy', style: TextStyle(fontSize: 11, color: AppColors.kNavy.withOpacity(0.65))),
                ],
              ),
            ),
          ),

          // POSE LABEL
          Positioned(
            bottom: 270,
            left: 0,
            right: 0,
            child: Center(
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: (_isBeeping ? Colors.red : _sessionStarted ? AppColors.kTeal : Colors.orange).withOpacity(_pulseOpacity),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _sessionStarted ? _poseName : 'Starting session...',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.kNavy),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTTOM PANEL
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(top: BorderSide(color: AppColors.kCardBorder, width: 1.0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Feedback row
                      Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined, color: AppColors.kSkyBlue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _feedback,
                              style: TextStyle(fontSize: 13, color: AppColors.kNavy.withOpacity(0.65)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Metrics row
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Accuracy', '$_accuracy%')),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricCard(
                              'Status',
                              _accuracy >= 80 ? 'Great!' : _accuracy >= 50 ? 'Good' : 'Adjust',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMetricCard('Session', _sessionStarted ? 'Active' : 'Loading')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassCard(
                            borderRadius: 26,
                            padding: EdgeInsets.zero,
                            child: const SizedBox(
                              width: 52,
                              height: 52,
                              child: Center(child: Icon(Icons.flip_camera_ios, color: AppColors.kNavy, size: 22)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.kPrimary,
                                boxShadow: [BoxShadow(color: AppColors.kSkyBlue.withOpacity(0.4), blurRadius: 20)],
                              ),
                              child: const Center(child: Icon(Icons.camera_alt, color: Colors.white, size: 30)),
                            ),
                          ),
                          GlassCard(
                            borderRadius: 26,
                            padding: EdgeInsets.zero,
                            child: GestureDetector(
                              onTap: _endSession,
                              child: const SizedBox(
                                width: 52,
                                height: 52,
                                child: Center(child: Icon(Icons.stop_circle_outlined, color: Colors.red, size: 22)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _sessionStarted ? 'Hold pose for 3 seconds to capture' : 'Connecting to server...',
                        style: TextStyle(fontSize: 12, color: AppColors.kNavy.withOpacity(0.65)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.kNavy.withOpacity(0.65)), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.kNavy),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// CustomPainter for Stickman
class _SkeletonPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;

  _SkeletonPainter({
    required this.pose,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    final jointBorderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Offset translate(PoseLandmark landmark) {
      // Scale to view size, and horizontally flip because the underlying CameraPreview is flipped 
      // with Matrix4.rotationY(math.pi)
      final x = size.width - (landmark.x * size.width / imageSize.width);
      final y = landmark.y * size.height / imageSize.height;
      return Offset(x, y);
    }

    void drawBone(PoseLandmarkType type1, PoseLandmarkType type2) {
      final lm1 = pose.landmarks[type1];
      final lm2 = pose.landmarks[type2];
      if (lm1 != null && lm2 != null) {
        canvas.drawLine(translate(lm1), translate(lm2), bonePaint);
      }
    }

    void drawJoint(PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm != null) {
        final pt = translate(lm);
        canvas.drawCircle(pt, 4.0, jointPaint);
        canvas.drawCircle(pt, 4.0, jointBorderPaint);
      }
    }

    // Bones
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawBone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawBone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawBone(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawBone(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawBone(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    // Joints
    final bodyJoints = [
      PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow, PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
    ];
    for (var joint in bodyJoints) {
      drawJoint(joint);
    }

    // Head (Radius based on ear distance, centered on nose)
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
    final rightEar = pose.landmarks[PoseLandmarkType.rightEar];

    if (nose != null && leftEar != null && rightEar != null) {
      final ptLeftEar = translate(leftEar);
      final ptRightEar = translate(rightEar);
      final ptNose = translate(nose);

      final dx = ptLeftEar.dx - ptRightEar.dx;
      final dy = ptLeftEar.dy - ptRightEar.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      
      final radius = dist > 0 ? (dist / 2.0) * 1.6 : 20.0;

      final headPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 8.0
        ..style = PaintingStyle.stroke;
        
      canvas.drawCircle(ptNose, radius, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
