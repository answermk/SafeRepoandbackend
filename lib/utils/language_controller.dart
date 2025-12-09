import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safereport_mobo/l10n/app_localizations.dart';
import '../services/language_service.dart';

/// Language Controller Utility
/// Manages app locale and provides helper methods
class LanguageController {
  /// Get Locale from language code
  static Locale getLocaleFromCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en');
      case 'fr':
        return const Locale('fr');
      case 'rw':
        return const Locale('rw');
      default:
        return const Locale('en');
    }
  }

  /// Get language code from Locale
  static String getCodeFromLocale(Locale locale) {
    return locale.languageCode;
  }

  /// Get supported locales list
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en'),
      Locale('fr'),
      Locale('rw'),
    ];
  }

  /// Get localization delegates
  static List<LocalizationsDelegate<dynamic>> getLocalizationDelegates() {
    return const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }

  /// Initialize and load saved language
  static Future<Locale> initializeLanguage() async {
    final savedLanguage = await LanguageService.getSavedLanguage();
    return getLocaleFromCode(savedLanguage);
  }

  /// Change app language
  static Future<Map<String, dynamic>> changeLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    try {
      // Save language preference
      final result = await LanguageService.saveLanguageWithSync(languageCode);

      if (result['success'] == true) {
        // Note: To actually change the language, you need to rebuild the MaterialApp
        // This is typically done by wrapping the app in a StatefulWidget or using
        // a state management solution like Provider/Riverpod
        return {
          'success': true,
          'message': 'Language changed successfully. Please restart the app.',
          'locale': getLocaleFromCode(languageCode),
        };
      } else {
        return result;
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error changing language: ${e.toString()}',
      };
    }
  }

  /// Get current language name
  static Future<String> getCurrentLanguageName() async {
    final code = await LanguageService.getSavedLanguage();
    return LanguageService.getLanguageName(code);
  }

  /// Get current language code
  static Future<String> getCurrentLanguageCode() async {
    return await LanguageService.getSavedLanguage();
  }

  /// Check if RTL language
  static bool isRTL(Locale locale) {
    // Add RTL languages here if needed (e.g., Arabic, Hebrew)
    return false;
  }
}

