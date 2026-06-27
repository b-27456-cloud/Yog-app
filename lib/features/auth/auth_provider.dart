import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/network/api_client.dart';
import '../../core/audio/music_service.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> checkSession() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
      MusicService.instance.start();
      return true;
    } on SessionExpiredException {
      await logout();
      return false;
    } catch (e) {
      // Allow proceeding if it's a network issue? 
      // Usually, if we have a token but network is down, we might want to stay on home.
      // But for simplicity, we'll assume valid if we don't get SessionExpiredException.
      // Actually, if it's a network error, maybe we assume false or show offline mode.
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _user = await _authService.login(email, password);
      _setLoading(false);
      MusicService.instance.start();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required int age,
    required String accessibilityProfile,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Backend returns 201 with user profile, but does not auto-login.
      await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        accessibilityProfile: accessibilityProfile,
      );
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await MusicService.instance.stop();
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
