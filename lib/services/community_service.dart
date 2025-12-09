import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Community Service
/// Handles community statistics and status based on location
class CommunityService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get community status based on user's location
  /// Backend: GET /api/community/status?latitude=...&longitude=...&radiusKm=...
  static Future<Map<String, dynamic>> getCommunityStatus({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0, // Default 5km radius
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/community/status').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radiusKm': radiusKm.toString(),
        },
      );
      
      final response = await http.get(
        uri,
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
  
  /// Get top active areas based on user's location
  /// Backend: GET /api/community/top-areas?latitude=...&longitude=...&radiusKm=...&limit=...
  static Future<Map<String, dynamic>> getTopActiveAreas({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0, // Default 5km radius
    int limit = 5, // Default top 5 areas
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/community/top-areas').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radiusKm': radiusKm.toString(),
          'limit': limit.toString(),
        },
      );
      
      final response = await http.get(
        uri,
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

