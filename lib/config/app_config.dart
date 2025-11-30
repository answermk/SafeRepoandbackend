/// Application Configuration
/// Contains all app-wide configuration constants
class AppConfig {
  // Backend API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const String productionUrl = 'https://api.saferreport.com/api';
  
  // Environment
  static const bool isProduction = false; // Change to true in production
  
  // Get current base URL based on environment
  static String get apiBaseUrl => isProduction ? productionUrl : baseUrl;
  
  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'image/jpeg',
    'image/png',
    'image/jpg',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];
  
  // Pagination Defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Map Configuration
  static const double defaultMapZoom = 12.0;
  static const double defaultSearchRadius = 1000.0; // meters
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  
  // Notification Configuration
  static const int maxNotificationRetries = 3;
}

