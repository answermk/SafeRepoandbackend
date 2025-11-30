import 'package:shared_preferences/shared_preferences.dart';

/// Token Manager for storing and retrieving authentication tokens
class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';
  
  /// Save authentication token and user info
  static Future<void> saveToken({
    required String token,
    required String email,
    required String username,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_usernameKey, username);
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
  }
  
  /// Get stored authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// Get stored user email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
  
  /// Get stored username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }
  
  /// Get stored user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
  
  /// Clear all stored authentication data
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }
  
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

