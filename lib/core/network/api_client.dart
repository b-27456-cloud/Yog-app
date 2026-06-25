import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://yoga-backend-t0rq.onrender.com';
  
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    return _request(() async {
      final headers = await _getHeaders();
      return await _client.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    });
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(() async {
      final headers = await _getHeaders();
      return await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(() async {
      final headers = await _getHeaders();
      return await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> _request(Future<http.Response> Function() requestFunc) async {
    try {
      final response = await requestFunc();
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please check your network and try again.');
    } on FormatException {
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Something went wrong on our end. Please try again in a moment.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else if (response.statusCode == 401) {
      throw SessionExpiredException('Your session has expired. Please log in again.');
    } else {
      String message = 'An error occurred';
      try {
        final errorBody = jsonDecode(response.body);
        message = errorBody['message'] ?? errorBody['error'] ?? message;
      } catch (_) {}
      
      if (response.statusCode >= 500) {
        throw ApiException('Something went wrong on our end. Please try again in a moment.');
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        throw ValidationException(message);
      }
      
      throw ApiException(message);
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class SessionExpiredException extends ApiException {
  SessionExpiredException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
