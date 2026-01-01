import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Impact Service
/// Handles fetching user impact/performance metrics from the backend
class ImpactService {
  /// Get user impact metrics
  /// 
  /// [userId] - The user ID to get impact for
  /// Returns a map with 'success', 'data', and optionally 'error'
  static Future<Map<String, dynamic>> getUserImpact(String userId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication required. Please log in.',
        };
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/users/$userId/impact');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Impact Response Status: ${response.statusCode}');
      print('📊 Impact Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'You do not have permission to view this impact data.',
        };
      } else {
        String errorMessage = 'Failed to load impact data';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 
                        errorData['message'] ?? 
                        errorMessage;
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
              ? response.body 
              : 'Server error: ${response.statusCode}';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Impact Service Error: $e');
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}

