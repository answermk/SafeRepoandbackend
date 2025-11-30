import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/app_config.dart';
import 'token_manager.dart';

/// File Upload Service
/// Handles file uploads (images, documents, etc.)
class FileUploadService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Upload a file
  /// Backend: POST /api/upload
  /// Supports: images, PDF, Word documents (max 10MB)
  static Future<Map<String, dynamic>> uploadFile(File file) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      // Check file size (10MB limit)
      final fileSize = await file.length();
      if (fileSize > AppConfig.maxFileSize) {
        return {
          'success': false,
          'error': 'File size exceeds ${AppConfig.maxFileSize ~/ (1024 * 1024)}MB limit',
        };
      }
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      
      var fileStream = http.ByteStream(file.openRead());
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileSize,
        filename: path.basename(file.path),
      );
      
      request.files.add(multipartFile);
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'url': data['url'],
          'path': data['path'],
          'fileName': data['fileName'],
          'fileSize': data['fileSize'],
          'contentType': data['contentType'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Upload multiple files
  static Future<Map<String, dynamic>> uploadFiles(List<File> files) async {
    try {
      final results = <Map<String, dynamic>>[];
      final errors = <String>[];
      
      for (var file in files) {
        final result = await uploadFile(file);
        if (result['success'] == true) {
          results.add(result);
        } else {
          errors.add(result['error'] ?? 'Upload failed');
        }
      }
      
      return {
        'success': errors.isEmpty,
        'results': results,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Download file
  /// Backend: GET /api/files/{filePath}
  /// Example: /api/files/2025/11/filename.jpg
  static Future<Map<String, dynamic>> downloadFile(String filePath) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      // Remove leading slash if present
      final cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/files/$cleanPath'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.bodyBytes,
          'contentType': response.headers['content-type'],
        };
      } else {
        return {
          'success': false,
          'error': 'File not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Get file URL
  /// Constructs the full URL for a file path
  static String getFileUrl(String filePath) {
    // Remove leading slash if present
    final cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    return '${AppConfig.apiBaseUrl}/files/$cleanPath';
  }
}

