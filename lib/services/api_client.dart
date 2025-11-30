import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'token_manager.dart';

/// Base API Client using Dio
/// Handles authentication, error handling, and base configuration
class ApiClient {
  static Dio? _dio;
  
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ));
      
      // Add interceptor for authentication
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token
            TokenManager.clearToken();
          }
          return handler.next(error);
        },
      ));
    }
    return _dio!;
  }
  
  /// Reset Dio instance (useful for testing or changing base URL)
  static void reset() {
    _dio = null;
  }
}

