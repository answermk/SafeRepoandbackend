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
        // Response: { "token": "...", "email": "...", "username": "...", "userId": "..." }
        return {
          'success': true,
          'token': data['token'],
          'email': data['email'],
          'username': data['username'],
          'userId': data['userId'] ?? data['id'], // Support both userId and id fields
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
    required String phoneNumber,
    String? username,
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
          'phoneNumber': phoneNumber,
          if (username != null && username.isNotEmpty) 'username': username,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Account created successfully! Please sign in.',
        };
      } else {
        // Parse error message from backend
        String errorMessage = 'Failed to create account';
        try {
          final errorBody = response.body;
          if (errorBody.isNotEmpty) {
            // Try to parse as JSON first
            try {
              final errorJson = jsonDecode(errorBody);
              errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorBody;
            } catch (e) {
              // If not JSON, use body as is
              errorMessage = errorBody;
            }
          }
        } catch (e) {
          errorMessage = 'Failed to create account. Please try again.';
        }
        
        return {
          'success': false,
          'error': errorMessage,
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
  
  /// Verify 6-digit code
  /// Backend: POST /api/auth/verify-code
  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/verify-code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
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

  /// Change password using email and code
  /// Backend: POST /api/auth/change-password
  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
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

  /// Reset password (legacy - using token)
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

