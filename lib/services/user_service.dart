import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// User Service
/// Handles user profile operations
class UserService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get user profile by ID
  /// Backend: GET /api/users/{id}
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
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
  
  /// Update user profile
  /// Backend: PUT /api/users/{id}
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? location,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? anonymousMode,
    bool? locationSharing,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (fullName != null) requestBody['fullName'] = fullName;
      if (phone != null) requestBody['phoneNumber'] = phone; // Backend expects phoneNumber
      if (anonymousMode != null) requestBody['anonymousMode'] = anonymousMode;
      if (locationSharing != null) requestBody['locationSharing'] = locationSharing;
      // Note: location, emergencyContactName, emergencyContactPhone are not in UpdateUserRequest DTO
      // They may be added to the backend DTO in the future
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
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
  
  /// Update user profile by email
  /// Backend: PUT /api/users/by-email/{email}
  static Future<Map<String, dynamic>> updateUserProfileByEmail({
    required String email,
    String? fullName,
    String? phone,
    String? location,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (fullName != null) requestBody['fullName'] = fullName;
      if (phone != null) requestBody['phoneNumber'] = phone; // Backend expects phoneNumber
      // Note: location, emergencyContactName, emergencyContactPhone are not in UpdateUserRequest DTO
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/users/by-email/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
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
  
  /// Change password
  /// Backend: PUT /api/users/{id}/change-password
  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/users/$userId/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': newPassword, // Backend expects confirmPassword
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonDecode(response.body)['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Get user statistics
  /// Backend: GET /api/users/stats
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
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
}

