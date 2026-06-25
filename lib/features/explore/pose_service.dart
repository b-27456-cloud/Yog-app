import '../../core/network/api_client.dart';

class PoseService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches a paginated list of all published yoga poses.
  Future<Map<String, dynamic>> getPoses({
    int? page,
    int? limit,
    String? difficulty,
    int? level,
    String? targetArea,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    if (level != null) queryParams['level'] = level.toString();
    if (targetArea != null) queryParams['target_area'] = targetArea;

    final queryString = queryParams.isEmpty
        ? ''
        : '?${Uri(queryParameters: queryParams).query}';

    // _apiClient.get returns dynamic (could be null if body is empty)
    final dynamic raw = await _apiClient.get('/api/v1/poses$queryString');
    if (raw == null) {
      throw ApiException('Empty response from server. Please try again.');
    }
    return Map<String, dynamic>.from(raw as Map);
  }

  /// Retrieves the full details for a specific pose.
  Future<Map<String, dynamic>> getPoseDetails(String idOrSlug) async {
    final dynamic raw = await _apiClient.get('/api/v1/poses/$idOrSlug');
    if (raw == null) {
      throw ApiException('Pose not found on server.');
    }
    return Map<String, dynamic>.from(raw as Map);
  }
}
