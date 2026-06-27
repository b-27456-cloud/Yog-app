import 'api_client.dart';
import '../models/analytics_models.dart';
import '../models/achievement_models.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  Future<UserStats> fetchUserStats(String userId) async {
    final response = await _apiClient.get('/api/v1/analytics/user/$userId/stats');
    return UserStats.fromJson(response['data'] ?? {});
  }

  Future<UserStreak> fetchUserStreak(String userId) async {
    final response = await _apiClient.get('/api/v1/streaks/user/$userId');
    return UserStreak.fromJson(response['data'] ?? {});
  }

  Future<List<String>> fetchUserInsights(String userId) async {
    final response = await _apiClient.get('/api/v1/analytics/user/$userId/insights');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => e.toString()).toList();
  }

  Future<SessionResponse> fetchUserSessions(String userId, {int page = 1, int limit = 10}) async {
    final response = await _apiClient.get('/api/v1/sessions/user/$userId?page=$page&limit=$limit');
    return SessionResponse.fromJson(response ?? {});
  }

  /// GET /api/v1/achievements — full catalog
  Future<List<Achievement>> fetchAllAchievements() async {
    final response = await _apiClient.get('/api/v1/achievements');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/achievements/user/:userId — what this user has earned
  Future<List<UserAchievement>> fetchUserAchievements(String userId) async {
    final response = await _apiClient.get('/api/v1/achievements/user/$userId');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => UserAchievement.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/notifications  (auth token in header identifies the user)
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _apiClient.get('/api/v1/notifications');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }
}

