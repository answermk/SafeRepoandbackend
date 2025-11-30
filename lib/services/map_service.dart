import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// Map Service
/// Handles crime maps, heat maps, live incidents, and geographic analysis
class MapService {
  
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Generate comprehensive crime map
  /// Backend: POST /api/maps/generate
  static Future<Map<String, dynamic>> generateCrimeMap({
    String? timeRange,  // e.g., "7d", "30d", "1y"
    String? mapType,    // "heatmap", "points", "clusters"
    List<String>? crimeTypes,
    double? north,
    double? south,
    double? east,
    double? west,
    int? maxPoints,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (timeRange != null) requestBody['timeRange'] = timeRange;
      if (mapType != null) requestBody['mapType'] = mapType;
      if (crimeTypes != null) requestBody['crimeTypes'] = crimeTypes;
      if (north != null) requestBody['north'] = north;
      if (south != null) requestBody['south'] = south;
      if (east != null) requestBody['east'] = east;
      if (west != null) requestBody['west'] = west;
      if (maxPoints != null) requestBody['maxPoints'] = maxPoints;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/maps/generate'),
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
  
  /// Get crime heatmap
  /// Backend: POST /api/maps/heatmap
  static Future<Map<String, dynamic>> getHeatMap({
    String? timeRange,
    List<String>? crimeTypes,
    double? north,
    double? south,
    double? east,
    double? west,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (timeRange != null) requestBody['timeRange'] = timeRange;
      if (crimeTypes != null) requestBody['crimeTypes'] = crimeTypes;
      if (north != null) requestBody['north'] = north;
      if (south != null) requestBody['south'] = south;
      if (east != null) requestBody['east'] = east;
      if (west != null) requestBody['west'] = west;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/maps/heatmap'),
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
  
  /// Get crime clusters
  /// Backend: POST /api/maps/clusters
  static Future<Map<String, dynamic>> getCrimeClusters({
    String? timeRange,
    List<String>? crimeTypes,
    double? north,
    double? south,
    double? east,
    double? west,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final requestBody = <String, dynamic>{};
      if (timeRange != null) requestBody['timeRange'] = timeRange;
      if (crimeTypes != null) requestBody['crimeTypes'] = crimeTypes;
      if (north != null) requestBody['north'] = north;
      if (south != null) requestBody['south'] = south;
      if (east != null) requestBody['east'] = east;
      if (west != null) requestBody['west'] = west;
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/maps/clusters'),
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
  
  /// Get live incidents
  /// Backend: GET /api/maps/live-incidents
  static Future<Map<String, dynamic>> getLiveIncidents() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/maps/live-incidents'),
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
  
  /// Get live incidents in area
  /// Backend: GET /api/maps/live-incidents/area?latitude={lat}&longitude={lon}&radiusKm={radius}
  static Future<Map<String, dynamic>> getLiveIncidentsInArea({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/maps/live-incidents/area').replace(
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
  
  /// Get quick crime map
  /// Backend: GET /api/maps/quick/{timeRange}
  static Future<Map<String, dynamic>> getQuickCrimeMap({
    required String timeRange,  // "7d", "30d", "1y"
    String mapType = 'heatmap',
    int maxPoints = 100,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/maps/quick/$timeRange').replace(
        queryParameters: {
          'mapType': mapType,
          'maxPoints': maxPoints.toString(),
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
  
  /// Get area statistics
  /// Backend: GET /api/maps/statistics/area
  static Future<Map<String, dynamic>> getAreaStatistics({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/maps/statistics/area').replace(
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
}

