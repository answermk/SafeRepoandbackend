import 'package:dio/dio.dart';

/// API Error Handler
/// Centralized error handling for API calls
class ApiErrorHandler {
  /// Get user-friendly error message from error
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return 'Unauthorized. Please login again.';
          } else if (error.response?.statusCode == 403) {
            return 'Access denied.';
          } else if (error.response?.statusCode == 404) {
            return 'Resource not found.';
          } else if (error.response?.statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          return 'Error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    
    if (error is Map && error.containsKey('error')) {
      return error['error'] as String;
    }
    
    return 'An unexpected error occurred.';
  }
  
  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return false;
  }
  
  /// Check if error is authentication related
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401 ||
          error.response?.statusCode == 403;
    }
    return false;
  }
}

