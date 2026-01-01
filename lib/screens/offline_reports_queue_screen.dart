import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:io';
import '../services/offline_reports_service.dart';
import '../services/report_service.dart';

class OfflineReportsQueueScreen extends StatefulWidget {
  const OfflineReportsQueueScreen({Key? key}) : super(key: key);

  @override
  State<OfflineReportsQueueScreen> createState() => _OfflineReportsQueueScreenState();
}

class _OfflineReportsQueueScreenState extends State<OfflineReportsQueueScreen> {
  List<Map<String, dynamic>> _queuedReports = [];
  bool _isOnline = false;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadQueuedReports();
    _checkConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResults.isNotEmpty && 
                  connectivityResults.first != ConnectivityResult.none;
    });
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = !_isOnline;
      final isConnected = results.isNotEmpty && 
                          results.first != ConnectivityResult.none;
      
      setState(() {
        _isOnline = isConnected;
      });

      // Auto-sync when coming back online
      if (wasOffline && isConnected && _queuedReports.isNotEmpty) {
        _autoSyncAll();
      }
    });
  }

  Future<void> _loadQueuedReports() async {
    try {
      final queue = await OfflineReportsService.getQueue();
      if (mounted) {
        setState(() {
          _queuedReports = queue;
        });
      }
      print('✅ Loaded ${queue.length} reports from offline queue');
    } catch (e) {
      print('❌ Error loading queued reports: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading queue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncReport(String reportId) async {
    if (!_isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isSyncing = true);

    try {
      print('Syncing report: $reportId');
      
      // Get the report from queue
      final report = _queuedReports.firstWhere(
        (r) => r['id'] == reportId,
        orElse: () => {},
      );

      if (report.isEmpty) {
        throw Exception('Report not found in queue');
      }

      // Extract report data from queue
      final incidentType = report['incidentType'] as String? ?? 
                          report['crimeType'] as String? ?? 
                          'other';
      final description = report['description'] as String? ?? 
                         report['incidentTitle'] as String? ?? 
                         '';
      final latitude = (report['latitude'] ?? report['location']?['latitude'] ?? 0.0) as double;
      final longitude = (report['longitude'] ?? report['location']?['longitude'] ?? 0.0) as double;
      final address = report['address'] as String? ?? 
                     report['location']?['address'] as String?;
      final isAnonymous = report['submitAnonymously'] as bool? ?? 
                         report['isAnonymous'] as bool? ?? 
                         false;
      
      // Get media files if available
      List<File>? mediaFiles;
      if (report['mediaPaths'] != null) {
        final mediaPaths = report['mediaPaths'] as List<dynamic>;
        mediaFiles = mediaPaths
            .map((path) => path.toString())
            .where((path) => path.isNotEmpty)
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();
        
        if (mediaFiles.isEmpty) {
          mediaFiles = null;
        }
      }

      // Call actual backend API
      final result = await ReportService.createReport(
        incidentType: incidentType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        isAnonymous: isAnonymous,
        mediaFiles: mediaFiles,
      );
      
      final success = result['success'] == true;

      if (success) {
        // Mark as synced in local storage
        await OfflineReportsService.markAsSynced(reportId);
        
        // Reload queue to update UI
        await _loadQueuedReports();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report synced successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Backend returned error');
      }
    } catch (e) {
      // Mark as failed in local storage
      await OfflineReportsService.markAsFailed(reportId, e.toString());
      
      // Reload queue to update UI
      await _loadQueuedReports();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _autoSyncAll() async {
    if (!_isOnline || _queuedReports.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No reports to sync or offline'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isSyncing = true);

    final pendingReports = _queuedReports.where((r) => r['status'] != 'synced').toList();
    int successCount = 0;
    int failCount = 0;

    for (var report in pendingReports) {
      try {
        await _syncReport(report['id']);
        successCount++;
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        failCount++;
        print('Error syncing report ${report['id']}: $e');
      }
    }

    // Reload queue to get updated status
    await _loadQueuedReports();

    if (mounted) {
      setState(() => _isSyncing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync complete: $successCount succeeded, $failCount failed',
          ),
          backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteReport(String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this queued report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete from local storage
      final deleted = await OfflineReportsService.removeFromQueue(reportId);
      
      if (deleted) {
        // Reload queue to update UI
        await _loadQueuedReports();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete report'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editReport(Map<String, dynamic> report) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _queuedReports.where((r) => r['status'] == 'pending').length;
    final failedCount = _queuedReports.where((r) => r['status'] == 'failed').length;
    final syncedCount = _queuedReports.where((r) => r['status'] == 'synced').length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Offline Queue', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
        actions: [
          if (_queuedReports.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _isSyncing ? null : _autoSyncAll,
              tooltip: 'Sync All',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionStatus(),
          _buildStatsSummary(pendingCount, failedCount, syncedCount),
          const Divider(height: 1),
          Expanded(
            child: _queuedReports.isEmpty
                ? _buildEmptyState()
                : _buildReportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: _isOnline ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        child: Row(
          children: [
        Icon(
        _isOnline ? Icons.wifi : Icons.wifi_off,
          color: _isOnline ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                ),
              ),
              Text(
                _isOnline
                    ? 'Reports will sync automatically'
                    : 'Reports will be queued for upload',
                style: TextStyle(
                  fontSize: 12,
                  color: _isOnline ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
        ),
        if (_isSyncing)
    SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(
        _isOnline ? const Color(0xFF059669) : const Color(0xFFDC2626),
      ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildStatsSummary(int pending, int failed, int synced) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              pending.toString(),
              Colors.orange,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Failed',
              failed.toString(),
              Colors.red,
              Icons.error_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Synced',
              synced.toString(),
              Colors.green,
              Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_done,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'All Caught Up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No reports in offline queue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _queuedReports.length,
      itemBuilder: (context, index) {
        return _buildReportCard(_queuedReports[index]);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] as String;
    final timestamp = DateTime.parse(report['timestamp'] as String);
    final hasMedia = (report['mediaPaths'] as List).isNotEmpty;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Pending Upload';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Upload Failed';
        break;
      case 'synced':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Synced';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report['incidentTitle'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF36599F),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  report['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),

                // Metadata Row
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (hasMedia) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.attachment, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${(report['mediaPaths'] as List).length} file(s)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),

                // Error message if failed
                if (status == 'failed' && report['errorMessage'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            report['errorMessage'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((report['retryCount'] as int) > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Retry attempts: ${report['retryCount']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (status != 'synced') ...[
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _syncReport(report['id']),
                      icon: const Icon(Icons.sync, size: 18),
                      label: Text(status == 'failed' ? 'Retry' : 'Sync Now'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF36599F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _editReport(report),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _deleteReport(report['id']),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}