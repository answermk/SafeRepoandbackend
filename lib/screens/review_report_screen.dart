import 'dart:io';
import 'package:flutter/material.dart';
import 'report_success_screen.dart';
import '../services/report_service.dart';
import '../controllers/report_controller.dart';
import '../utils/theme_helper.dart';
import '../utils/translation_helper.dart';
import '../l10n/app_localizations.dart';

class ReviewReportScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReviewReportScreen({
    Key? key,
    required this.reportData,
  }) : super(key: key);

  @override
  State<ReviewReportScreen> createState() => _ReviewReportScreenState();
}

class _ReviewReportScreenState extends State<ReviewReportScreen> {
  bool isSubmitting = false;
  bool isSavingDraft = false;

  Future<void> _submitReport() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      print('Submitting report to backend...');
      print('Report data: ${widget.reportData}');

      // Extract data from reportData map
      final incidentType = widget.reportData['incidentType'] as String? ?? 'other';
      final description = widget.reportData['description'] as String? ?? '';
      final latitude = widget.reportData['latitude'] as double? ?? -1.9441; // Default to Kigali
      final longitude = widget.reportData['longitude'] as double? ?? 30.0619;
      final address = widget.reportData['detectedLocation'] as String? ?? 
                      widget.reportData['manualAddress'] as String?;
      final isAnonymous = widget.reportData['submitAnonymously'] as bool? ?? false;
      
      // Extract and convert media files from reportData
      List<File>? mediaFiles;
      if (widget.reportData['mediaPaths'] != null) {
        final mediaPaths = widget.reportData['mediaPaths'] as List<dynamic>?;
        if (mediaPaths != null && mediaPaths.isNotEmpty) {
          // Convert string paths to File objects and filter out non-existent files
          mediaFiles = mediaPaths
              .map((path) => path.toString())
              .where((path) => path.isNotEmpty)
              .map((path) => File(path))
              .where((file) => file.existsSync())
              .toList();
          
          // If all files were invalid, set to null
          if (mediaFiles.isEmpty) {
            mediaFiles = null;
          } else {
            print('📎 Uploading ${mediaFiles.length} media file(s)');
            for (var file in mediaFiles) {
              print('  - ${file.path} (${(file.lengthSync() / 1024).toStringAsFixed(2)} KB)');
            }
          }
        }
      }
      
      // Call the actual backend API
      final result = await ReportService.createReport(
        incidentType: incidentType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        isAnonymous: isAnonymous,
        mediaFiles: mediaFiles,
      );

      setState(() {
        isSubmitting = false;
      });

      if (result['success'] == true) {
        final reportData = result['data'] as Map<String, dynamic>?;
        final reportId = reportData?['id']?.toString() ?? 
                        '#SP-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReportSuccessScreen(
              reportId: reportId,
            ),
          ),
        );
      } else {
        // Check if report was queued for offline sync
        final wasQueued = result['queued'] == true;
        
        if (wasQueued) {
          // Show success message that report was queued
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report saved offline. It will be submitted when connection is restored.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View Queue',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to offline queue screen
                  Navigator.pushNamed(context, '/offline-queue');
                },
              ),
            ),
          );
          
          // Navigate back or to queue screen
          Navigator.pop(context);
        } else {
          // Show error message
          final errorMsg = result['error'] as String? ?? 'Failed to submit report';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${TranslationHelper.of(context).reportSubmitFailed}: $errorMsg'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      setState(() {
        isSubmitting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${TranslationHelper.of(context).reportSubmitFailed}: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAsDraft() async {
    setState(() {
      isSavingDraft = true;
    });

    try {
      // TODO: Implement backend draft saving
      print('Saving report as draft...');
      print('Draft data: ${widget.reportData}');

      // Prepare draft data
      final draftData = {
        ...widget.reportData,
        'status': 'draft',
        'savedAt': DateTime.now().toIso8601String(),
        'draftId': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual backend call
      // await ReportService.saveDraft(draftData);

      setState(() {
        isSavingDraft = false;
      });

      // Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationHelper.of(context).draftSavedSuccess),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      setState(() {
        isSavingDraft = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${TranslationHelper.of(context).draftSaveFailed}: $error'),
          backgroundColor: Colors.red,
        ),
      );
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

    return Scaffold(
      backgroundColor: scaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(t, primary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    _buildReportSummaryCard(t, cardColor, textColor, secondary, primary),
                    const SizedBox(height: 20),
                    _buildEmergencyWarning(t),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildActionButtons(t, primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(
                  t.reviewReportTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  t.confirmSubmission,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummaryCard(AppLocalizations t, Color cardColor, Color textColor, Color secondary, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.reportSummaryTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 20),

          _buildSummaryField(t.typeLabel.toUpperCase(), widget.reportData['incidentType'] ?? t.suspiciousActivityLabel, textColor, primary, t),
          const SizedBox(height: 18),

          _buildSummaryField(t.descriptionLabel, widget.reportData['description'] ?? t.noDescriptionProvided, textColor, primary, t),
          const SizedBox(height: 18),

          _buildSummaryField(t.locationLabel, widget.reportData['detectedLocation'] ?? widget.reportData['manualAddress'] ?? t.locationNotSpecified, textColor, primary, t),
          const SizedBox(height: 18),

          _buildEvidenceSection(t, textColor, secondary, primary),
          const SizedBox(height: 18),

          _buildAnonymousSection(t, textColor),
        ],
      ),
    );
  }

  Widget _buildSummaryField(String label, String value, Color textColor, Color primary, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: label.toUpperCase() == t.typeLabel.toUpperCase() ? primary : textColor,
            fontWeight: label.toUpperCase() == t.typeLabel.toUpperCase() ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(AppLocalizations t, Color textColor, Color secondary, Color primary) {
    final evidenceList = widget.reportData['evidence'] as List<String>? ?? [];
    final mediaPaths = widget.reportData['mediaPaths'] as List<dynamic>? ?? [];
    final mediaCount = mediaPaths.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidence',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (evidenceList.contains('photo'))
              Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF36599F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            if (evidenceList.contains('video'))
              Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF36599F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            if (mediaCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.attach_file,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$mediaCount file${mediaCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (evidenceList.isEmpty && mediaCount == 0)
              Text(
                'No evidence attached',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnonymousSection(AppLocalizations t, Color textColor) {
    final isAnonymous = widget.reportData['submitAnonymously'] ?? true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t.anonymousReportLabel,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.check,
              color: isAnonymous ? const Color(0xFF10B981) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isAnonymous ? t.yesLabel : t.noLabel,
              style: TextStyle(
                fontSize: 15,
                color: isAnonymous ? const Color(0xFF10B981) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyWarning(AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                t.emergencyPrompt,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                t.call911Prompt,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations t, Color primary) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Submit Report Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                t.submitReportCta,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Save as Draft Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: isSavingDraft ? null : _saveAsDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSavingDraft
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: primary,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                t.saveAsDraftCta,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}