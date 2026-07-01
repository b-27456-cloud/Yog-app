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
    } else if (response.statusCode == 403) {
      String message = 'Access denied.';
      try {
        final errorBody = jsonDecode(response.body);
        message = errorBody['message'] ?? errorBody['error'] ?? message;
      } catch (_) {}
      throw PoseLockedException(message);
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

/// Thrown when the backend returns HTTP 403 — the pose is gated behind
/// completing all beginner poses. The [message] contains the full API
/// message string, e.g.:
///   "You must complete all beginner poses before accessing intermediate
///    poses. Remaining beginner poses: Mountain Pose, Child's Pose."
class PoseLockedException extends ApiException {
  PoseLockedException(String message) : super(message);

  /// Parses the remaining beginner pose names out of the API message.
  List<String> get remainingPoses {
    const marker = 'Remaining beginner poses: ';
    final idx = message.indexOf(marker);
    if (idx == -1) return [];
    final raw = message.substring(idx + marker.length).replaceAll(RegExp(r'\.$'), '');
    return raw.split(', ').where((s) => s.isNotEmpty).toList();
  }
}
