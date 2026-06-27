import '../../core/network/api_client.dart';

class PoseService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches yoga poses with optional filters
  Future<Map<String, dynamic>> getPoses({
    int? page,
    int? limit,
    String? difficulty,
    int? level,
    String? targetArea,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (level != null) queryParams['level'] = level.toString();
      if (targetArea != null) queryParams['target_area'] = targetArea;
      if (search != null) queryParams['search'] = search;

      final queryString = queryParams.isEmpty
          ? ''
          : '?${Uri(queryParameters: queryParams).query}';

      final dynamic raw = await _apiClient.get('/api/v1/poses$queryString');
      
      if (raw == null) {
        throw ApiException('Empty response from server.');
      }
      
      return Map<String, dynamic>.from(raw as Map);
      
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch poses: ${e.toString()}');
    }
  }

  /// Get a specific pose by ID or slug
  Future<Map<String, dynamic>> getPoseDetails(String idOrSlug) async {
    try {
      final dynamic raw = await _apiClient.get('/api/v1/poses/$idOrSlug');
      
      if (raw == null) {
        throw ApiException('Pose not found.');
      }
      
      return Map<String, dynamic>.from(raw as Map);
      
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch pose details: ${e.toString()}');
    }
  }
}

