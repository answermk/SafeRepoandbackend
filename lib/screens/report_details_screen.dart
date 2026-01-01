import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';
import '../utils/theme_helper.dart';
import '../utils/translation_helper.dart';

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
    final t = TranslationHelper.of(context);
    final scaffold = ThemeHelper.getScaffoldBackgroundColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final primary = ThemeHelper.getPrimaryColor(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffold,
        body: Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );
    }

    if (_reportData == null) {
      return Scaffold(
        backgroundColor: scaffold,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: secondary),
              const SizedBox(height: 16),
              Text(t.unableToLoadReportDetails, style: TextStyle(color: textColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.goBack),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: scaffold,
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
    final t = TranslationHelper.of(context);
    final primary = ThemeHelper.getPrimaryColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    return Container(
      color: primary,
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
              Text(
                t.reportDetailsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${t.reportIdLabel} ${widget.reportId ?? _reportData?['id'] ?? t.notAvailable}',
                style: TextStyle(
                  color: secondary,
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
    final t = TranslationHelper.of(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final textColor = ThemeHelper.getTextColor(context);

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
              style: TextStyle(
                color: statusColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          Text(
            updatedAt != null ? t.updatedTimeAgo(_formatTimeAgo(updatedAt)) : t.updatedUnknown,
            style: TextStyle(color: secondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentInfo() {
    final t = TranslationHelper.of(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);

    final title = _reportData?['title']?.toString() ?? t.untitledReport;
    final description = _reportData?['description']?.toString() ?? t.noDescriptionProvided;
    final location = _reportData?['location'] as Map<String, dynamic>?;
    final address = location?['address']?.toString() ?? 
                   location?['city']?.toString() ?? 
                   t.locationNotSpecified;
    final createdAt = _reportData?['createdAt']?.toString();
    final dateTime = createdAt != null ? _formatDate(createdAt) : t.unknown;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.incidentInformation,
              style: TextStyle(
                color: ThemeHelper.getPrimaryColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${t.typeLabel}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: title),
                ],
              ),
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${t.locationLabel}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: address),
                ],
              ),
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${t.timeLabel}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: dateTime),
                ],
              ),
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              t.descriptionLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    final primary = ThemeHelper.getPrimaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(Icons.camera_alt, color: primary, size: 28),
            const SizedBox(width: 16),
            Icon(Icons.videocam, color: primary, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdates() {
    final t = TranslationHelper.of(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final primary = ThemeHelper.getPrimaryColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.statusUpdates,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${t.reportUnderReview}\n', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${t.minutesAgo(30)}\n'),
                  TextSpan(text: t.officerAssigned),
                ],
              ),
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${t.reportReceived}\n', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${t.hoursAgo(2)}\n'),
                  TextSpan(text: t.reportLogged),
                ],
              ),
              style: TextStyle(fontSize: 14, color: secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousBadge() {
    final t = TranslationHelper.of(context);
    final primary = ThemeHelper.getPrimaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);

    final isAnonymous = _reportData?['isAnonymous'] == true;
    
    if (!isAnonymous) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Text(
              t.anonymousReportLabel,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Spacer(),
            Icon(Icons.verified_user, color: Colors.green.shade600, size: 20),
            SizedBox(width: 4),
            Text(
              t.protectedLabel,
              style: TextStyle(
                color: Colors.green.shade600,
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