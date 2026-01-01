import 'package:flutter/material.dart';

/// Theme Helper
/// Provides utility functions for theme-aware colors and styling
class ThemeHelper {
  /// Get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
  
  /// Get secondary text color (for subtitles, hints)
  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.grey[600]!;
  }
  
  /// Get tertiary text color (for less important text)
  static Color getTertiaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white60 
        : Colors.grey[500]!;
  }
  
  /// Get background color for cards/containers
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Primary color from theme
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  /// Get scaffold background color
  static Color getScaffoldBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Get icon color based on theme/iconTheme
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).iconTheme.color ??
        Theme.of(context).colorScheme.onSurface;
  }
  
  /// Get divider color
  static Color getDividerColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[700]! 
        : Colors.grey[300]!;
  }
  
  /// Get border color
  static Color getBorderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[700]! 
        : Colors.grey[300]!;
  }
  
  /// Check if dark mode is enabled
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get shadow color for cards
  static Color getShadowColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.black.withOpacity(0.3) 
        : Colors.grey.withOpacity(0.1);
  }
}

