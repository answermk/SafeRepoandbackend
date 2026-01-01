import '../config/app_config.dart';
import 'api_client.dart';
import 'api_error_handler.dart';
import 'token_manager.dart';
import 'package:dio/dio.dart';

/// Video Tutorial Service
/// Handles fetching video tutorials from the backend
class VideoTutorialService {
  static Future<String?> getAuthToken() async {
    return await TokenManager.getToken();
  }
  
  /// Get all active video tutorials
  /// Backend: GET /api/video-tutorials
  static Future<Map<String, dynamic>> getAllVideos() async {
    try {
      final response = await ApiClient.dio.get('/video-tutorials');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  /// Get featured video tutorials
  /// Backend: GET /api/video-tutorials/featured
  static Future<Map<String, dynamic>> getFeaturedVideos() async {
    try {
      final response = await ApiClient.dio.get('/video-tutorials/featured');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  /// Get videos by category
  /// Backend: GET /api/video-tutorials/category/{category}
  static Future<Map<String, dynamic>> getVideosByCategory(String category) async {
    try {
      final response = await ApiClient.dio.get('/video-tutorials/category/$category');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  /// Get video by ID
  /// Backend: GET /api/video-tutorials/{id}
  static Future<Map<String, dynamic>> getVideoById(String id) async {
    try {
      final response = await ApiClient.dio.get('/video-tutorials/$id');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  /// Increment video views
  /// Backend: PUT /api/video-tutorials/{id}/views
  static Future<Map<String, dynamic>> incrementViews(String id) async {
    try {
      final response = await ApiClient.dio.put('/video-tutorials/$id/views');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
}

