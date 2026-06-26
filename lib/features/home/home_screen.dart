import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/pose_model.dart';
import '../../core/data/poses_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pose_selection_sheet.dart';
import '../../core/network/analytics_service.dart';
import '../../core/models/analytics_models.dart';
import '../auth/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  UserStats? _userStats;
  UserStreak? _userStreak;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) {
      setState(() => _isLoadingStats = false);
      return;
    }

    try {
      final stats = await _analyticsService.fetchUserStats(userId);
      final streak = await _analyticsService.fetchUserStreak(userId);
      if (mounted) {
        setState(() {
          _userStats = stats;
          _userStreak = streak;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final name = user != null ? user.firstName : 'Guest';

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
              // ─── SECTION 1: TOP BAR ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning 🌿",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: AppColors.kNavy.withOpacity(0.65),
                        ),
                      ),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kNavy,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.notifications_outlined, color: AppColors.kNavy, size: 24),
                      SizedBox(width: 12),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.kPrimary,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── DASHBOARD STATS ───
              if (_isLoadingStats)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_userStats != null)
                Row(
                  children: [
                    Expanded(child: _buildStatCard("${_userStats!.totalMinutes}m", "Practiced")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard("${_userStats!.totalSessions}", "Sessions")),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        _userStats!.favoritePose?.poseName.split(' ').first ?? "-", 
                        "Fav Pose",
                      ),
                    ),
                  ],
                ),
              if (!_isLoadingStats && _userStats != null)
                const SizedBox(height: 24),

              // ─── SECTION 2: STREAK CARD ───
              if (!_isLoadingStats && _userStreak != null)
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.kPrimary.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_fire_department, color: AppColors.kSkyBlue, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${_userStreak!.currentStreak} Day Streak",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kNavy,
                                ),
                              ),
                              Text(
                                _userStreak!.currentStreak >= _userStreak!.longestStreak && _userStreak!.currentStreak > 0
                                    ? "Personal Best!"
                                    : "Longest: ${_userStreak!.longestStreak} days",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.kNavy.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Text("🏆", style: TextStyle(fontSize: 30)),
                    ],
                  ),
                ),
              if (!_isLoadingStats && _userStreak != null)
                const SizedBox(height: 24),

              // ─── SECTION 3: TODAY'S SESSION ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Session",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: AppColors.kSkyBlue,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildPoseCard(context, posesData[0]),
                    const SizedBox(width: 12),
                    _buildPoseCard(context, posesData[1]),
                    const SizedBox(width: 12),
                    _buildPoseCard(context, posesData[2]),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── SECTION 4: START DETECTION ───
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start Pose\nDetection",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kNavy,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Point camera at yourself to begin",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: AppColors.kNavy.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () {
                              PoseSelectionSheet.show(context);
                            },
                            child: Container(
                              height: 40,
                              width: 130,
                              decoration: BoxDecoration(
                                color: AppColors.kPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Start Now",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.camera_enhance_outlined,
                      size: 72,
                      color: AppColors.kNavy.withOpacity(0.08),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── SECTION 5: RECENT SESSIONS ───
              Text(
                "Recent Sessions",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kNavy,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentSessionTile("Sun Salutation"),
              const SizedBox(height: 10),
              _buildRecentSessionTile("Warrior II"),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kSkyBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.kNavy.withOpacity(0.65),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPoseCard(BuildContext context, PoseModel pose) {
    return GestureDetector(
      onTap: () => PoseSelectionSheet.show(context),
      child: SizedBox(
        width: 145,
        child: GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.kPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(pose.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                pose.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kNavy,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${pose.durationMinutes} min',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.kNavy.withOpacity(0.65),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.kTeal.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pose.difficulty,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.kTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSessionTile(String poseName) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.kPrimary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.accessibility_new, color: AppColors.kSkyBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poseName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kNavy,
                  ),
                ),
                Text(
                  "Today • 12 min • 91% accuracy",
                  style: TextStyle(
                    color: AppColors.kNavy.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.kSkyBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "View",
              style: TextStyle(
                color: AppColors.kSkyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
