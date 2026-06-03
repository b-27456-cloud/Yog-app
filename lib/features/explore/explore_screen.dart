import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/poses_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<String> _categories = [
    "All", "Beginner", "Intermediate", "Advanced", "Balance", "Strength", "Flexibility"
  ];
  String _activeCategory = "All";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── TOP: SEARCH BAR ───
              const SizedBox(height: 16),
              GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.kNavy.withOpacity(0.65), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.kNavy),
                        cursorColor: AppColors.kSkyBlue,
                        decoration: InputDecoration.collapsed(
                          hintText: "Search poses...",
                          hintStyle: TextStyle(color: AppColors.kNavy.withOpacity(0.65)),
                        ),
                      ),
                    ),
                    const Icon(Icons.tune, color: AppColors.kSkyBlue, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── CATEGORY CHIPS ───
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: _categories.map((category) {
                      final isActive = _activeCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeCategory = category;
                            });
                          },
                          child: isActive
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.kPrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : GlassCard(
                                  borderRadius: 20,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.kNavy.withOpacity(0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── FEATURED CARD ───
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.kSkyBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "✦ Featured",
                              style: GoogleFonts.poppins(
                                color: AppColors.kSkyBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            posesData[0].name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            posesData[0].description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.kNavy.withOpacity(0.65),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.kPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Start →",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${posesData[0].durationMinutes} min",
                                style: TextStyle(
                                  color: AppColors.kNavy.withOpacity(0.65),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      posesData[0].icon,
                      size: 80,
                      color: AppColors.kNavy.withOpacity(0.08),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "All Poses",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kNavy,
                ),
              ),
              const SizedBox(height: 12),

              // ─── POSE GRID ───
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 90), // padding for bottom nav
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: posesData.length,
                  itemBuilder: (context, index) {
                    final pose = posesData[index];
                    return GestureDetector(
                      onTap: () => context.push('/pose-detail/${pose.id}'),
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.kPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(pose.icon, color: AppColors.kSkyBlue, size: 24),
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
                              "• ${pose.difficulty}  • ${pose.durationMinutes} min",
                              style: TextStyle(
                                color: AppColors.kNavy.withOpacity(0.65),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.kSkyBlue.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }
}
