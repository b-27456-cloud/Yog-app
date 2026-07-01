import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../network/api_client.dart';

/// Shows a premium modal bottom sheet informing the user that a pose is
/// locked behind completing all beginner poses.
///
/// [lockedError] is the [PoseLockedException] thrown by [ApiClient].
/// [rawMessage] can be passed instead when you only have the string.
/// At least one must be non-null.
Future<void> showPoseLockedSheet(
  BuildContext context, {
  PoseLockedException? lockedError,
  String? rawMessage,
}) {
  assert(lockedError != null || rawMessage != null,
      'Provide either lockedError or rawMessage.');

  final List<String> remaining = lockedError?.remainingPoses ??
      _parseRemainingPoses(rawMessage ?? '');

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PoseLockedSheet(remainingPoses: remaining),
  );
}

List<String> _parseRemainingPoses(String message) {
  const marker = 'Remaining beginner poses: ';
  final idx = message.indexOf(marker);
  if (idx == -1) return [];
  final raw =
      message.substring(idx + marker.length).replaceAll(RegExp(r'\.$'), '');
  return raw.split(', ').where((s) => s.isNotEmpty).toList();
}

// ─────────────────────────────────────────────────────────────────────────────

class _PoseLockedSheet extends StatelessWidget {
  final List<String> remainingPoses;

  const _PoseLockedSheet({required this.remainingPoses});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: bottomPadding + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.kNavy.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Lock Icon with Glow ──
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3CD), Color(0xFFFFE08A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.40),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.lock_rounded, size: 40, color: Color(0xFF8B6914)),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ──
          Text(
            'Pose Locked',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.kNavy,
            ),
          ),
          const SizedBox(height: 8),

          // ── Subtitle ──
          Text(
            'Complete these beginner poses first:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.kNavy.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Remaining Poses List ──
          if (remainingPoses.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: remainingPoses
                      .map((pose) => _PoseChip(label: pose))
                      .toList(),
                ),
              ),
            )
          else
            Text(
              'You need to complete all beginner poses before accessing this pose.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.kNavy.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 28),

          // ── CTA Button ──
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                context.go('/explore?difficulty=beginner');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.self_improvement, size: 20),
              label: Text(
                'Go to Beginner Poses',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Secondary — dismiss ──
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe later',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.kNavy.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PoseChip extends StatelessWidget {
  final String label;

  const _PoseChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kInputBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kNavy.withOpacity(0.10),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.kNavy,
            ),
          ),
        ],
      ),
    );
  }
}
