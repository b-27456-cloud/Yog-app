import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: Column(
          children: [
            // ─── TOP HEADER ───
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.kNavy,
                        AppColors.kPrimary.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -48, // Avatar is radius 48, so it overflows by 48
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.kLightBlue,
                        child: Icon(Icons.person, color: AppColors.kNavy, size: 52),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.kSteelBlue, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60), // Space for avatar

            Text(
              "Alex Johnson",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Yoga Enthusiast  •  2 Years",
              style: TextStyle(
                color: AppColors.kNavy.withOpacity(0.65),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // ─── STATS ROW ───
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("142", "Sessions")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard("34", "Poses")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard("7", "Streak")),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── LEVEL CARD ───
                  GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Intermediate Yogi",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.kNavy,
                                  ),
                                ),
                                Text(
                                  "1,240 / 2,000 XP to Level 8",
                                  style: TextStyle(
                                    color: AppColors.kNavy.withOpacity(0.65),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.kPrimary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "LVL 7",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: 0.62,
                            minHeight: 8,
                            backgroundColor: AppColors.kPrimary.withOpacity(0.15),
                            color: AppColors.kSkyBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "62% to next level",
                          style: TextStyle(
                            color: AppColors.kNavy.withOpacity(0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── MENU ───
                  GlassCard(
                    borderRadius: 18,
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.favorite_border, "Saved Poses", () {
                            // context.push('/saved');
                          }),
                          _buildDivider(),
                          _buildMenuItem(Icons.emoji_events_outlined, "Achievements", () {
                            // context.push('/achievements');
                          }),
                          _buildDivider(),
                          _buildMenuItem(Icons.notifications_outlined, "Notifications", () {
                            // context.push('/notifications');
                          }),
                          _buildDivider(),
                          _buildMenuItem(Icons.settings_outlined, "Settings", () {
                            context.push('/settings');
                          }),
                          _buildDivider(),
                          _buildMenuItem(Icons.help_outline, "Help & Support", () {
                            // context.push('/help');
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── LOGOUT ───
                  GlassCard(
                    borderRadius: 14,
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                      title: Text(
                        "Log Out",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                      onTap: () {
                        context.go('/login');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.kPrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.kSkyBlue, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.kNavy,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.kNavy.withOpacity(0.65), size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.kNavy.withOpacity(0.1),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
