import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../network/analytics_service.dart';
import '../models/analytics_models.dart';
import '../../features/auth/auth_provider.dart';

class SessionHistorySheet extends StatefulWidget {
  const SessionHistorySheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<AuthProvider>(context, listen: false),
        child: const SessionHistorySheet(),
      ),
    );
  }

  @override
  State<SessionHistorySheet> createState() => _SessionHistorySheetState();
}

class _SessionHistorySheetState extends State<SessionHistorySheet> {
  List<SessionRecord> _sessions = [];
  SessionMeta? _sessionMeta;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;

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
          _errorMessage = 'User not logged in.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
      });
    }

    try {
      final res = await AnalyticsService().fetchUserSessions(userId, page: 1);
      if (mounted) {
        setState(() {
          _sessions = res.sessions;
          _sessionMeta = res.meta;
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

  Future<void> _loadMoreSessions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) return;
    if (_sessionMeta == null) return;

    final nextPage = _currentPage + 1;
    if (nextPage > _sessionMeta!.pages) return;

    try {
      final res = await AnalyticsService().fetchUserSessions(userId, page: nextPage);
      if (mounted) {
        setState(() {
          _sessions.addAll(res.sessions);
          _sessionMeta = res.meta;
          _currentPage = nextPage;
        });
      }
    } catch (_) {
      // Ignore pagination errors to keep existing items visible
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── DRAG HANDLE ───
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.kNavy.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ─── TITLE ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              'Session History',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.kNavy,
              ),
            ),
          ),

          const Divider(height: 1),

          // ─── CONTENT ───
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
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
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        children: [
                          if (_sessions.isEmpty)
                            GlassCard(
                              borderRadius: 14,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No sessions recorded yet.',
                                style: TextStyle(
                                  color: AppColors.kNavy.withOpacity(0.65),
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else ...[
                            ..._sessions.map((session) {
                              final durationMin = (session.durationSeconds / 60).round();
                              final dateStr = session.startTime != null
                                  ? _formatDate(session.startTime!)
                                  : 'Unknown date';
                              final isDone = session.completed;
                              final poseName = session.pose.name.isNotEmpty
                                  ? session.pose.name
                                  : 'Yoga Session';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: GlassCard(
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
                                        child: const Icon(Icons.history, color: AppColors.kSkyBlue, size: 24),
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
                                              '$dateStr • $durationMin min • ${session.accuracyAverage}% accuracy',
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
                                          color: isDone
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isDone ? 'Done' : 'Partial',
                                          style: TextStyle(
                                            color: isDone
                                                ? Colors.green.shade700
                                                : Colors.orange.shade800,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            if (_sessionMeta != null && _currentPage < _sessionMeta!.pages)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextButton(
                                  onPressed: _loadMoreSessions,
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColors.kPrimary.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Load More',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.kPrimary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
