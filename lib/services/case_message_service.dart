import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Case Message Service
/// Handles messages related to reports/cases
class CaseMessageService {
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Send case message
  /// Backend: POST /api/case-messages/send
  static Future<Map<String, dynamic>> sendCaseMessage({
    required String reportId,
    required String content,
    String? messageType,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{
        'reportId': reportId,
        'content': content,
      };
      if (messageType != null) requestBody['messageType'] = messageType;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/case-messages/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
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
  
  /// Get conversation for a report (paginated)
  /// Backend: GET /api/case-messages/conversation/{reportId}
  static Future<Map<String, dynamic>> getConversation({
    required String reportId,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDir = 'asc',
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/case-messages/conversation/$reportId').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          'sortBy': sortBy,
          'sortDir': sortDir,
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
  
  /// Get all conversation messages (no pagination)
  /// Backend: GET /api/case-messages/conversation/{reportId}/all
  static Future<Map<String, dynamic>> getConversationAll(String reportId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/case-messages/conversation/$reportId/all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data is List ? data : [data],
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
  
  /// Update case message
  /// Backend: PUT /api/case-messages/{messageId}
  static Future<Map<String, dynamic>> updateCaseMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/case-messages/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
        }),
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
  
  /// Delete case message
  /// Backend: DELETE /api/case-messages/{messageId}
  static Future<Map<String, dynamic>> deleteCaseMessage(String messageId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/case-messages/$messageId'),
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
}

