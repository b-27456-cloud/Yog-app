import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/network/analytics_service.dart';
import '../../core/models/achievement_models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() { _isLoading = true; _error = null; });
    try {
      final notifs = await _analyticsService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifs;
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _timeStr(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return _formatDate(date);
  }

  Map<String, List<AppNotification>> _groupByDate(List<AppNotification> notifs) {
    final Map<String, List<AppNotification>> groups = {};
    for (final n in notifs) {
      final key = n.createdAt != null ? _formatDate(n.createdAt!) : 'Unknown';
      groups.putIfAbsent(key, () => []).add(n);
    }
    return groups;
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'badge':
        return Icons.emoji_events;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'badge':
        return const Color(0xFFFFD700);
      case 'system':
        return AppColors.kSkyBlue;
      default:
        return AppColors.kPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.kNavy, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.kNavy,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount new',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      extendBody: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.kNavy.withOpacity(0.65),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppColors.kNavy.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.kNavy.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: AppColors.kPrimary,
                      child: _buildList(),
                    ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }

  Widget _buildList() {
    final grouped = _groupByDate(_notifications);
    final entries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: entries.fold<int>(0, (sum, e) => sum + 1 + e.value.length),
      itemBuilder: (context, index) {
        // Flatten grouped map into a single list of widgets
        int cursor = 0;
        for (final entry in entries) {
          if (index == cursor) {
            // Date label
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                entry.key,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kNavy.withOpacity(0.45),
                ),
              ),
            );
          }
          cursor++;
          for (final n in entry.value) {
            if (index == cursor) {
              return _buildTile(n);
            }
            cursor++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTile(AppNotification n) {
    final iconColor = _colorForType(n.type);
    final icon = _iconForType(n.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.all(14),
        color: n.read ? null : AppColors.kSkyBlue.withOpacity(0.06),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── ICON BOX ───
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // ─── TEXT ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.kNavy.withOpacity(0.65),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeStr(n.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.kNavy.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),

            // ─── UNREAD DOT ───
            if (!n.read)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.kSkyBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
