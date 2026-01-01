import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/app_config.dart';
import 'api_client.dart';
import 'token_manager.dart';
import 'offline_reports_service.dart';

/// Report Service
/// Handles report creation, retrieval, updates, and deletion
class ReportService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Maps frontend incident types to backend CrimeType enum values
  static String _mapIncidentTypeToCrimeType(String incidentType) {
    // Convert to lowercase for case-insensitive matching
    final lowerType = incidentType.toLowerCase().replaceAll('_', '_');
    
    // Map frontend incident types to backend CrimeType enum
    final Map<String, String> typeMapping = {
      'suspicious_person': 'OTHER', // Backend doesn't have SUSPICIOUS_PERSON
      'vehicle_activity': 'TRAFFIC_VIOLATION',
      'abandoned_item': 'OTHER',
      'theft': 'THEFT',
      'vandalism': 'VANDALISM',
      'drug_activity': 'DRUG_OFFENSE',
      'assault': 'ASSAULT',
      'noise': 'PUBLIC_DISORDER',
      'trespassing': 'TRESPASSING',
      'other': 'OTHER',
      'burglary': 'BURGLARY',
      'robbery': 'ROBBERY',
      'fraud': 'FRAUD',
      'cybercrime': 'CYBERCRIME',
      'domestic_violence': 'DOMESTIC_VIOLENCE',
      'sexual_assault': 'SEXUAL_ASSAULT',
      'harassment': 'HARASSMENT',
      'weapon_offense': 'WEAPON_OFFENSE',
      'arson': 'ARSON',
      'murder': 'MURDER',
      'kidnapping': 'KIDNAPPING',
    };
    
    // Return mapped type or default to OTHER
    return typeMapping[lowerType] ?? 'OTHER';
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
        // Map incidentType to title (use incidentType as title for now)
        final title = incidentType.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
        
        // Send location coordinates directly to backend
        final response = await http.post(
          Uri.parse('${AppConfig.apiBaseUrl}/reports'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'title': title,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            if (address != null) 'address': address,
            'crimeType': _mapIncidentTypeToCrimeType(incidentType), // Map to backend enum
            'isAnonymous': isAnonymous,
          }),
        );
        
        if (response.statusCode == 201) {
          return {
            'success': true,
            'data': jsonDecode(response.body),
          };
        } else {
          // If request failed, try to add to offline queue
          final queueData = {
            'incidentType': incidentType,
            'incidentTitle': title,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'submitAnonymously': isAnonymous,
            'isAnonymous': isAnonymous,
            'mediaPaths': mediaFiles?.map((f) => f.path).toList() ?? [],
          };
          
          await OfflineReportsService.addToQueue(queueData);
          
          return {
            'success': false,
            'error': response.body,
            'queued': true,
          };
        }
      }
      
      // If files exist, use multipart request
      var request = http.MultipartRequest('POST', Uri.parse('${AppConfig.apiBaseUrl}/reports'));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Map incidentType to title (use incidentType as title for now)
      final title = incidentType.replaceAll('_', ' ').split(' ').map((word) => 
        word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
      ).join(' ');
      
      // Create JSON request body
      final requestJson = jsonEncode({
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        'crimeType': _mapIncidentTypeToCrimeType(incidentType), // Map to backend enum
        'isAnonymous': isAnonymous,
      });
      
      // Add JSON data as a multipart part with proper content type
      // Spring Boot's @RequestPart expects the part to have Content-Type: application/json
      final jsonBytes = utf8.encode(requestJson);
      final jsonPart = http.MultipartFile.fromBytes(
        'request',
        jsonBytes,
        filename: 'request.json',
        contentType: http.MediaType('application', 'json'),
      );
      request.files.add(jsonPart);
      
      // Add evidence files
      for (var file in mediaFiles) {
        var fileStream = http.ByteStream(file.openRead());
        var length = await file.length();
        
        // Determine content type from file extension
        final fileExtension = path.extension(file.path).toLowerCase();
        String? contentType;
        if (['.jpg', '.jpeg'].contains(fileExtension)) {
          contentType = 'image/jpeg';
        } else if (fileExtension == '.png') {
          contentType = 'image/png';
        } else if (['.mp4', '.mov'].contains(fileExtension)) {
          contentType = 'video/mp4';
        } else if (fileExtension == '.pdf') {
          contentType = 'application/pdf';
        }
        
        var multipartFile = http.MultipartFile(
          'files',
          fileStream,
          length,
          filename: path.basename(file.path),
          contentType: contentType != null ? http.MediaType.parse(contentType) : null,
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
        // If request failed, try to add to offline queue
        final title = incidentType.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
        
        final queueData = {
          'incidentType': incidentType,
          'incidentTitle': title,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'submitAnonymously': isAnonymous,
          'isAnonymous': isAnonymous,
          'mediaPaths': mediaFiles?.map((f) => f.path).toList() ?? [],
        };
        
        await OfflineReportsService.addToQueue(queueData);
        
        return {
          'success': false,
          'error': response.body,
          'queued': true,
        };
      }
    } catch (e) {
      // Connection error - add to offline queue
      final title = incidentType.replaceAll('_', ' ').split(' ').map((word) => 
        word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
      ).join(' ');
      
      final queueData = {
        'incidentType': incidentType,
        'incidentTitle': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'submitAnonymously': isAnonymous,
        'isAnonymous': isAnonymous,
        'mediaPaths': mediaFiles?.map((f) => f.path).toList() ?? [],
      };
      
      await OfflineReportsService.addToQueue(queueData);
      
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'queued': true,
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

