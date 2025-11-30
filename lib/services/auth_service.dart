import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_client.dart';
import 'token_manager.dart';

/// Authentication Service
/// Handles login, register, password reset, etc.
class AuthService {
  
  /// Login user
  /// Backend: POST /api/auth/login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Response: { "token": "...", "email": "...", "username": "..." }
        return {
          'success': true,
          'token': data['token'],
          'email': data['email'],
          'username': data['username'],
        };
      } else {
        return {
          'success': false,
          'error': 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Register new user
  /// Backend: POST /api/auth/register
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (location != null) 'location': location,
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body, // "User registered successfully"
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Forgot password
  /// Backend: POST /api/auth/forgot-password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body,
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Reset password
  /// Backend: POST /api/auth/reset-password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body,
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Validate reset token
  /// Backend: GET /api/auth/validate-reset-token/{token}
  static Future<Map<String, dynamic>> validateResetToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/validate-reset-token/$token'),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body,
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Logout user
  /// Backend: POST /api/auth/logout
  static Future<void> logout() async {
    try {
      final token = await TokenManager.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConfig.apiBaseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await TokenManager.clearToken();
    }
  }
}

