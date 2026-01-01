import 'package:flutter/material.dart';
import 'dart:async';
import 'location_screen.dart';
import 'media_capture_screen.dart';
import '../services/draft_service.dart';
import '../utils/theme_helper.dart';
import '../utils/translation_helper.dart';
import '../l10n/app_localizations.dart';

class ReportCrimeScreen extends StatefulWidget {
  const ReportCrimeScreen({Key? key}) : super(key: key);

  @override
  State<ReportCrimeScreen> createState() => _ReportCrimeScreenState();
}

class _ReportCrimeScreenState extends State<ReportCrimeScreen> {
  bool _submitAnonymously = true;
  String? _selectedIncidentType;
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _selectedEvidence = [];
  List<String> _uploadedMediaPaths = []; // Store actual media file paths

  // Backend data structure for report
  Map<String, dynamic> reportData = {};

  // Draft auto-save variables
  Timer? _debounceTimer;
  bool _isSavingDraft = false;
  bool _draftSaved = false;
  DateTime? _lastSavedAt;

  // All incident categories
  final List<Map<String, dynamic>> _incidentCategories = [
    {
      'id': 'suspicious_person',
      'icon': Icons.person,
      'color': const Color(0xFFFFB347),
      'title': 'Suspicious Person',
      'subtitle': 'Individual acting suspiciously'
    },
    {
      'id': 'vehicle_activity',
      'icon': Icons.directions_car,
      'color': const Color(0xFFFF6B6B),
      'title': 'Vehicle Activity',
      'subtitle': 'Suspicious vehicle behavior'
    },
    {
      'id': 'abandoned_item',
      'icon': Icons.inventory_2,
      'color': const Color(0xFFFFD93D),
      'title': 'Abandoned Item',
      'subtitle': 'Unattended suspicious items'
    },
    {
      'id': 'theft',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFEF4444),
      'title': 'Theft/Burglary',
      'subtitle': 'Property theft or break-in'
    },
    {
      'id': 'vandalism',
      'icon': Icons.broken_image,
      'color': const Color(0xFFF97316),
      'title': 'Vandalism',
      'subtitle': 'Property damage or graffiti'
    },
    {
      'id': 'drug_activity',
      'icon': Icons.medication,
      'color': const Color(0xFF8B5CF6),
      'title': 'Drug Activity',
      'subtitle': 'Suspected drug-related behavior'
    },
    {
      'id': 'assault',
      'icon': Icons.dangerous,
      'color': const Color(0xFFDC2626),
      'title': 'Assault/Violence',
      'subtitle': 'Physical altercation or threat'
    },
    {
      'id': 'noise',
      'icon': Icons.volume_up,
      'color': const Color(0xFF06B6D4),
      'title': 'Noise Disturbance',
      'subtitle': 'Excessive noise complaint'
    },
    {
      'id': 'trespassing',
      'icon': Icons.no_accounts,
      'color': const Color(0xFF84CC16),
      'title': 'Trespassing',
      'subtitle': 'Unauthorized entry'
    },
    {
      'id': 'other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF6B7280),
      'title': 'Other',
      'subtitle': 'Other incident type'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
    // Listen to description changes for auto-save
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    super.dispose();
  }

  /// Load saved draft when screen opens
  Future<void> _loadDraft() async {
    final draft = await DraftService.loadDraft();
    if (draft != null && mounted) {
      // Show dialog to restore draft
      final shouldRestore = await _showRestoreDraftDialog(draft);
      if (shouldRestore == true) {
        setState(() {
          _selectedIncidentType = draft['incidentType'] as String?;
          _descriptionController.text = draft['description'] as String? ?? '';
          _selectedEvidence = List<String>.from(draft['evidence'] ?? []);
          _uploadedMediaPaths = List<String>.from(draft['mediaPaths'] ?? []);
          _submitAnonymously = draft['submitAnonymously'] as bool? ?? true;
          _lastSavedAt = draft['_savedAt'] != null 
              ? DateTime.tryParse(draft['_savedAt'] as String)
              : null;
        });
        // Trigger auto-save after restoring
        _triggerAutoSave();
      }
    }
  }

