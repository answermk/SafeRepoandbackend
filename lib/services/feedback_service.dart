import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Feedback Service
/// Handles feedback submission and retrieval
class FeedbackService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Submit feedback
  /// Backend: POST /api/feedback
  static Future<Map<String, dynamic>> submitFeedback(String message) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
        }),
      );
      
      if (response.statusCode == 201) {
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
  
  /// Get user's feedbacks
  /// Backend: GET /api/feedback/my-feedbacks
  static Future<Map<String, dynamic>> getMyFeedbacks({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/feedback/my-feedbacks?page=$page&size=$size'),
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

