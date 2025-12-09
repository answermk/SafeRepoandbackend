import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Emergency Service
/// Handles emergency requests and police ETA
class EmergencyService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Create an emergency request
  /// Backend: POST /api/emergency/request
  static Future<Map<String, dynamic>> createEmergencyRequest({
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? emergencyType,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/emergency/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
          if (description != null) 'description': description,
          if (emergencyType != null) 'emergencyType': emergencyType,
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
  
  /// Get police ETA for a location
  /// Backend: GET /api/emergency/eta?latitude=...&longitude=...
  static Future<Map<String, dynamic>> getPoliceETA({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/emergency/eta').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
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
  
  /// Get emergency status
  /// Backend: GET /api/emergency/{emergencyId}/status
  static Future<Map<String, dynamic>> getEmergencyStatus(String emergencyId) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/emergency/$emergencyId/status'),
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

