import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Article Service
/// Handles fetching educational articles from the backend
class ArticleService {
  /// Get featured articles
  /// Returns a map with 'success', 'data', and optionally 'error'
  static Future<Map<String, dynamic>> getFeaturedArticles() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication required. Please log in.',
        };
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/articles/featured');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📚 Featured Articles Response Status: ${response.statusCode}');
      print('📚 Featured Articles Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> articles = jsonDecode(response.body);
        return {
          'success': true,
          'data': articles,
        };
      } else {
        String errorMessage = 'Failed to load featured articles';
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
      print('❌ Article Service Error: $e');
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get article by ID
  static Future<Map<String, dynamic>> getArticleById(String articleId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication required. Please log in.',
        };
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/articles/$articleId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final article = jsonDecode(response.body);
        return {
          'success': true,
          'data': article,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load article',
        };
      }
    } catch (e) {
      print('❌ Article Service Error: $e');
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}

