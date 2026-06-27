import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/network/analytics_service.dart';
import '../../core/models/achievement_models.dart';
import '../auth/auth_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  List<Achievement> _all = [];
  Set<String> _unlockedSlugs = {};
  Map<String, DateTime?> _earnedDates = {};
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() { _isLoading = true; _error = null; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? '';

    try {
      final results = await Future.wait([
        _analyticsService.fetchAllAchievements(),
        _analyticsService.fetchUserAchievements(userId),
      ]);
      final allAch = results[0] as List<Achievement>;
      final userAch = results[1] as List<UserAchievement>;

      if (mounted) {
        setState(() {
          _all = allAch;
          _unlockedSlugs = userAch.map((u) => u.achievement.slug).toSet();
          _earnedDates = {for (var u in userAch) u.achievement.slug: u.earnedAt};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _conditionLabel(String type) {
    switch (type) {
      case 'sessions':
        return 'sessions';
      case 'streak_days':
        return 'day streak';
      case 'accuracy':
        return '% accuracy';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _all.where((a) => _unlockedSlugs.contains(a.slug)).toList();
    final totalPoints = unlocked.fold<int>(0, (sum, a) => sum + a.pointsReward);

    final categories = ['All', ..._all.map((a) => a.category).toSet().toList()..sort()];

    final filtered = _selectedCategory == 'All'
        ? _all
        : _all.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.kPrimary,
        child: CustomScrollView(
          slivers: [
            // ─── HEADER ───
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.kNavy, AppColors.kPrimary],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Achievements',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.kNavy.withOpacity(0.65), fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.kPrimary, foregroundColor: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ─── SUMMARY ROW ───
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GlassCard(
                                      borderRadius: 14,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${unlocked.length}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.kSkyBlue,
                                            ),
                                          ),
                                          Text(
                                            'Earned',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.kNavy.withOpacity(0.65),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GlassCard(
                                      borderRadius: 14,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$totalPoints',
                                            style: GoogleFonts.poppins(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.kSkyBlue,
                                            ),
                                          ),
                                          Text(
                                            'Points',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.kNavy.withOpacity(0.65),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ─── CATEGORY FILTER ───
                            SizedBox(
                              height: 38,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: categories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  final isSelected = _selectedCategory == cat;
                                  return ChoiceChip(
                                    label: Text(
                                      cat,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : AppColors.kNavy,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (_) => setState(() => _selectedCategory = cat),
                                    selectedColor: AppColors.kPrimary,
                                    backgroundColor: AppColors.kPrimary.withOpacity(0.08),
                                    showCheckmark: false,
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
            ),

            // ─── BADGE GRID ───
            if (!_isLoading && _error == null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBadgeCard(filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }

  Widget _buildBadgeCard(Achievement a) {
    final isUnlocked = _unlockedSlugs.contains(a.slug);

    Widget content = GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      color: isUnlocked ? AppColors.kSkyBlue.withOpacity(0.12) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ─── ICON ───
          if (a.iconUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                a.iconUrl!,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: isUnlocked ? AppColors.kSkyBlue : AppColors.kNavy.withOpacity(0.3),
                ),
              ),
            )
          else
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: isUnlocked ? AppColors.kSkyBlue : AppColors.kNavy.withOpacity(0.3),
            ),

          const SizedBox(height: 10),

          // ─── NAME ───
          Text(
            a.name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.kNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // ─── POINTS ───
          Text(
            '+${a.pointsReward} pts',
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? AppColors.kSkyBlue : AppColors.kNavy.withOpacity(0.35),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          // ─── STATUS CHIP ───
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '✓ Unlocked',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.kNavy.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🔒 ${a.conditionValue} ${_conditionLabel(a.conditionType)}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.kNavy.withOpacity(0.45),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );

    if (!isUnlocked) {
      content = Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: content,
        ),
      );
    }

    return content;
  }
}
