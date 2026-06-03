import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/pose_model.dart';
import '../../core/widgets/glass_card.dart';

class PoseDetailScreen extends StatelessWidget {
  final PoseModel pose;

  const PoseDetailScreen({Key? key, required this.pose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ─── SLIVER APP BAR ───
          SliverAppBar(
            expandedHeight: 260,
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.white),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.kSkyBlue.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(75),
                          ),
                        ),
                        Icon(
                          pose.icon,
                          size: 120,
                          color: AppColors.kNavy.withOpacity(0.10),
                        ),
                      ],
                    ),
                  ),
                ],
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

                // ── Steps ──
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

                // ── CTA Button ──
                GestureDetector(
                  onTap: () => context.push('/session'),
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
