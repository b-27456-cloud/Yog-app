import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/network/analytics_service.dart';
import '../../core/models/analytics_models.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  UserStats? _userStats;
  UserStreak? _userStreak;
  List<String> _insights = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not logged in.";
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _analyticsService.fetchUserStats(userId),
        _analyticsService.fetchUserStreak(userId),
        _analyticsService.fetchUserInsights(userId),
      ]);
      if (mounted) {
        setState(() {
          _userStats = results[0] as UserStats;
          _userStreak = results[1] as UserStreak;
          _insights = results[2] as List<String>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final fullName = user != null ? '${user.firstName} ${user.lastName}'.trim() : 'Guest User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.kPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    bottom: -48,
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.kLightBlue,
                          child: Icon(Icons.person, color: AppColors.kNavy, size: 52),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // ─── NAME & BIO ───
              Center(
                child: Text(
                  fullName.isNotEmpty ? fullName : 'Guest User',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kNavy,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  email.isNotEmpty ? email : 'Yoga Enthusiast',
                  style: TextStyle(
                    color: AppColors.kNavy.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── ERROR BANNER ───
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ─── STATS ROW ───
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              _userStats != null ? '${_userStats!.totalSessions}' : '--',
                              'Sessions',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              _userStats != null ? '${_userStats!.totalMinutes}m' : '--',
                              'Practiced',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              _userStreak != null ? '${_userStreak!.currentStreak}' : '--',
                              'Streak',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ─── STREAK DETAILS CARD ───
                    if (!_isLoading && _userStreak != null) ...[
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
                                      'Best Streak: ${_userStreak!.longestStreak} days',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.kNavy,
                                      ),
                                    ),
                                    Text(
                                      '${_userStreak!.totalDaysPracticed} total days practiced',
                                      style: TextStyle(
                                        color: AppColors.kNavy.withOpacity(0.65),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.ac_unit, color: AppColors.kSkyBlue, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_userStreak!.availableFreezes} freeze${_userStreak!.availableFreezes == 1 ? '' : 's'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.kSkyBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _userStreak!.longestStreak > 0
                                    ? (_userStreak!.currentStreak / _userStreak!.longestStreak).clamp(0.0, 1.0)
                                    : 0.0,
                                minHeight: 8,
                                backgroundColor: AppColors.kPrimary.withOpacity(0.15),
                                color: AppColors.kSkyBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _userStreak!.currentStreak >= _userStreak!.longestStreak && _userStreak!.currentStreak > 0
                                  ? '🏆 Personal best!'
                                  : '${_userStreak!.currentStreak} / ${_userStreak!.longestStreak} days to personal best',
                              style: TextStyle(
                                color: AppColors.kNavy.withOpacity(0.65),
                                fontSize: 12,
                              ),
                            ),
                            if (_userStats?.favoritePose != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: AppColors.kSkyBlue, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Favourite Pose: ${_userStats!.favoritePose!.poseName} (×${_userStats!.favoritePose!.count})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.kNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ─── YOUR INSIGHTS ───
                    if (!_isLoading && _insights.isNotEmpty) ...[
                      Text(
                        "Your Insights",
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._insights.map((insight) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: GlassCard(
                            borderRadius: 14,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, color: AppColors.kSkyBlue, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    insight,
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
                      }).toList(),
                      const SizedBox(height: 14),
                    ],



                    // ─── MENU ───
                    GlassCard(
                      borderRadius: 18,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: [
                            _buildMenuItem(Icons.emoji_events_outlined, 'Achievements', () {
                              context.push('/achievements');
                            }),
                            _buildDivider(),
                            _buildMenuItem(Icons.notifications_outlined, 'Notifications', () {
                              context.push('/notifications');
                            }),
                            _buildDivider(),
                            _buildMenuItem(Icons.settings_outlined, 'Settings', () {
                              context.push('/settings');
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
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                        onTap: () async {
                          final router = GoRouter.of(context);
                          await Provider.of<AuthProvider>(context, listen: false).logout();
                          if (mounted) router.go('/login');
                        },
                      ),
                    ),
                  ],
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
              fontSize: 22,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff < 7) return "${diff}d ago";
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}";
  }
}