  /// Show dialog asking user if they want to restore draft
  Future<bool?> _showRestoreDraftDialog(Map<String, dynamic> draft) async {
    final savedAt = draft['_savedAt'] != null
        ? DateTime.tryParse(draft['_savedAt'] as String)
        : null;
    final timeAgo = savedAt != null
        ? DraftService.getFormattedTimeAgo(savedAt)
        : 'previously';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore, color: Color(0xFF36599F)),
            SizedBox(width: 8),
            Text('Restore Draft?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have an unsaved draft from $timeAgo.'),
            const SizedBox(height: 12),
            if (draft['incidentType'] != null) ...[
              Text(
                'Incident: ${_getIncidentTitle(draft['incidentType'] as String)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
            ],
            if (draft['description'] != null && (draft['description'] as String).isNotEmpty) ...[
              Text(
                'Description: ${(draft['description'] as String).substring(0, (draft['description'] as String).length > 50 ? 50 : (draft['description'] as String).length)}${(draft['description'] as String).length > 50 ? '...' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear draft and start fresh
              DraftService.clearDraft();
              Navigator.of(context).pop(false);
            },
            child: const Text('Start Fresh'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF36599F),
            ),
            child: const Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Get incident title from ID
  String _getIncidentTitle(String? incidentId) {
    if (incidentId == null) return 'Unknown';
    try {
      return _incidentCategories
          .firstWhere((cat) => cat['id'] == incidentId)['title'] as String;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Called when description text changes
  void _onDescriptionChanged() {
    _triggerAutoSave();
  }

  /// Trigger debounced auto-save
  void _triggerAutoSave() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set new timer (2 seconds debounce)
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _performAutoSave();
    });
  }

  /// Perform the actual auto-save operation
  Future<void> _performAutoSave() async {
    // Only save if there's something to save
    if (_selectedIncidentType == null && _descriptionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSavingDraft = true;
      _draftSaved = false;
    });

