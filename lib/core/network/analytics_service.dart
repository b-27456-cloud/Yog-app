import 'api_client.dart';
import '../models/analytics_models.dart';

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
}
