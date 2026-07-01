import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/models/settings_model.dart';
import '../../core/models/analytics_models.dart';
import '../../core/network/analytics_service.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../auth/auth_provider.dart';
import 'settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Preferences state
  bool _pushNotifications = true;
  bool _hapticFeedback = false;
  String? _localProfile;

  // Analytics state
  List<String> _insights = [];
  bool _isLoadingInsights = true;

  // ignore: unused_field
  List<SessionRecord> _sessions = [];
  // ignore: unused_field
  SessionMeta? _sessionMeta;
  // ignore: unused_field
  bool _isLoadingSessions = true;
  // ignore: unused_field
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) {
      setState(() {
        _isLoadingInsights = false;
      });
      return;
    }

    // Fetch insights
    _analyticsService.fetchUserInsights(userId).then((insights) {
      if (mounted) setState(() { _insights = insights; _isLoadingInsights = false; });
    }).catchError((_) {
      if (mounted) setState(() => _isLoadingInsights = false);
    });
  }

  Future<void> _updateSettingOptimistically({
    bool? pushNotifications,
    bool? hapticFeedback,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) return;

    setState(() {
      if (pushNotifications != null) _pushNotifications = pushNotifications;
      if (hapticFeedback != null) _hapticFeedback = hapticFeedback;
    });

    final newSettings = SettingsModel(
      accessibility: AccessibilitySettings(hapticFeedback: _hapticFeedback),
      settings: AppSettings(notifications: _pushNotifications),
    );

    try {
      await _settingsService.updateSettings(userId, newSettings);
    } catch (e) {
      if (mounted) {
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

  Future<void> _updateProfile(String? value) async {
    if (value == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) return;

    final oldProfile = _localProfile ?? authProvider.user?.accessibilityProfile ?? 'standard';
    setState(() {
      _localProfile = value;
    });

    final newSettings = SettingsModel(
      accessibility: AccessibilitySettings(profile: value),
    );

    try {
      await _settingsService.updateSettings(userId, newSettings);
    } catch (e) {
      if (mounted) {
        setState(() {
          _localProfile = oldProfile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            // ─── SECTION: AI Insights ───
            _buildSectionHeader("AI Insights ✨", subtitle: "Personalized tips from your sessions"),
            _buildInsightsSection(),
            const SizedBox(height: 24),

            // // ─── SECTION: Session History ───
            // _buildSectionHeader("Session History"),
            // _buildSessionHistorySection(),
            // const SizedBox(height: 20),

            // ─── SECTION: Account ───
            _buildSectionHeader("Account", subtitle: "Your profile and session"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
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
                        );
                      },
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
                        final router = GoRouter.of(context);
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (mounted) {
                          router.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── SECTION: Accessibility ───
            _buildSectionHeader("Accessibility", subtitle: "Physical capability profile"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final profile = _localProfile ?? authProvider.user?.accessibilityProfile ?? 'standard';
                    return Column(
                      children: [
                        _buildRadioTile("Standard", "standard", profile, (v) => _updateProfile(v)),
                        _buildDivider(),
                        _buildRadioTile("Elderly (65+)", "elderly", profile, (v) => _updateProfile(v)),
                        _buildDivider(),
                        _buildRadioTile("Injury-Prone", "injury_prone", profile, (v) => _updateProfile(v)),
                      ],
                    );
                  }
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── SECTION: Preferences ───
            _buildSectionHeader("Preferences", subtitle: "Customize your experience"),
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
                      subtitle: "Reminders and session alerts",
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      Icons.volume_up_outlined,
                      "Sound Effects",
                      settingsProvider.soundEffects,
                      (v) => settingsProvider.setSoundEffects(v),
                      subtitle: "Background music during sessions",
                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── SECTION: Detection ───
            _buildSectionHeader("Detection", subtitle: "Camera and pose detection settings"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    _buildNavTile(Icons.camera_alt_outlined, "Camera Quality", settingsProvider.cameraQuality, _showCameraQualityBottomSheet),

                    _buildDivider(),
                    _buildNavTile(Icons.speed_outlined, "Detection Speed", settingsProvider.detectionSpeed, _showDetectionSpeedBottomSheet),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── SECTION: About ───
            _buildSectionHeader("About", subtitle: "App info"),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
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
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── AI INSIGHTS SECTION ───
  Widget _buildInsightsSection() {
    if (_isLoadingInsights) {
      return GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(24),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_insights.isEmpty) {
      return GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.kSkyBlue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No insights yet. Complete a few sessions to get personalized tips!",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.kNavy.withOpacity(0.65),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final insightColors = [
      const Color(0xFFE8F5FF),
      const Color(0xFFF0FFF4),
      const Color(0xFFFFF8E8),
    ];
    final insightBorderColors = [
      AppColors.kSkyBlue.withOpacity(0.3),
      const Color(0xFF4CAF50).withOpacity(0.3),
      const Color(0xFFFF9800).withOpacity(0.3),
    ];

    return Column(
      children: List.generate(_insights.length, (i) {
        final color = insightColors[i % insightColors.length];
        final borderColor = insightBorderColors[i % insightBorderColors.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("💡", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _insights[i],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kNavy,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── SESSION HISTORY SECTION ───
  // ignore: unused_element
  Future<void> _loadMoreSessions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) return;
    final nextPage = _currentPage + 1;
    final total = _sessionMeta?.pages ?? 1;
    if (nextPage > total) return;

    try {
      final res = await _analyticsService.fetchUserSessions(userId, page: nextPage);
      if (mounted) {
        setState(() {
          _sessions.addAll(res.sessions);
          _sessionMeta = res.meta;
          _currentPage = nextPage;
        });
      }
    } catch (_) {}
  }

  // ignore: unused_element
  Widget _buildSessionHistorySection() {
    if (_isLoadingSessions) {
      return GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(24),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessions.isEmpty) {
      return GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.history, color: AppColors.kSkyBlue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No sessions yet. Start your first yoga session!",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.kNavy.withOpacity(0.65),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GlassCard(
          borderRadius: 18,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: List.generate(_sessions.length, (i) {
                final session = _sessions[i];
                return Column(
                  children: [
                    _buildSessionTile(session),
                    if (i < _sessions.length - 1) _buildDivider(),
                  ],
                );
              }),
            ),
          ),
        ),
        // Pagination
        if (_sessionMeta != null && _currentPage < _sessionMeta!.pages)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: GestureDetector(
              onTap: _loadMoreSessions,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.kPrimary.withOpacity(0.25)),
                ),
                child: Center(
                  child: Text(
                    "Load More Sessions",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_sessionMeta != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              "Showing ${_sessions.length} of ${_sessionMeta!.total} sessions",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.kNavy.withOpacity(0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionTile(SessionRecord session) {
    final durationMin = (session.durationSeconds / 60).round();
    final dateStr = session.startTime != null
        ? _formatDate(session.startTime!)
        : "Unknown date";
    final levelBadge = ['Beginner', 'Intermediate', 'Advanced'];
    final level = session.pose.level.clamp(1, 3) - 1;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.kPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.accessibility_new, color: AppColors.kSkyBlue, size: 22),
      ),
      title: Text(
        session.pose.name.isNotEmpty ? session.pose.name : "Yoga Session",
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.kNavy,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          "$dateStr  •  ${durationMin}m  •  ${session.accuracyAverage}% accuracy",
          style: TextStyle(
            fontSize: 12,
            color: AppColors.kNavy.withOpacity(0.6),
          ),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.kSkyBlue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          levelBadge[level],
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.kSkyBlue,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff < 7) return "${diff}d ago";
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}";
  }

  // ─── ACTION METHODS ───


  void _showCameraQualityBottomSheet() {
    final qualities = ['HD 720p', 'HD 1080p', '4K Ultra HD'];
    final icons = [Icons.sd, Icons.hd, Icons.four_k];
    final settingsProvider = context.read<SettingsProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Camera Quality',
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.kNavy),
            ),
            const SizedBox(height: 4),
            Text('Higher quality uses more battery and storage.',
              style: TextStyle(fontSize: 12, color: AppColors.kNavy.withOpacity(0.5)),
            ),
            const SizedBox(height: 12),
            ...List.generate(qualities.length, (i) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: settingsProvider.cameraQuality == qualities[i]
                      ? AppColors.kPrimary.withOpacity(0.15)
                      : AppColors.kNavy.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[i],
                  color: settingsProvider.cameraQuality == qualities[i] ? AppColors.kPrimary : AppColors.kNavy.withOpacity(0.4),
                  size: 20,
                ),
              ),
              title: Text(qualities[i], style: GoogleFonts.poppins(fontSize: 14, color: AppColors.kNavy)),
              trailing: settingsProvider.cameraQuality == qualities[i]
                  ? const Icon(Icons.check_circle, color: AppColors.kPrimary, size: 20)
                  : null,
              onTap: () {
                settingsProvider.setCameraQuality(qualities[i]);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDetectionSpeedBottomSheet() {
    final speeds = ['Fast', 'Balanced', 'Accurate'];
    final descriptions = ['Lower accuracy, uses less CPU', 'Best for most users', 'Highest accuracy, uses more CPU'];
    final icons = [Icons.bolt, Icons.balance, Icons.center_focus_strong];
    final settingsProvider = context.read<SettingsProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Detection Speed',
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.kNavy),
            ),
            const SizedBox(height: 4),
            Text('Choose your pose detection processing speed.',
              style: TextStyle(fontSize: 12, color: AppColors.kNavy.withOpacity(0.5)),
            ),
            const SizedBox(height: 12),
            ...List.generate(speeds.length, (i) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: settingsProvider.detectionSpeed == speeds[i]
                      ? AppColors.kPrimary.withOpacity(0.15)
                      : AppColors.kNavy.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[i],
                  color: settingsProvider.detectionSpeed == speeds[i] ? AppColors.kPrimary : AppColors.kNavy.withOpacity(0.4),
                  size: 20,
                ),
              ),
              title: Text(speeds[i], style: GoogleFonts.poppins(fontSize: 14, color: AppColors.kNavy, fontWeight: FontWeight.w500)),
              subtitle: Text(descriptions[i], style: TextStyle(fontSize: 11, color: AppColors.kNavy.withOpacity(0.5))),
              trailing: settingsProvider.detectionSpeed == speeds[i]
                  ? const Icon(Icons.check_circle, color: AppColors.kPrimary, size: 20)
                  : null,
              onTap: () {
                settingsProvider.setDetectionSpeed(speeds[i]);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── SHARED HELPERS ───
  Widget _buildSectionHeader(String label, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.kNavy.withOpacity(0.65),
            ),
          ),
          if (subtitle != null) ...
            [
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.kNavy.withOpacity(0.4),
                ),
              ),
            ],
        ],
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

  Widget _buildRadioTile(String title, String value, String groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.kNavy,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.kPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) {
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
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.kNavy.withOpacity(0.45)))
          : null,
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
