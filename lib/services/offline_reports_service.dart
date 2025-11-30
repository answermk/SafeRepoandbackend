import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing offline reports queue
/// Handles saving, loading, and syncing reports when offline
class OfflineReportsService {
  static const String _queueKey = 'offline_reports_queue';

  /// Add a report to the offline queue
  /// This is called when a report is submitted while offline
  static Future<bool> addToQueue(Map<String, dynamic> reportData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Generate unique ID if not present
      if (!reportData.containsKey('id') || reportData['id'] == null) {
        reportData['id'] = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Set initial status
      reportData['status'] = 'pending';
      reportData['timestamp'] = DateTime.now().toIso8601String();
      reportData['retryCount'] = 0;
      
      // Load existing queue
      final existingQueue = await getQueue();
      
      // Add new report
      existingQueue.add(reportData);
      
      // Save back to storage
      final queueJson = jsonEncode(existingQueue);
      final saved = await prefs.setString(_queueKey, queueJson);
      
      print('✅ Report added to offline queue: ${reportData['id']}');
      return saved;
    } catch (e) {
      print('❌ Error adding to queue: $e');
      return false;
    }
  }

  /// Get all reports in the queue
  static Future<List<Map<String, dynamic>>> getQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      
      if (queueJson == null || queueJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> queueList = jsonDecode(queueJson);
      return queueList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error loading queue: $e');
      return [];
    }
  }

  /// Get reports by status
  static Future<List<Map<String, dynamic>>> getQueueByStatus(String status) async {
    final queue = await getQueue();
    return queue.where((report) => report['status'] == status).toList();
  }

  /// Update a report in the queue
  static Future<bool> updateReport(String reportId, Map<String, dynamic> updates) async {
    try {
      final queue = await getQueue();
      final index = queue.indexWhere((r) => r['id'] == reportId);
      
      if (index == -1) {
        print('⚠️ Report not found in queue: $reportId');
        return false;
      }
      
      // Merge updates
      queue[index] = {...queue[index], ...updates};
      
      // Save back
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(queue);
      await prefs.setString(_queueKey, queueJson);
      
      print('✅ Report updated in queue: $reportId');
      return true;
    } catch (e) {
      print('❌ Error updating report: $e');
      return false;
    }
  }

  /// Mark a report as synced (successfully uploaded)
  static Future<bool> markAsSynced(String reportId) async {
    return await updateReport(reportId, {
      'status': 'synced',
      'syncedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Mark a report as failed
  static Future<bool> markAsFailed(String reportId, String errorMessage) async {
    final queue = await getQueue();
    final report = queue.firstWhere((r) => r['id'] == reportId, orElse: () => {});
    
    final retryCount = (report['retryCount'] ?? 0) + 1;
    
    return await updateReport(reportId, {
      'status': 'failed',
      'errorMessage': errorMessage,
      'retryCount': retryCount,
      'lastRetryAt': DateTime.now().toIso8601String(),
    });
  }

  /// Remove a report from the queue
  static Future<bool> removeFromQueue(String reportId) async {
    try {
      final queue = await getQueue();
      queue.removeWhere((r) => r['id'] == reportId);
      
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(queue);
      await prefs.setString(_queueKey, queueJson);
      
      print('✅ Report removed from queue: $reportId');
      return true;
    } catch (e) {
      print('❌ Error removing from queue: $e');
      return false;
    }
  }

  /// Clear all synced reports (cleanup)
  static Future<bool> clearSyncedReports() async {
    try {
      final queue = await getQueue();
      final pendingQueue = queue.where((r) => r['status'] != 'synced').toList();
      
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(pendingQueue);
      await prefs.setString(_queueKey, queueJson);
      
      print('✅ Synced reports cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing synced reports: $e');
      return false;
    }
  }

  /// Get queue statistics
  static Future<Map<String, int>> getQueueStats() async {
    final queue = await getQueue();
    return {
      'total': queue.length,
      'pending': queue.where((r) => r['status'] == 'pending').length,
      'failed': queue.where((r) => r['status'] == 'failed').length,
      'synced': queue.where((r) => r['status'] == 'synced').length,
    };
  }

  /// Check if there are any pending reports
  static Future<bool> hasPendingReports() async {
    final queue = await getQueue();
    return queue.any((r) => r['status'] == 'pending' || r['status'] == 'failed');
  }
}

