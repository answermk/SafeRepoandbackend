import 'package:flutter/material.dart';
import 'report_success_screen.dart';
import '../services/report_service.dart';
import '../controllers/report_controller.dart';

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
      
      // Call the actual backend API
      final result = await ReportService.createReport(
        incidentType: incidentType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        isAnonymous: isAnonymous,
        mediaFiles: null, // TODO: Handle media files if needed
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
        // Show error message
        final errorMsg = result['error'] as String? ?? 'Failed to submit report';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        isSubmitting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $error'),
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
        const SnackBar(
          content: Text('Report saved as draft successfully'),
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
          content: Text('Failed to save draft: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    _buildReportSummaryCard(),
                    const SizedBox(height: 20),
                    _buildEmergencyWarning(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF36599F),
        borderRadius: BorderRadius.only(
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
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Review Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Confirm your submission',
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

  Widget _buildReportSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 20),

          _buildSummaryField('TYPE', widget.reportData['incidentType'] ?? 'Suspicious Person'),
          const SizedBox(height: 18),

          _buildSummaryField('Description', widget.reportData['description'] ?? 'Individual loitering around school entrance for extended period...'),
          const SizedBox(height: 18),

          _buildSummaryField('Location', widget.reportData['detectedLocation'] ?? widget.reportData['manualAddress'] ?? '123 Main Street, Downtown'),
          const SizedBox(height: 18),

          _buildEvidenceSection(),
          const SizedBox(height: 18),

          _buildAnonymousSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryField(String label, String value) {
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
            color: label == 'TYPE' ? const Color(0xFF36599F) : Colors.black87,
            fontWeight: label == 'TYPE' ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    final evidenceList = widget.reportData['evidence'] as List<String>? ?? [];

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
            if (evidenceList.isEmpty)
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

  Widget _buildAnonymousSection() {
    final isAnonymous = widget.reportData['submitAnonymously'] ?? true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Anonymous Report',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
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
              isAnonymous ? 'Yes' : 'No',
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

  Widget _buildEmergencyWarning() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency ?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Call 911 for immediate danger',
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

  Widget _buildActionButtons() {
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
                backgroundColor: const Color(0xFF36599F),
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
                  : const Text(
                'Submit Report',
                style: TextStyle(
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
                foregroundColor: const Color(0xFF36599F),
                side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSavingDraft
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF36599F),
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Save As Draft',
                style: TextStyle(
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