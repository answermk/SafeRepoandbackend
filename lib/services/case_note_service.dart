import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Case Note Service
/// Handles case notes on reports (mainly for viewing notes on own reports)
class CaseNoteService {
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get notes for a report
  /// Backend: GET /api/reports/{reportId}/notes
  /// Note: Citizens can view notes on their own reports
  static Future<Map<String, dynamic>> getNotesByReport(String reportId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/reports/$reportId/notes'),
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
  
  /// Get note by ID
  /// Backend: GET /api/notes/{noteId}
  static Future<Map<String, dynamic>> getNoteById(String noteId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/notes/$noteId'),
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
  
  /// Create case note (Police/Admin only - but included for completeness)
  /// Backend: POST /api/reports/{reportId}/notes
  /// Note: This requires POLICE_OFFICER, OFFICER, or ADMIN role
  static Future<Map<String, dynamic>> createNote({
    required String reportId,
    required String note,
    String? noteType,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{
        'note': note,
      };
      if (noteType != null) requestBody['noteType'] = noteType;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/reports/$reportId/notes'),
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
  
  /// Update case note (Police/Admin only)
  /// Backend: PUT /api/notes/{noteId}
  static Future<Map<String, dynamic>> updateNote({
    required String noteId,
    required String note,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/notes/$noteId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'note': note,
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
  
  /// Delete case note (Police/Admin only)
  /// Backend: DELETE /api/notes/{noteId}
  static Future<Map<String, dynamic>> deleteNote(String noteId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/notes/$noteId'),
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

