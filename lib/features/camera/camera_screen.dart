import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double _pulseOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_animatePulse);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── LAYER 1 — Camera viewfinder & Skeleton ───
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: _SkeletonPainter(),
            ),
          ),

          // ─── LAYER 2 — TOP BAR ───
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
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.kNavy, size: 20),
                      ),
                      Text(
                        "Pose Detection",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kNavy,
                        ),
                      ),
                      const Icon(Icons.more_vert, color: AppColors.kNavy, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── LAYER 3 — CONFIDENCE BADGE ───
          Positioned(
            top: 110,
            right: 20,
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Text(
                    "94%",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kSkyBlue,
                    ),
                  ),
                  Text(
                    "Accuracy",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.kNavy.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── LAYER 4 — POSE LABEL ───
          Positioned(
            bottom: 270, // Just above the bottom panel
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
                        color: AppColors.kTeal.withOpacity(_pulseOpacity),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Warrior II Detected",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── LAYER 5 — BOTTOM PANEL ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(color: AppColors.kCardBorder, width: 1.0),
                    ),
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
                              "Keep your back straight and extend arms wider",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.kNavy.withOpacity(0.65),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Metrics row
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard("Posture", "Good")),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMetricCard("Balance", "Fair")),
                          const SizedBox(width: 10),
                          Expanded(child: _buildMetricCard("Angle", "87°")),
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
                              child: Center(
                                child: Icon(Icons.flip_camera_ios, color: AppColors.kNavy, size: 22),
                              ),
                            ),
                          ),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.kPrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.kSkyBlue.withOpacity(0.4),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                            ),
                          ),
                          GlassCard(
                            borderRadius: 26,
                            padding: EdgeInsets.zero,
                            child: const SizedBox(
                              width: 52,
                              height: 52,
                              child: Center(
                                child: Icon(Icons.stop_circle_outlined, color: AppColors.kNavy, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Hold pose for 3 seconds to capture",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.kNavy.withOpacity(0.65),
                        ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.kNavy.withOpacity(0.65),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.kNavy,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skelPaint = Paint()
      ..color = AppColors.kPrimary.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = AppColors.kPrimary.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    void drawLine(Offset p1, Offset p2) {
      canvas.drawLine(p1, p2, skelPaint);
    }

    void drawJoint(Offset p) {
      canvas.drawCircle(p, 5, jointPaint);
    }

    final cx = size.width / 2;
    // Shift slightly up to center nicely on screen above the bottom panel
    final cy = size.height / 2 - 50; 

    // Joints
    final head = Offset(cx, cy - 120);
    final neck = Offset(cx, cy - 80);
    final lShoulder = Offset(cx - 40, cy - 80);
    final rShoulder = Offset(cx + 40, cy - 80);
    final lElbow = Offset(cx - 80, cy - 30);
    final rElbow = Offset(cx + 80, cy - 30);
    final lWrist = Offset(cx - 110, cy - 70); // warrior pose arms out
    final rWrist = Offset(cx + 110, cy - 70); 
    final spineBase = Offset(cx, cy + 60);
    final lHip = Offset(cx - 30, cy + 60);
    final rHip = Offset(cx + 30, cy + 60);
    final lKnee = Offset(cx - 60, cy + 140); // lunging
    final rKnee = Offset(cx + 60, cy + 160); // back leg straight
    final lAnkle = Offset(cx - 60, cy + 220);
    final rAnkle = Offset(cx + 100, cy + 220);

    // Head
    canvas.drawCircle(head, 20, skelPaint);
    
    // Torso / Arms
    drawLine(Offset(cx, cy - 100), neck); // neck to head
    drawLine(lShoulder, rShoulder);
    drawLine(neck, spineBase); // spine
    drawLine(lShoulder, lElbow);
    drawLine(lElbow, lWrist);
    drawLine(rShoulder, rElbow);
    drawLine(rElbow, rWrist);

    // Legs
    drawLine(lHip, rHip);
    drawLine(lHip, lKnee);
    drawLine(lKnee, lAnkle);
    drawLine(rHip, rKnee);
    drawLine(rKnee, rAnkle);

    // Draw all joints
    final joints = [
      neck, lShoulder, rShoulder, lElbow, rElbow, lWrist, rWrist,
      spineBase, lHip, rHip, lKnee, rKnee, lAnkle, rAnkle
    ];
    for (final j in joints) {
      drawJoint(j);
    }

    // Corner brackets (15% inset)
    final bracketPaint = Paint()
      ..color = AppColors.kPrimary.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double insetX = size.width * 0.15;
    final double insetY = size.height * 0.15;
    const double bLen = 28.0;

    // TL
    canvas.drawLine(Offset(insetX, insetY), Offset(insetX + bLen, insetY), bracketPaint);
    canvas.drawLine(Offset(insetX, insetY), Offset(insetX, insetY + bLen), bracketPaint);

    // TR
    final trX = size.width - insetX;
    canvas.drawLine(Offset(trX, insetY), Offset(trX - bLen, insetY), bracketPaint);
    canvas.drawLine(Offset(trX, insetY), Offset(trX, insetY + bLen), bracketPaint);

    // BL
    final blY = size.height - insetY;
    canvas.drawLine(Offset(insetX, blY), Offset(insetX + bLen, blY), bracketPaint);
    canvas.drawLine(Offset(insetX, blY), Offset(insetX, blY - bLen), bracketPaint);

    // BR
    canvas.drawLine(Offset(trX, blY), Offset(trX - bLen, blY), bracketPaint);
    canvas.drawLine(Offset(trX, blY), Offset(trX, blY - bLen), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
