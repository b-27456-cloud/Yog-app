import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/pose_model.dart';
import '../../core/widgets/glass_card.dart';
import '../explore/pose_service.dart';

class PoseDetailScreen extends StatefulWidget {
  final String poseId;

  const PoseDetailScreen({Key? key, required this.poseId}) : super(key: key);

  @override
  State<PoseDetailScreen> createState() => _PoseDetailScreenState();
}

class _PoseDetailScreenState extends State<PoseDetailScreen> {
  final PoseService _poseService = PoseService();
  PoseModel? _pose;
  bool _isLoading = true;
  String? _error;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoInitialized = false;
  bool _videoError = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPoseDetails();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.pixels >= 280 - kToolbarHeight) {
          _videoController?.pause();
        }
      }
    });
  }

  Future<void> _fetchPoseDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _poseService.getPoseDetails(widget.poseId);
      final rawData = response['pose'] ?? response['data'];
      if (rawData != null) {
        setState(() {
          _pose = PoseModel.fromJson(rawData as Map<String, dynamic>);
          _isLoading = false;
        });
        if (_pose!.videoUrl != null && _pose!.videoUrl!.isNotEmpty) {
          _initVideo(_pose!.videoUrl!);
        }
      } else {
        setState(() {
          _error = 'Pose not found.\nKeys in response: ${response.keys.join(', ')}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _initVideo(String url) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: Container(color: AppColors.kPrimary.withOpacity(0.05)),
        errorBuilder: (context, errorMessage) => Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
      if (mounted) setState(() => _videoInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _pose == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.kNavy),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Pose Details',
            style: GoogleFonts.poppins(color: AppColors.kNavy, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Could not load pose',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'Unknown error occurred.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.kNavy.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kPrimary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: _fetchPoseDetails,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pose = _pose!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── SLIVER APP BAR ───
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: GlassCard(
                  borderRadius: 18,
                  padding: EdgeInsets.zero,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: Icon(Icons.arrow_back_ios_new, color: AppColors.kNavy, size: 18),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
                child: GlassCard(
                  borderRadius: 18,
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.bookmark_border, color: AppColors.kNavy, size: 18),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pose.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kNavy,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: ClipRect(
                key: const ValueKey('video_background'),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppColors.kPrimary.withOpacity(0.05)),
                    if (_videoInitialized && _chewieController != null)
                      Chewie(controller: _chewieController!)
                    else if (_videoError)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_off, size: 40, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              'Video unavailable',
                              style: GoogleFonts.poppins(
                                color: AppColors.kNavy.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.kPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              pose.videoUrl != null ? 'Loading video...' : 'No video available',
                              style: GoogleFonts.poppins(
                                color: AppColors.kNavy.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ─── BODY CONTENT ───
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Info chips row ──
                Row(
                  children: [
                    Expanded(child: _buildInfoChip(Icons.signal_cellular_alt, pose.difficulty, "Level")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInfoChip(Icons.timer_outlined, '${pose.durationMinutes} min', "Duration")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInfoChip(Icons.local_fire_department, '${pose.calories} cal', "Burn")),
                  ],
                ),
                const SizedBox(height: 20),

                // ── About ──
                Text(
                  "About",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kNavy,
                  ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    pose.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.kNavy.withOpacity(0.65),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Benefits ──
                if (pose.benefits.isNotEmpty) ...[
                  Text(
                    "Benefits",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: pose.benefits.map((benefit) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.kSkyBlue,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.kNavy.withOpacity(0.65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Steps ──
                if (pose.steps.isNotEmpty) ...[
                  Text(
                    "How to Do It",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...pose.steps.asMap().entries.map((entry) {
                    final stepNum = entry.key + 1;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassCard(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.kPrimary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  "$stepNum",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.kNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step['desc']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.kNavy.withOpacity(0.65),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // ── CTA Button ──
                GestureDetector(
                  onTap: () {
                    context.push('/camera', extra: {'poseId': widget.poseId});
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.kPrimary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kPrimary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Begin Practice",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.kSkyBlue, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.kNavy,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.kNavy.withOpacity(0.65),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
