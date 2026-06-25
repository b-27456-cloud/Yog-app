import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/models/settings_model.dart';
import '../auth/auth_provider.dart';
import 'settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _pushNotifications = true;
  bool _soundEffects = true;
  bool _hapticFeedback = false;
  bool _mirrorMode = false;

  Future<void> _updateSettingOptimistically({
    bool? pushNotifications,
    bool? hapticFeedback,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) return;

    // Apply optimistic update
    setState(() {
      if (pushNotifications != null) _pushNotifications = pushNotifications;
      if (hapticFeedback != null) _hapticFeedback = hapticFeedback;
    });

    final newSettings = SettingsModel(
      accessibility: AccessibilitySettings(
        hapticFeedback: _hapticFeedback,
      ),
      settings: AppSettings(
        notifications: _pushNotifications,
      ),
    );

    try {
      await _settingsService.updateSettings(userId, newSettings);
    } catch (e) {
      if (mounted) {
        // Revert update on failure
        setState(() {
          if (pushNotifications != null) _pushNotifications = !pushNotifications;
          if (hapticFeedback != null) _hapticFeedback = !hapticFeedback;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.kNavy, size: 20),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.kNavy,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── SECTION: Account ───
            _buildSectionHeader("Account"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    // Profile tile
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final user = authProvider.user;
                        final name = user != null 
                            ? '${user.firstName} ${user.lastName}'.trim() 
                            : 'Guest User';
                        final email = user?.email ?? '';
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.kPrimary,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            name.isNotEmpty ? name : "Guest User",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kNavy,
                            ),
                          ),
                          subtitle: Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.kNavy.withOpacity(0.65),
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right, color: AppColors.kNavy.withOpacity(0.65)),
                          onTap: () {},
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildNavTile(Icons.lock_outline, "Change Password", null, () {}),
                    _buildDivider(),
                    _buildNavTile(Icons.language, "Language", "English", () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── SECTION: Preferences ───
            _buildSectionHeader("Preferences"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      Icons.notifications_outlined,
                      "Push Notifications",
                      _pushNotifications,
                      (v) => _updateSettingOptimistically(pushNotifications: v),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      Icons.volume_up_outlined,
                      "Sound Effects",
                      _soundEffects,
                      (v) => setState(() => _soundEffects = v),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      Icons.vibration,
                      "Haptic Feedback",
                      _hapticFeedback,
                      (v) => _updateSettingOptimistically(hapticFeedback: v),
                    ),
                    _buildDivider(),
                    // Dark mode — disabled (always on)
                    ListTile(
                      leading: _buildLeadingIcon(Icons.dark_mode_outlined),
                      title: Text(
                        "Dark Mode",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kNavy,
                        ),
                      ),
                      trailing: Switch(
                        value: true,
                        onChanged: null,
                        activeColor: AppColors.kPrimary,
                        activeTrackColor: AppColors.kPrimary.withOpacity(0.4),
                        inactiveThumbColor: AppColors.kNavy.withOpacity(0.3),
                        inactiveTrackColor: AppColors.kNavy.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── SECTION: Detection ───
            _buildSectionHeader("Detection"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    _buildNavTile(Icons.camera_alt_outlined, "Camera Quality", "HD 1080p", () {}),
                    _buildDivider(),
                    _buildSwitchTile(
                      Icons.flip,
                      "Mirror Mode",
                      _mirrorMode,
                      (v) => setState(() => _mirrorMode = v),
                    ),
                    _buildDivider(),
                    _buildNavTile(Icons.speed_outlined, "Detection Speed", "Balanced", () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── SECTION: About ───
            _buildSectionHeader("About"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    ListTile(
                      leading: _buildLeadingIcon(Icons.info_outline),
                      title: Text(
                        "Version",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kNavy,
                        ),
                      ),
                      trailing: Text(
                        "1.0.0",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.kNavy.withOpacity(0.65),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildNavTile(Icons.privacy_tip_outlined, "Privacy Policy", null, () {}),
                    _buildDivider(),
                    _buildNavTile(Icons.description_outlined, "Terms of Service", null, () {}),
                    _buildDivider(),
                    // Rate App with kSkyBlue icon
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.kPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_outline, color: AppColors.kSkyBlue, size: 20),
                      ),
                      title: Text(
                        "Rate App",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kNavy,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: AppColors.kNavy.withOpacity(0.50), size: 20),
                      onTap: () {},
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      ),
                      title: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                      onTap: () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.kNavy.withOpacity(0.65),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.kPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.kSkyBlue, size: 20),
    );
  }

  Widget _buildNavTile(IconData icon, String title, String? trailing, VoidCallback onTap) {
    return ListTile(
      leading: _buildLeadingIcon(icon),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.kNavy,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(fontSize: 13, color: AppColors.kNavy.withOpacity(0.65)),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.kNavy.withOpacity(0.50), size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: _buildLeadingIcon(icon),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.kNavy,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.kPrimary,
        activeTrackColor: AppColors.kPrimary.withOpacity(0.4),
        inactiveThumbColor: AppColors.kNavy.withOpacity(0.3),
        inactiveTrackColor: AppColors.kNavy.withOpacity(0.1),
      ),
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