    // Prepare draft data
    final draftData = {
      'incidentType': _selectedIncidentType,
      'incidentTitle': _selectedIncidentType != null
          ? _getIncidentTitle(_selectedIncidentType)
          : null,
      'description': _descriptionController.text.trim(),
      'evidence': _selectedEvidence,
      'mediaPaths': _uploadedMediaPaths,
      'submitAnonymously': _submitAnonymously,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Save to local storage
    final saved = await DraftService.saveDraft(draftData);

    if (mounted) {
      setState(() {
        _isSavingDraft = false;
        _draftSaved = saved;
        _lastSavedAt = DateTime.now();
      });

      // Clear the saved indicator after 3 seconds
      if (saved) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _draftSaved = false;
            });
          }
        });
      }
    }
  }

  Future<void> _handleEvidenceSelection(String type) async {
    // Navigate to MediaCaptureScreen based on type
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaCaptureScreen(
          mediaType: type, // 'photo', 'video', 'audio'
        ),
      ),
    );

    if (result != null && result is List<String>) {
      setState(() {
        _uploadedMediaPaths.addAll(result);
        if (!_selectedEvidence.contains(type)) {
          _selectedEvidence.add(type);
        }
      });

      // Auto-save when media is added
      _triggerAutoSave();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.length} ${type}(s) added'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleContinueToLocation() async {
    // Validate required fields
    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an incident type'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Prepare report data for backend
    reportData = {
      'incidentType': _selectedIncidentType,
      'incidentTitle': _incidentCategories
          .firstWhere((cat) => cat['id'] == _selectedIncidentType)['title'],
      'description': _descriptionController.text.trim(),
      'evidence': _selectedEvidence,
      'mediaPaths': _uploadedMediaPaths,
      'submitAnonymously': _submitAnonymously,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'draft',
    };

    print('Report data prepared for backend: $reportData');

    // Clear local draft since we're proceeding to next step
    // (The draft will be saved again in the location screen if needed)
    await DraftService.clearDraft();

    // Navigate to location screen with report data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(reportData: reportData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final scaffold = ThemeHelper.getScaffoldBackgroundColor(context);
    final primary = ThemeHelper.getPrimaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final borderColor = ThemeHelper.getBorderColor(context);

    return Scaffold(
      backgroundColor: scaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, t, primary, secondary),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),

                      // Section Title with count
                      Row(
                        children: [
                          Text(
                            t.selectIncidentTypeTitle,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_incidentCategories.length}',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Incident Type Cards
                      ..._incidentCategories.map((category) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildIncidentTypeCard(
                          icon: category['icon'] as IconData,
                          iconColor: category['color'] as Color,
                          title: category['title'] as String,
                          subtitle: category['subtitle'] as String,
                          value: category['id'] as String,
                        ),
                      )),

                      const SizedBox(height: 30),

                      // Description Section
                      Text(
                        t.descriptionLabel,
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.provideDetailsHint,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildDescriptionField(
                        t,
                        primary,
                        secondary,
                        cardColor,
                        borderColor,
                        textColor,
                      ),

                      const SizedBox(height: 30),

                      // Evidence Section
                      Row(
                        children: [
                          Text(
                            t.addEvidenceTitle,
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.optionalLabel,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.evidenceHelperText,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildEvidenceRow(primary, t, secondary),

                      // Show uploaded media count
                      if (_uploadedMediaPaths.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.filesAttachedCount(_uploadedMediaPaths.length),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Anonymous Toggle Section
                      _buildAnonymousSection(
                        primary,
                        secondary,
                        textColor,
                        t,
                        cardColor,
                        borderColor,
                      ),

                      const SizedBox(height: 40),
                      _buildContinueButton(primary, textColor, t),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations t, Color primary, Color secondary) {
    return Container(
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.reportCrimeTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.reportCrimeSubtitle,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Draft status indicator
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: _buildDraftStatusIndicator(primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Build draft save status indicator
  Widget _buildDraftStatusIndicator(Color primary) {
    if (_isSavingDraft) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              TranslationHelper.of(context).savingLabel,
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (_draftSaved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 14),
            const SizedBox(width: 6),
            Text(
              TranslationHelper.of(context).draftSavedSuccess,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (_lastSavedAt != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save, color: Colors.grey[600], size: 14),
            const SizedBox(width: 6),
            Text(
              DraftService.getFormattedTimeAgo(_lastSavedAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildIncidentTypeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedIncidentType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIncidentType = value;
        });
        // Auto-save when incident type changes
        _triggerAutoSave();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF36599F) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF36599F).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF36599F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(
    AppLocalizations t,
    Color primary,
    Color secondary,
    Color cardColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardColor,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: t.descriptionPlaceholder,
          hintStyle: TextStyle(
            color: secondary,
            fontSize: 15,
          ),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          counterStyle: TextStyle(color: secondary, fontSize: 12),
        ),
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildEvidenceRow(Color primary, AppLocalizations t, Color secondary) {
    return Row(
      children: [
        _buildEvidenceIcon(Icons.camera_alt, t.photoLabel, 'photo', primary, secondary),
        const SizedBox(width: 20),
        _buildEvidenceIcon(Icons.videocam, t.videoLabel, 'video', primary, secondary),
        const SizedBox(width: 20),
        _buildEvidenceIcon(Icons.mic, t.audioLabel, 'audio', primary, secondary),
      ],
    );
  }

  Widget _buildEvidenceIcon(
    IconData icon,
    String label,
    String type,
    Color primary,
    Color secondary,
  ) {
    final isSelected = _selectedEvidence.contains(type);

    return GestureDetector(
      onTap: () => _handleEvidenceSelection(type),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected
                  ? primary
                  : primary.withOpacity(0.35),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? primary : secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousSection(
    Color primary,
    Color secondary,
    Color textColor,
    AppLocalizations t,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip,
                color: _submitAnonymously
                    ? primary
                    : secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.submitAnonymouslyTitle,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.identityProtectedSubtitle,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _submitAnonymously,
                onChanged: (val) {
                  setState(() {
                    _submitAnonymously = val;
                  });
                  // Auto-save when anonymous toggle changes
                  _triggerAutoSave();
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF36599F),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(Color primary, Color textColor, AppLocalizations t) {
    final bool isValid = _selectedIncidentType != null &&
        _descriptionController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isValid ? _handleContinueToLocation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isValid ? 2 : 0,
        ),
        child: Text(
          t.continueToLocation,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isValid ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}