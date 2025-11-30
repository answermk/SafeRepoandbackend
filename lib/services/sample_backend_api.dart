/// Sample Backend API Integration Examples
/// 
/// This file contains example code showing how to integrate with backend APIs.
/// Replace the sample implementations with your actual backend service calls.
/// 
/// When your backend is ready:
/// 1. Replace sample functions with actual HTTP calls (using http package or Dio)
/// 2. Update base URLs and endpoints
/// 3. Add proper error handling
/// 4. Implement authentication tokens
/// 5. Add request/response models

import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:dio/dio.dart';

/// Base URL for your backend API
const String baseUrl = 'https://api.saferreport.com/v1';

/// Sample Authentication Service
class AuthService {
  /// Example: Login API call
  /// 
  /// Backend endpoint: POST /auth/login
  /// Request body: { "email": "user@example.com", "password": "password123" }
  /// Response: { "success": true, "token": "jwt_token", "user": {...} }
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // TODO: Replace with actual API call
    /*
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
    */

    // Sample response (remove when backend is ready)
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'token': 'sample_jwt_token_here',
      'user': {
        'id': '123',
        'email': email,
        'name': 'John Doe',
      },
    };
  }

  /// Example: Change Password API call
  /// 
  /// Backend endpoint: POST /auth/change-password
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Request body: { "currentPassword": "...", "newPassword": "..." }
  /// Response: { "success": true, "message": "Password changed successfully" }
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    // TODO: Replace with actual API call
    /*
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Password change failed');
    }
    */

    // Sample response (remove when backend is ready)
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Password changed successfully',
    };
  }

  /// Example: Logout API call
  /// 
  /// Backend endpoint: POST /auth/logout
  /// Headers: { "Authorization": "Bearer {token}" }
  static Future<void> logout(String token) async {
    // TODO: Replace with actual API call
    /*
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    */

    // Sample implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Sample Report Service
class ReportService {
  /// Example: Submit Report API call
  /// 
  /// Backend endpoint: POST /reports
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Request body: FormData with report data and media files
  /// Response: { "success": true, "reportId": "123", "status": "submitted" }
  static Future<Map<String, dynamic>> submitReport({
    required Map<String, dynamic> reportData,
    required List<String> mediaPaths,
    required String token,
  }) async {
    // TODO: Replace with actual API call
    /*
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/reports'));
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add report data
    request.fields['incidentType'] = reportData['incidentType'];
    request.fields['description'] = reportData['description'];
    request.fields['location'] = jsonEncode(reportData['location']);
    request.fields['submitAnonymously'] = reportData['submitAnonymously'].toString();
    
    // Add media files
    for (var path in mediaPaths) {
      request.files.add(await http.MultipartFile.fromPath('media', path));
    }
    
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Report submission failed');
    }
    */

    // Sample response (remove when backend is ready)
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'reportId': 'report_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'submitted',
      'message': 'Report submitted successfully',
    };
  }

  /// Example: Save Draft API call
  /// 
  /// Backend endpoint: PUT /reports/draft
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Request body: { "draft": {...} }
  static Future<void> saveDraft(Map<String, dynamic> draftData, String token) async {
    // TODO: Replace with actual API call
    /*
    await http.put(
      Uri.parse('$baseUrl/reports/draft'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'draft': draftData}),
    );
    */

    // Sample implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Example: Get User Reports API call
  /// 
  /// Backend endpoint: GET /reports?status={status}&page={page}
  /// Headers: { "Authorization": "Bearer {token}" }
  static Future<List<Map<String, dynamic>>> getUserReports({
    String? status,
    int page = 1,
    required String token,
  }) async {
    // TODO: Replace with actual API call
    /*
    final queryParams = {
      'page': page.toString(),
      if (status != null) 'status': status,
    };
    
    final response = await http.get(
      Uri.parse('$baseUrl/reports').replace(queryParameters: queryParams),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['reports']);
    } else {
      throw Exception('Failed to load reports');
    }
    */

    // Sample response (remove when backend is ready)
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'id': '1',
        'incidentType': 'suspicious_person',
        'description': 'Sample report',
        'status': 'submitted',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];
  }
}

/// Sample Notification Service
class NotificationService {
  /// Example: Register Device Token for Push Notifications
  /// 
  /// Backend endpoint: POST /notifications/register
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Request body: { "deviceToken": "...", "platform": "android|ios" }
  static Future<void> registerDeviceToken({
    required String deviceToken,
    required String platform,
    required String token,
  }) async {
    // TODO: Replace with actual API call
    /*
    await http.post(
      Uri.parse('$baseUrl/notifications/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'deviceToken': deviceToken,
        'platform': platform,
      }),
    );
    */

    // Sample implementation
    await Future.delayed(const Duration(milliseconds: 500));
    print('Device token registered: $deviceToken');
  }
}

/// Sample User Service
class UserService {
  /// Example: Update User Profile API call
  /// 
  /// Backend endpoint: PUT /users/profile
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Request body: { "name": "...", "email": "...", "phone": "..." }
  static Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> profileData,
    required String token,
  }) async {
    // TODO: Replace with actual API call
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Profile update failed');
    }
    */

    // Sample response (remove when backend is ready)
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'user': profileData,
    };
  }

  /// Example: Update Accessibility Settings API call
  /// 
  /// Backend endpoint: PUT /users/accessibility
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Request body: { "fontSize": 16, "highContrast": false, "textToSpeech": false }
  static Future<void> updateAccessibilitySettings({
    required Map<String, dynamic> settings,
    required String token,
  }) async {
    // TODO: Replace with actual API call
    /*
    await http.put(
      Uri.parse('$baseUrl/users/accessibility'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(settings),
    );
    */

    // Sample implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Sample Watch Group Service
class WatchGroupService {
  /// Example: Get Watch Groups API call
  /// 
  /// Backend endpoint: GET /watch-groups
  /// Headers: { "Authorization": "Bearer {token}" }
  static Future<List<Map<String, dynamic>>> getWatchGroups(String token) async {
    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('$baseUrl/watch-groups'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['groups']);
    } else {
      throw Exception('Failed to load watch groups');
    }
    */

    // Sample response (remove when backend is ready)
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}

/// Error Handling Helper
class ApiError {
  final String message;
  final int? statusCode;

  ApiError(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Token Management Helper
class TokenManager {
  static String? _token;
  static DateTime? _expiry;

  static void setToken(String token, DateTime expiry) {
    _token = token;
    _expiry = expiry;
  }

  static String? getToken() {
    if (_token == null || _expiry == null) return null;
    if (DateTime.now().isAfter(_expiry!)) {
      _token = null;
      _expiry = null;
      return null;
    }
    return _token;
  }

  static void clearToken() {
    _token = null;
    _expiry = null;
  }
}

