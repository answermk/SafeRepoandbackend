import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safereport_mobo/l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../utils/language_controller.dart' as LangUtil;

/// Language Controller State
/// Manages language state and provides change notifications
class LanguageControllerState extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  bool _isLoading = false;

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;

  LanguageControllerState() {
    _initializeLanguage();
  }

  /// Initialize language from saved preference
  Future<void> _initializeLanguage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedLanguage = await LanguageService.getSavedLanguage();
      _currentLocale = LangUtil.LanguageController.getLocaleFromCode(savedLanguage);
    } catch (e) {
      print('Error initializing language: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change app language
  Future<Map<String, dynamic>> changeLanguage(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Save language preference
      final result = await LanguageService.saveLanguageWithSync(languageCode);

      if (result['success'] == true) {
        _currentLocale = LangUtil.LanguageController.getLocaleFromCode(languageCode);
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': 'Language changed successfully',
          'locale': _currentLocale,
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'error': 'Error changing language: ${e.toString()}',
      };
    }
  }

  /// Get current language code
  String getCurrentLanguageCode() {
    return LangUtil.LanguageController.getCodeFromLocale(_currentLocale);
  }

  /// Get current language name
  String getCurrentLanguageName() {
    return LanguageService.getLanguageName(getCurrentLanguageCode());
  }
}

