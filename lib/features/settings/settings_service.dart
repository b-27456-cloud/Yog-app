import '../../core/network/api_client.dart';
import '../../core/models/settings_model.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  Future<SettingsModel> updateSettings(String userId, SettingsModel settings) async {
    final response = await _apiClient.put(
      '/api/v1/users/$userId/settings',
      body: settings.toJson(),
    );
    
    return SettingsModel.fromJson(response['settings'] ?? response);
  }
}
