import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Forum Service
/// Handles forum posts and replies
class ForumService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get all forum posts
  /// Backend: GET /api/forum/posts
  static Future<Map<String, dynamic>> getAllPosts({
    int page = 0,
    int size = 50,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? priority,
    String? status,
    String? category,
    String? location,
    String? search,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDir': sortDir,
      };
      
      if (priority != null) queryParams['priority'] = priority;
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (search != null) queryParams['search'] = search;
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/forum/posts').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['content'],
          'totalPages': data['totalPages'],
          'totalElements': data['totalElements'],
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
  
  /// Get forum post by ID
  /// Backend: GET /api/forum/posts/{postId}
  static Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/forum/posts/$postId'),
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
  
  /// Create forum post
  /// Backend: POST /api/forum/posts
  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    String? category,
    String? priority,
    String? location,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{
        'title': title,
        'content': content,
      };
      
      if (category != null) requestBody['category'] = category;
      if (priority != null) requestBody['priority'] = priority;
      if (location != null) requestBody['location'] = location;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/forum/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to create post';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 
                        errorData['message'] ?? 
                        errorData.toString();
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
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Add reply to post
  /// Backend: POST /api/forum/posts/{postId}/replies
  static Future<Map<String, dynamic>> addReply({
    required String postId,
    required String content,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/forum/posts/$postId/replies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to add reply';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 
                        errorData['message'] ?? 
                        errorData.toString();
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
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Update forum post
  /// Backend: PUT /api/forum/posts/{postId}
  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    String? title,
    String? content,
    String? category,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (content != null) requestBody['content'] = content;
      if (category != null) requestBody['category'] = category;
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/forum/posts/$postId'),
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
  
  /// Delete forum post
  /// Backend: DELETE /api/forum/posts/{postId}
  static Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/forum/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 204) {
        return {'success': true};
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
  
  /// Get post replies
  /// Backend: GET /api/forum/posts/{postId}/replies
  static Future<Map<String, dynamic>> getPostReplies({
    required String postId,
    int page = 0,
    int size = 100,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/forum/posts/$postId/replies').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data is List ? data : data['content'] ?? [],
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

