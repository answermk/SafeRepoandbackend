import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import 'user_service.dart';
import 'token_manager.dart';

/// Language Service
/// Handles language preference storage and synchronization with backend
class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';

  /// Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'fr': 'French',
    'rw': 'Kinyarwanda',
    'sw': 'Swahili',
    'es': 'Spanish',
  };

  /// Get saved language preference
  static Future<String> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? _defaultLanguage;
    } catch (e) {
      print('Error getting saved language: $e');
      return _defaultLanguage;
    }
  }

  /// Save language preference locally
  static Future<bool> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      return true;
    } catch (e) {
      print('Error saving language: $e');
      return false;
    }
  }

  /// Save language preference and sync with backend
  static Future<Map<String, dynamic>> saveLanguageWithSync(String languageCode) async {
    try {
      // Save locally first
      final saved = await saveLanguage(languageCode);
      if (!saved) {
        return {
          'success': false,
          'error': 'Failed to save language locally',
        };
      }

      // Try to sync with backend (optional - if user is logged in)
      // Note: Backend may not have language field yet, so this is optional
      // If backend adds 'preferredLanguage' to UpdateUserRequest, uncomment below:
      /*
      final userId = await TokenManager.getUserId();
      if (userId != null) {
        try {
          // Update user profile with language preference
          // This requires backend to support 'preferredLanguage' in UpdateUserRequest
          final result = await UserService.updateUserProfile(
            userId: userId,
            preferredLanguage: languageCode, // Add this parameter to UserService
          );

          if (result['success'] == true) {
            return {
              'success': true,
              'message': 'Language preference saved and synced',
            };
          }
        } catch (e) {
          // If backend sync fails, still return success since local save worked
          print('Backend sync failed, but local save succeeded: $e');
        }
      }
      */

      return {
        'success': true,
        'message': 'Language preference saved',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error saving language: ${e.toString()}',
      };
    }
  }

  /// Get language display name
  static String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? languageCode.toUpperCase();
  }

  /// Get all supported languages
  static Map<String, String> getAllLanguages() {
    return supportedLanguages;
  }

  /// Check if language is supported
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }

  /// Get language code from display name
  static String? getLanguageCode(String displayName) {
    for (var entry in supportedLanguages.entries) {
      if (entry.value == displayName) {
        return entry.key;
      }
    }
    return null;
  }

  /// Clear saved language (reset to default)
  static Future<void> clearLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
    } catch (e) {
      print('Error clearing language: $e');
    }
  }
}

