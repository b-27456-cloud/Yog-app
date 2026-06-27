import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required int age,
    required String accessibilityProfile,
  }) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/register', body: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'age': age,
        'accessibility_profile': accessibilityProfile,
      });

      // Backend returns 201 with user profile
      final userData = response['data']?['user'] ?? 
                       response['user'] ?? 
                       response['data'] ?? 
                       response;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException && e.message.toLowerCase().contains('already exists')) {
        throw ValidationException('An account with this email already exists. Try logging in.');
      }
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/login', body: {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setBool('isLoggedIn', true);
      }

      final userData = response['data']?['user'] ?? 
                       response['user'] ?? 
                       response['data'] ?? 
                       response;
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is ApiException && 
         (e.message.toLowerCase().contains('invalid') || 
          e.message.toLowerCase().contains('incorrect') || 
          e.message.toLowerCase().contains('not found'))) {
        throw ValidationException('Incorrect email or password.');
      }
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/api/v1/auth/me');
    
    // Robust extraction to handle various backend response formats
    final userData = response['data']?['user'] ?? 
                     response['user'] ?? 
                     response['data'] ?? 
                     response;
                     
    return UserModel.fromJson(userData);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.setBool('isLoggedIn', false);
  }
}
