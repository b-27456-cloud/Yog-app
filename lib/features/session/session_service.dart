import '../../core/network/api_client.dart';

class SessionService {
  final ApiClient _apiClient = ApiClient();

  /// Initiates a new live yoga session for the selected pose.
  Future<Map<String, dynamic>> startSession({
    required String poseId,
    required String musicId,
  }) async {
    final dynamic raw = await _apiClient.post(
      '/api/v1/sessions/start',
      body: {
        'pose_id': poseId,
        'music_id': musicId,
      },
    );
    // null = backend returned empty body (unlikely for 201, but guard anyway)
    if (raw == null) {
      throw ApiException('No response from server when starting session.');
    }
    return Map<String, dynamic>.from(raw as Map);
  }

  /// Sends MediaPipe body landmarks for real-time form evaluation.
  Future<Map<String, dynamic>> logFrame({
    required String sessionId,
    required List<Map<String, dynamic>> landmarks,
  }) async {
    final dynamic raw = await _apiClient.post(
      '/api/v1/sessions/$sessionId/log-frame',
      body: {'landmarks': landmarks},
    );
    if (raw == null) return {'data': null}; // non-fatal: keep streaming
    return Map<String, dynamic>.from(raw as Map);
  }

  /// Completes the active session.
  Future<Map<String, dynamic>> endSession({
    required String sessionId,
    String? notes,
  }) async {
    final dynamic raw = await _apiClient.post(
      '/api/v1/sessions/$sessionId/end',
      body: {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    // End session may return 204 No Content — treat null as success
    if (raw == null) return {'status': 'success', 'data': null};
    return Map<String, dynamic>.from(raw as Map);
  }
}
