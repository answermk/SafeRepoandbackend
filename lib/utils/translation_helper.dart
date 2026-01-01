import 'package:flutter/material.dart';
import 'package:safereport_mobo/l10n/app_localizations.dart';

/// Translation Helper
/// Provides easy access to translations throughout the app
class TranslationHelper {
  /// Get AppLocalizations instance (non-null)
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
  
  /// Get translation with null safety
  static String translate(BuildContext context, String Function(AppLocalizations) getter) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Fallback to English key if localization is not available
      return '';
    }
    return getter(localizations);
  }
  
  /// Get current locale
  static Locale? getCurrentLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }
  
  /// Check if current language is RTL
  static bool isRTL(BuildContext context) {
    final locale = getCurrentLocale(context);
    if (locale == null) return false;
    // Add RTL languages here if needed (e.g., Arabic, Hebrew)
    return false;
  }
}

