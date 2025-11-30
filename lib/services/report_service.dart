import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/app_config.dart';
import 'api_client.dart';
import 'token_manager.dart';

/// Report Service
/// Handles report creation, retrieval, updates, and deletion
class ReportService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Create a new report
  /// Backend: POST /api/reports
  /// Supports both JSON (no files) and multipart/form-data (with files)
  static Future<Map<String, dynamic>> createReport({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    bool isAnonymous = false,
    String? priority,
    List<File>? mediaFiles,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      // If no files, use JSON request
      if (mediaFiles == null || mediaFiles.isEmpty) {
        final response = await http.post(
          Uri.parse('${AppConfig.apiBaseUrl}/reports'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'incidentType': incidentType,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            if (address != null) 'address': address,
            'isAnonymous': isAnonymous,
            if (priority != null) 'priority': priority,
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
      }
      
      // If files exist, use multipart request
      var request = http.MultipartRequest('POST', Uri.parse('${AppConfig.apiBaseUrl}/reports'));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add JSON data as a part
      request.fields['request'] = jsonEncode({
        'incidentType': incidentType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        'isAnonymous': isAnonymous,
        if (priority != null) 'priority': priority,
      });
      
      // Add files
      for (var file in mediaFiles) {
        var fileStream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'files',
          fileStream,
          length,
          filename: path.basename(file.path),
        );
        request.files.add(multipartFile);
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
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
  
  /// Get user's reports
  /// Backend: GET /api/reports/my-reports
  static Future<Map<String, dynamic>> getMyReports({
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/reports/my-reports').replace(
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
          'data': data['content'], // List of reports
          'totalPages': data['totalPages'],
          'totalElements': data['totalElements'],
          'currentPage': data['number'],
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
  
  /// Get report by ID
  /// Backend: GET /api/reports/{reportId}
  static Future<Map<String, dynamic>> getReport(String reportId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/reports/$reportId'),
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
  
  /// Delete report
  /// Backend: DELETE /api/reports/{reportId}
  static Future<Map<String, dynamic>> deleteReport(String reportId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/reports/$reportId'),
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

