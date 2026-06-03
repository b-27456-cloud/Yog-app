import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // For weekly chart mock data
    final heights = [40.0, 65.0, 50.0, 80.0, 45.0, 90.0, 35.0];
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final todayIndex = 5; // "Sat" as today for mock purposes

    // For accuracy breakdown mock data
    final accuracyData = [
      {"name": "Warrior II", "value": 0.92, "text": "92%"},
      {"name": "Tree Pose", "value": 0.87, "text": "87%"},
      {"name": "Downward Dog", "value": 0.78, "text": "78%"},
      {"name": "Mountain", "value": 0.95, "text": "95%"},
    ];

    // For achievements mock data
    final achievements = [
      {"icon": Icons.local_fire_department, "title": "7-Day\nStreak"},
      {"icon": Icons.star, "title": "100\nSessions"},
      {"icon": Icons.emoji_events, "title": "Master\nPose"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── HEADER ───
              const SizedBox(height: 16),
              Text(
                "Progress",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kNavy,
                ),
              ),
              Text(
                "Last 30 days",
                style: TextStyle(
                  color: AppColors.kNavy.withOpacity(0.65),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // ─── STATS ROW ───
              Row(
                children: [
                  Expanded(child: _buildStatCard("142", "Sessions")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard("89%", "Accuracy")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard("28h", "Practice")),
                ],
              ),
              const SizedBox(height: 24),

              // ─── WEEKLY CHART CARD ───
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Weekly Activity",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kNavy,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.chevron_left, color: AppColors.kNavy.withOpacity(0.65), size: 20),
                            Text(
                              "This Week",
                              style: TextStyle(
                                color: AppColors.kNavy.withOpacity(0.65),
                                fontSize: 12,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.kNavy.withOpacity(0.65), size: 20),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (i) {
                          final isToday = i == todayIndex;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 28,
                                height: heights[i],
                                decoration: BoxDecoration(
                                  color: isToday ? AppColors.kPrimary : AppColors.kPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: isToday
                                      ? [
                                          BoxShadow(
                                            color: AppColors.kSkyBlue.withOpacity(0.4),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                days[i],
                                style: TextStyle(
                                  color: AppColors.kNavy.withOpacity(0.65),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── ACCURACY BREAKDOWN ───
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pose Accuracy",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...accuracyData.map((data) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data["name"] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.kNavy,
                                  ),
                                ),
                                Text(
                                  data["text"] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.kSkyBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: data["value"] as double,
                                minHeight: 6,
                                backgroundColor: AppColors.kPrimary.withOpacity(0.15),
                                color: AppColors.kPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── ACHIEVEMENTS ───
              Text(
                "Achievements",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kNavy,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: achievements.map((achieve) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                achieve["icon"] as IconData,
                                color: AppColors.kSkyBlue,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                achieve["title"] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kNavy,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.kSkyBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.kNavy.withOpacity(0.65),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
