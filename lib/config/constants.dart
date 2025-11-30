/// Application Constants
/// Contains all constant values used throughout the app
class AppConstants {
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String emailKey = 'user_email';
  static const String usernameKey = 'username';
  static const String userIdKey = 'user_id';
  static const String draftKey = 'report_draft';
  static const String offlineReportsKey = 'offline_reports';
  static const String accessibilitySettingsKey = 'accessibility_settings';
  
  // Report Status
  static const String reportStatusSubmitted = 'SUBMITTED';
  static const String reportStatusReviewing = 'REVIEWING';
  static const String reportStatusResolved = 'RESOLVED';
  static const String reportStatusClosed = 'CLOSED';
  
  // Report Priority
  static const String priorityLow = 'LOW';
  static const String priorityNormal = 'NORMAL';
  static const String priorityHigh = 'HIGH';
  static const String priorityUrgent = 'URGENT';
  
  // Incident Types
  static const List<String> incidentTypes = [
    'Theft',
    'Vandalism',
    'Suspicious Person',
    'Vehicle Activity',
    'Drug Activity',
    'Assault',
    'Burglary',
    'Other',
  ];
  
  // User Roles
  static const String roleCivilian = 'CIVILIAN';
  static const String rolePolice = 'POLICE_OFFICER';
  static const String roleOfficer = 'OFFICER';
  static const String roleAdmin = 'ADMIN';
  
  // Notification Types
  static const String notificationTypeMessage = 'MESSAGE';
  static const String notificationTypeCase = 'CASE';
  static const String notificationTypeGroup = 'GROUP';
  static const String notificationTypeSystem = 'SYSTEM';
  
  // Time Ranges for Maps
  static const String timeRangeWeek = '7d';
  static const String timeRangeMonth = '30d';
  static const String timeRangeYear = '1y';
  
  // Map Types
  static const String mapTypeHeatmap = 'heatmap';
  static const String mapTypePoints = 'points';
  static const String mapTypeClusters = 'clusters';
}

