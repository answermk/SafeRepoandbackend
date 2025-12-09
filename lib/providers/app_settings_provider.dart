import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/language_controller.dart';
import '../services/language_service.dart';

/// App Settings Provider
/// Manages theme, font size, and language settings app-wide
class AppSettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'app_font_size';
  static const String _darkModeKey = 'app_dark_mode';
  static const String _languageKey = 'app_language';
  
  // Default values
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  
  // Getters
  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  double get fontScale => _fontSize / 16.0; // Scale factor based on default 16
  
  AppSettingsProvider() {
    _loadSettings();
  }
  
  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load font size
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;
      
      // Load dark mode
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      
      // Load language (use LanguageService to get the saved language)
      final languageCode = await LanguageService.getSavedLanguage();
      _locale = LanguageController.getLocaleFromCode(languageCode);
      
      notifyListeners();
    } catch (e) {
      print('Error loading app settings: $e');
    }
  }
  
  /// Update font size
  Future<void> setFontSize(double size) async {
    if (size < 12 || size > 28) return; // Validate range
    
    _fontSize = size;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, size);
    } catch (e) {
      print('Error saving font size: $e');
    }
  }
  
  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      print('Error saving dark mode: $e');
    }
  }
  
  /// Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      print('Error saving dark mode: $e');
    }
  }
  
  /// Update language
  Future<void> setLanguage(String languageCode) async {
    _locale = LanguageController.getLocaleFromCode(languageCode);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      // Also save to LanguageService for compatibility
      await LanguageController.changeLanguage(
        // We don't have context here, but LanguageService handles it
        null as BuildContext,
        languageCode,
      );
    } catch (e) {
      print('Error saving language: $e');
    }
  }
  
  /// Get theme data based on current settings
  ThemeData getThemeData() {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    return baseTheme.copyWith(
      // Primary color
      primaryColor: const Color(0xFF36599F),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: const Color(0xFF36599F),
        secondary: const Color(0xFF5D80C1),
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: _fontSize + 4,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Text theme with font scaling
      textTheme: baseTheme.textTheme.copyWith(
        displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
          fontSize: (baseTheme.textTheme.displayLarge?.fontSize ?? 32) * fontScale,
        ),
        displayMedium: baseTheme.textTheme.displayMedium?.copyWith(
          fontSize: (baseTheme.textTheme.displayMedium?.fontSize ?? 28) * fontScale,
        ),
        displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
          fontSize: (baseTheme.textTheme.displaySmall?.fontSize ?? 24) * fontScale,
        ),
        headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
          fontSize: (baseTheme.textTheme.headlineLarge?.fontSize ?? 22) * fontScale,
        ),
        headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
          fontSize: (baseTheme.textTheme.headlineMedium?.fontSize ?? 20) * fontScale,
        ),
        headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
          fontSize: (baseTheme.textTheme.headlineSmall?.fontSize ?? 18) * fontScale,
        ),
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontSize: (baseTheme.textTheme.titleLarge?.fontSize ?? 16) * fontScale,
        ),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
          fontSize: (baseTheme.textTheme.titleMedium?.fontSize ?? 14) * fontScale,
        ),
        titleSmall: baseTheme.textTheme.titleSmall?.copyWith(
          fontSize: (baseTheme.textTheme.titleSmall?.fontSize ?? 12) * fontScale,
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: (baseTheme.textTheme.bodyLarge?.fontSize ?? 16) * fontScale,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          fontSize: (baseTheme.textTheme.bodyMedium?.fontSize ?? 14) * fontScale,
        ),
        bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
          fontSize: (baseTheme.textTheme.bodySmall?.fontSize ?? 12) * fontScale,
        ),
        labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
          fontSize: (baseTheme.textTheme.labelLarge?.fontSize ?? 14) * fontScale,
        ),
        labelMedium: baseTheme.textTheme.labelMedium?.copyWith(
          fontSize: (baseTheme.textTheme.labelMedium?.fontSize ?? 12) * fontScale,
        ),
        labelSmall: baseTheme.textTheme.labelSmall?.copyWith(
          fontSize: (baseTheme.textTheme.labelSmall?.fontSize ?? 10) * fontScale,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF36599F),
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24 * fontScale,
            vertical: 12 * fontScale,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * fontScale,
          vertical: 12 * fontScale,
        ),
        labelStyle: TextStyle(fontSize: fontSize),
        hintStyle: TextStyle(fontSize: fontSize),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        margin: EdgeInsets.all(8 * fontScale),
      ),
    );
  }
}

