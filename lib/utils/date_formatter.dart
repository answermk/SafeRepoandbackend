import 'package:intl/intl.dart';

/// Date Formatter Utility
/// Helper functions for formatting dates and times
class DateFormatter {
  /// Format date as "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date and time as "Jan 15, 2024 at 10:30 AM"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(date);
  }

  /// Format time as "10:30 AM"
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "3 days ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format ISO string to DateTime
  static DateTime? parseISO(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// Format date for API (ISO 8601)
  static String formatForAPI(DateTime date) {
    return date.toIso8601String();
  }
}

