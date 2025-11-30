import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Watch Group Service
/// Handles watch group operations
class WatchGroupService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get user's watch groups
  /// Backend: GET /api/watch-groups/my-groups
  static Future<Map<String, dynamic>> getMyWatchGroups({
    int page = 0,
    int size = 100,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/watch-groups/my-groups').replace(
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
  
  /// Get all watch groups (for searching/browsing)
  /// Backend: GET /api/watch-groups
  static Future<Map<String, dynamic>> getAllWatchGroups({
    int page = 0,
    int size = 50,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    double? latitude,
    double? longitude,
    double? radius,
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
      
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/watch-groups').replace(
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
  
  /// Get watch group by ID
  /// Backend: GET /api/watch-groups/{id}
  static Future<Map<String, dynamic>> getWatchGroupById(String groupId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/watch-groups/$groupId'),
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
  
  /// Create watch group
  /// Backend: POST /api/watch-groups
  static Future<Map<String, dynamic>> createWatchGroup({
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{
        'name': name,
      };
      if (description != null) requestBody['description'] = description;
      if (latitude != null) requestBody['latitude'] = latitude;
      if (longitude != null) requestBody['longitude'] = longitude;
      if (address != null) requestBody['address'] = address;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/watch-groups'),
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
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to create watch group',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  /// Join watch group
  /// Backend: POST /api/watch-groups/{id}/members
  static Future<Map<String, dynamic>> joinWatchGroup(String groupId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/watch-groups/$groupId/members'),
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
  
  /// Leave watch group
  /// Backend: DELETE /api/watch-groups/{id}/members/{userId}
  static Future<Map<String, dynamic>> leaveWatchGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/watch-groups/$groupId/members/$userId'),
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

