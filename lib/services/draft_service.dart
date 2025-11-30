import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing report drafts locally using SharedPreferences
/// This handles saving, loading, and clearing drafts without backend dependency
class DraftService {
  static const String _draftKey = 'report_draft';
  static const String _draftTimestampKey = 'report_draft_timestamp';

  /// Save a draft report to local storage
  /// 
  /// Example draft data structure:
  /// {
  ///   'incidentType': 'suspicious_person',
  ///   'description': 'Saw someone...',
  ///   'evidence': ['photo', 'video'],
  ///   'mediaPaths': ['/path/to/photo.jpg'],
  ///   'submitAnonymously': true,
  /// }
  static Future<bool> saveDraft(Map<String, dynamic> draftData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert draft data to JSON string
      final draftJson = jsonEncode(draftData);
      
      // Save draft and timestamp
      final saved = await prefs.setString(_draftKey, draftJson);
      await prefs.setString(_draftTimestampKey, DateTime.now().toIso8601String());
      
      print('✅ Draft saved successfully: ${draftData['incidentType'] ?? 'No type'}');
      return saved;
    } catch (e) {
      print('❌ Error saving draft: $e');
      return false;
    }
  }

  /// Load the saved draft from local storage
  /// Returns null if no draft exists
  static Future<Map<String, dynamic>?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString(_draftKey);
      
      if (draftJson == null || draftJson.isEmpty) {
        print('ℹ️ No draft found');
        return null;
      }
      
      // Parse JSON string back to Map
      final draftData = jsonDecode(draftJson) as Map<String, dynamic>;
      
      // Get timestamp
      final timestampStr = prefs.getString(_draftTimestampKey);
      if (timestampStr != null) {
        draftData['_savedAt'] = timestampStr;
      }
      
      print('✅ Draft loaded: ${draftData['incidentType'] ?? 'No type'}');
      return draftData;
    } catch (e) {
      print('❌ Error loading draft: $e');
      return null;
    }
  }

  /// Check if a draft exists
  static Future<bool> hasDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_draftKey);
    } catch (e) {
      print('❌ Error checking draft: $e');
      return false;
    }
  }

  /// Get the timestamp when the draft was last saved
  static Future<DateTime?> getDraftTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_draftTimestampKey);
      
      if (timestampStr == null) return null;
      
      return DateTime.parse(timestampStr);
    } catch (e) {
      print('❌ Error getting draft timestamp: $e');
      return null;
    }
  }

  /// Clear/delete the saved draft
  static Future<bool> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final removed = await prefs.remove(_draftKey);
      await prefs.remove(_draftTimestampKey);
      
      print('✅ Draft cleared successfully');
      return removed;
    } catch (e) {
      print('❌ Error clearing draft: $e');
      return false;
    }
  }

  /// Get formatted time string for display (e.g., "Saved 2 minutes ago")
  static String getFormattedTimeAgo(DateTime? savedAt) {
    if (savedAt == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(savedAt);
    
    if (difference.inDays > 0) {
      return 'Saved ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return 'Saved ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return 'Saved ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Saved just now';
    }
  }
}

