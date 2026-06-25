import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/explore/pose_service.dart';
import '../models/pose_model.dart';
import '../network/api_client.dart';
import '../theme/app_colors.dart';

class PoseSelectionSheet extends StatefulWidget {
  const PoseSelectionSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PoseSelectionSheet(),
    );
  }

  @override
  State<PoseSelectionSheet> createState() => _PoseSelectionSheetState();
}

class _PoseSelectionSheetState extends State<PoseSelectionSheet> {
  final PoseService _poseService = PoseService();
  List<PoseModel> _poses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPoses();
  }

  Future<void> _fetchPoses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _poseService.getPoses(limit: 50);
      // Backend returns { "status": "success", "poses": [...], "meta": {...} }
      final rawData = response['poses'];
      if (rawData is List) {
        if (!mounted) return;
        setState(() {
          _poses = rawData
              .map((e) => PoseModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Unexpected response from server.\nKeys found: ${response.keys.join(', ')}';
          _isLoading = false;
        });
      }
    } on SessionExpiredException {
      if (!mounted) return;
      setState(() {
        _error = 'Your session has expired. Please log in again.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unexpected error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle bar ──
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select a Pose',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kNavy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.kNavy),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),
          // ── Body ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _poses.isEmpty
                        ? _buildEmptyState()
                        : _buildPoseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Could not load poses',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.kNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.kNavy.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh),
              label: Text('Try Again', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onPressed: _fetchPoses,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.self_improvement, size: 56, color: AppColors.kPrimary),
          const SizedBox(height: 12),
          Text(
            'No poses available yet.',
            style: GoogleFonts.poppins(fontSize: 15, color: AppColors.kNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildPoseList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _poses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pose = _poses[index];
        return ListTile(
          onTap: () {
            Navigator.of(context).pop(); // Close bottom sheet
            context.push('/pose-detail/${pose.id}');
          },
          tileColor: AppColors.kPrimary.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.kPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(pose.icon, color: AppColors.kPrimary),
          ),
          title: Text(
            pose.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.kNavy),
          ),
          subtitle: Text(
            '${pose.durationMinutes} min • ${pose.difficulty}',
            style: TextStyle(fontSize: 12, color: AppColors.kNavy.withOpacity(0.65)),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.kNavy),
        );
      },
    );
  }
}
