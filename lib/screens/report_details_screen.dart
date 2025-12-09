import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String? reportId;
  final Map<String, dynamic>? reportData;

  const ReportDetailsScreen({
    Key? key,
    this.reportId,
    this.reportData,
  }) : super(key: key);

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    // Use provided reportData or fetch from backend
    if (widget.reportData != null) {
      setState(() {
        _reportData = widget.reportData;
      });
      return;
    }

    if (widget.reportId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ReportService.getReport(widget.reportId!);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _reportData = result['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, y • h:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return DateFormat('MMM d, y').format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF36599F)),
        ),
      );
    }

    if (_reportData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Unable to load report details'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildStatusRow(),
              const SizedBox(height: 12),
              _buildIncidentInfo(),
              const SizedBox(height: 12),
              _buildEvidenceSection(),
              const SizedBox(height: 12),
              _buildStatusUpdates(),
              const SizedBox(height: 16),
              _buildAnonymousBadge(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF36599F),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Report #${widget.reportId ?? _reportData?['id'] ?? 'N/A'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final status = _reportData?['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final updatedAt = _reportData?['updatedAt']?.toString();
    
    Color statusColor;
    switch (status) {
      case 'PENDING':
      case 'SUBMITTED':
        statusColor = const Color(0xFFFDE68A);
        break;
      case 'IN_PROGRESS':
      case 'REVIEWING':
        statusColor = const Color(0xFF6CA6F7);
        break;
      case 'RESOLVED':
      case 'CLOSED':
        statusColor = const Color(0xFF86EFAC);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status.replaceAll('_', ' '),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          Text(
            updatedAt != null ? 'Updated ${_formatTimeAgo(updatedAt)}' : 'Updated: Unknown',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentInfo() {
    final title = _reportData?['title']?.toString() ?? 'Untitled Report';
    final description = _reportData?['description']?.toString() ?? 'No description provided';
    final location = _reportData?['location'] as Map<String, dynamic>?;
    final address = location?['address']?.toString() ?? 
                   location?['city']?.toString() ?? 
                   'Location not specified';
    final createdAt = _reportData?['createdAt']?.toString();
    final dateTime = createdAt != null ? _formatDate(createdAt) : 'Unknown';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Incident Information',
              style: TextStyle(
                color: Color(0xFF36599F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: title),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: address),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: dateTime),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: Row(
          children: const [
            Icon(Icons.camera_alt, color: Color(0xFF36599F), size: 28),
            SizedBox(width: 16),
            Icon(Icons.videocam, color: Color(0xFF36599F), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdates() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Updates',
              style: TextStyle(
                color: Color(0xFF36599F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Report Under Review\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '30 minutes ago\n'),
                  TextSpan(text: 'Officer Martinez has been assigned to investigate'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Report Received\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '2 hours ago\n'),
                  TextSpan(text: 'Your report has been logged and prioritized'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousBadge() {
    final isAnonymous = _reportData?['isAnonymous'] == true;
    
    if (!isAnonymous) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: const Row(
          children: [
            Text(
              'Anonymous Report',
              style: TextStyle(
                color: Color(0xFF36599F),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Spacer(),
            Icon(Icons.verified_user, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 4),
            Text(
              'Protected',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}