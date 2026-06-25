import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class SessionScreen extends StatefulWidget {
  final String poseId;
  const SessionScreen({Key? key, required this.poseId}) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 240, end: 260).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── LAYER 1: Background ───
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),

          // ─── LAYER 2: POSE VISUALIZATION ───
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final size = _pulseAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Pulsing ring
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size / 2),
                        border: Border.all(
                          color: AppColors.kPrimary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Main glass circle with icon
                    GlassCard(
                      borderRadius: 110,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: Icon(
                            Icons.accessibility_new,
                            size: 140,
                            color: AppColors.kNavy.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    // Pose label — positioned bottom
                    Positioned(
                      bottom: -18,
                      child: GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          "Warrior II",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.kNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ─── LAYER 3: TOP HUD ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.close,
                            color: AppColors.kNavy, size: 22),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Session",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.kNavy,
                            ),
                          ),
                          Text(
                            "Pose 3 of 8",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.kNavy.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "08:24",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kSkyBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── LAYER 4: PROGRESS BAR ───
          Positioned(
            top: 110,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.kPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 3 / 8,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── LAYER 5: BOTTOM PANEL ───
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
                  padding: const EdgeInsets.only(
                      top: 20, left: 24, right: 24, bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: const Border(
                      top: BorderSide(
                          color: AppColors.kCardBorder, width: 1.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Accuracy row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Accuracy",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.kNavy.withOpacity(0.65),
                            ),
                          ),
                          Text(
                            "94%",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kSkyBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tip card
                      GlassCard(
                        borderRadius: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppColors.kTeal, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Good posture! Extend arms more",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.kNavy.withOpacity(0.65),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Previous
                          GlassCard(
                            borderRadius: 27,
                            padding: EdgeInsets.zero,
                            child: const SizedBox(
                              width: 54,
                              height: 54,
                              child: Center(
                                child: Icon(Icons.skip_previous_rounded,
                                    color: AppColors.kNavy, size: 24),
                              ),
                            ),
                          ),

                          // Play/Pause
                          GestureDetector(
                            onTap: () {
                              setState(() => _isPlaying = !_isPlaying);
                            },
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.kPrimary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.kSkyBlue.withOpacity(0.4),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),

                          // Next
                          GlassCard(
                            borderRadius: 27,
                            padding: EdgeInsets.zero,
                            child: const SizedBox(
                              width: 54,
                              height: 54,
                              child: Center(
                                child: Icon(Icons.skip_next_rounded,
                                    color: AppColors.kNavy, size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Hold for 3s to capture pose",
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
}
