import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/pose_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import 'pose_provider.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialDifficulty;
  const ExploreScreen({Key? key, this.initialDifficulty}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late TextEditingController _searchController;
  final List<String> _difficulties = ["All", "Beginner", "Intermediate", "Advanced"];
  final List<String> _areas = ["All", "Strength", "Balance", "Flexibility", "Cardio"];
  
  String _selectedDifficulty = "All";
  String _selectedArea = "All";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Pre-seed difficulty filter if navigated with one (e.g. from lock sheet CTA)
    if (widget.initialDifficulty != null) {
      final seed = widget.initialDifficulty![0].toUpperCase() +
          widget.initialDifficulty!.substring(1).toLowerCase();
      if (_difficulties.contains(seed)) {
        _selectedDifficulty = seed;
      }
    }

    // Initialize poses on first load
    Future.microtask(() {
      final provider = Provider.of<PoseProvider>(context, listen: false);
      provider.initializePoses().then((_) {
        if (mounted && _selectedDifficulty != 'All') {
          provider.applyFilters(difficulty: _selectedDifficulty);
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Provider.of<PoseProvider>(context, listen: false).applyFilters(
      searchQuery: _searchController.text,
      difficulty: _selectedDifficulty,
      area: _selectedArea,
    );
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<PoseProvider>(context, listen: false);
    await provider.retry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Consumer<PoseProvider>(
        builder: (context, poseProvider, _) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.kPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                          const SizedBox(height: 24),
                          // _buildFilters(poseProvider),
                          // const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                if (poseProvider.isLoading && poseProvider.allPoses.isEmpty)
                  SliverToBoxAdapter(child: _buildLoadingState())
                else if (poseProvider.errorMessage != null && poseProvider.allPoses.isEmpty)
                  SliverToBoxAdapter(child: _buildErrorState(poseProvider))
                else if (poseProvider.filteredPoses.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  _buildContent(poseProvider),
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for nav bar
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }

  // ─── HEADER ───
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Discover",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.kNavy,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Find your perfect practice today",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.kNavy.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─── SEARCH BAR ───
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kInputBg ?? AppColors.kNavy.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kNavy.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilters(),
        style: GoogleFonts.poppins(color: AppColors.kNavy, fontSize: 15),
        cursorColor: AppColors.kPrimary,
        decoration: InputDecoration(
          hintText: "Search poses, benefits...",
          hintStyle: GoogleFonts.poppins(color: AppColors.kNavy.withOpacity(0.4), fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.kNavy.withOpacity(0.5)),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                  child: Icon(Icons.close_rounded, color: AppColors.kNavy.withOpacity(0.5)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ─── FILTERS ───
  Widget _buildFilters(PoseProvider poseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterRow(
          title: "Level",
          items: _difficulties,
          selectedValue: _selectedDifficulty,
          onSelected: (value) {
            setState(() => _selectedDifficulty = value);
            poseProvider.applyFilters(difficulty: value);
          },
        ),
        const SizedBox(height: 16),
        _buildFilterRow(
          title: "Focus",
          items: _areas,
          selectedValue: _selectedArea,
          onSelected: (value) {
            setState(() => _selectedArea = value);
            poseProvider.applyFilters(area: value);
          },
        ),
      ],
    );
  }

  Widget _buildFilterRow({
    required String title,
    required List<String> items,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.kNavy.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedValue == item;
                return GestureDetector(
                  onTap: () => onSelected(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.kPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.kPrimary : AppColors.kNavy.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.kPrimary.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : AppColors.kNavy.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── MAIN CONTENT ───
  Widget _buildContent(PoseProvider poseProvider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (poseProvider.allPoses.isNotEmpty && _searchController.text.isEmpty) ...[
            _buildFeaturedCard(poseProvider.getFeaturedPose()!),
            const SizedBox(height: 28),
          ],
          _buildResultsHeader(poseProvider),
          const SizedBox(height: 16),
          _buildPosesGrid(poseProvider.filteredPoses),
        ]),
      ),
    );
  }

  // ─── FEATURED CARD ───
  Widget _buildFeaturedCard(PoseModel pose) {
    return GestureDetector(
      onTap: () => context.push('/pose-detail/${pose.id}'),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.kPrimary,
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (pose.imageUrl != null && pose.imageUrl!.isNotEmpty)
              Image.network(
                pose.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderPattern(),
              )
            else
              _buildPlaceholderPattern(),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Featured",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pose.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${pose.difficulty} • ${pose.durationMinutes} mins",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPattern() {
    return Container(
      color: AppColors.kPrimary,
      child: CustomPaint(
        painter: GridPatternPainter(color: Colors.white.withOpacity(0.05)),
      ),
    );
  }

  // ─── RESULTS HEADER ───
  Widget _buildResultsHeader(PoseProvider poseProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "All Poses",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.kNavy,
          ),
        ),
        Text(
          "${poseProvider.filteredPoses.length} found",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.kNavy.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── POSES GRID ───
  Widget _buildPosesGrid(List<PoseModel> poses) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Taller cards for images
      ),
      itemCount: poses.length,
      itemBuilder: (context, index) {
        final pose = poses[index];
        return _buildPoseCard(context, pose, index);
      },
    );
  }

  // ─── POSE CARD ───
  Widget _buildPoseCard(BuildContext context, PoseModel pose, int index) {
    final bool isLocked = pose.difficulty.toLowerCase() != 'beginner';

    return GestureDetector(
      onTap: () => context.push('/pose-detail/${pose.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.kNavy.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Card content ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: AppColors.kInputBg ?? AppColors.kNavy.withOpacity(0.05),
                    child: pose.imageUrl != null && pose.imageUrl!.isNotEmpty
                        ? Image.network(
                            pose.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(pose.icon, color: AppColors.kNavy.withOpacity(0.2), size: 40),
                            ),
                          )
                        : Center(
                            child: Icon(pose.icon, color: AppColors.kNavy.withOpacity(0.2), size: 40),
                          ),
                  ),
                ),
                // Details Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pose.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.kNavy,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pose.difficulty,
                              style: GoogleFonts.poppins(
                                color: AppColors.kSkyBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer_outlined, size: 12, color: AppColors.kNavy.withOpacity(0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  '${pose.durationMinutes}m',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.kNavy.withOpacity(0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Lock badge overlay (non-beginner poses) ──
            if (isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFFFFD700),
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── LOADING STATE ───
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.kPrimary),
          const SizedBox(height: 24),
          Text(
            "Curating poses for you...",
            style: GoogleFonts.poppins(
              color: AppColors.kNavy.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ─── ERROR STATE ───
  Widget _buildErrorState(PoseProvider poseProvider) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            "Oops! Connection Lost",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kNavy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            poseProvider.errorMessage ?? "Failed to load poses",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.kNavy.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => poseProvider.retry(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              "Try Again",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ───
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.kNavy.withOpacity(0.2)),
          const SizedBox(height: 24),
          Text(
            "No poses found",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters to find what you're looking for.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.kNavy.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for a subtle background pattern
class GridPatternPainter extends CustomPainter {
  final Color color;

  GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const double spacing = 20.0;
    
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
