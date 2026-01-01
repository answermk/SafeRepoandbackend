import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Contact Service
/// Handles fetching admin contact information
class ContactService {
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get admin contact information
  /// Backend: GET /api/users/admin/contact-info
  static Future<Map<String, dynamic>> getAdminContactInfo() async {
    try {
      final token = await getAuthToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/admin/contact-info'),
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
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

