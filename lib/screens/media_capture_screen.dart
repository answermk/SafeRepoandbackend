import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class MediaCaptureScreen extends StatefulWidget {
  final String mediaType; // 'photo', 'video', 'audio'

  const MediaCaptureScreen({
    Key? key,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<MediaCaptureScreen> createState() => _MediaCaptureScreenState();
}

class _MediaCaptureScreenState extends State<MediaCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  List<File> _selectedFiles = [];
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _currentRecordingPath;

  // File size limits (in MB)
  final int _maxPhotoSize = 10;
  final int _maxVideoSize = 50;
  final int _maxAudioSize = 20;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'audio') {
      _initAudioRecorder();
    }
  }

  @override
  void dispose() {
    if (widget.mediaType == 'audio') {
      _audioRecorder.closeRecorder();
    }
    super.dispose();
  }

  Future<void> _initAudioRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};

    if (widget.mediaType == 'photo' || widget.mediaType == 'video') {
      statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
    } else if (widget.mediaType == 'audio') {
      statuses = await [
        Permission.microphone,
        Permission.storage,
      ].request();
    }

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _captureFromCamera() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      if (widget.mediaType == 'photo') {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (image != null) {
          await _addFile(File(image.path));
        }
      } else if (widget.mediaType == 'video') {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5),
        );
        if (video != null) {
          await _compressAndAddVideo(File(video.path));
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to capture: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      if (widget.mediaType == 'photo') {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        for (var image in images) {
          await _addFile(File(image.path));
        }
      } else if (widget.mediaType == 'video') {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
        if (video != null) {
          await _compressAndAddVideo(File(video.path));
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to select: $e');
    }
  }

  Future<void> _startAudioRecording() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _currentRecordingPath = path;
      });
    } catch (e) {
      _showErrorDialog('Failed to start recording: $e');
    }
  }

  Future<void> _stopAudioRecording() async {
    try {
      await _audioRecorder.stopRecorder();

      if (_currentRecordingPath != null) {
        await _addFile(File(_currentRecordingPath!));
      }

      setState(() {
        _isRecording = false;
        _currentRecordingPath = null;
      });
    } catch (e) {
      _showErrorDialog('Failed to stop recording: $e');
    }
  }

  Future<void> _compressAndAddVideo(File videoFile) async {
    setState(() => _isProcessing = true);

    try {
      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (info != null && info.file != null) {
        await _addFile(info.file!);
      } else {
        await _addFile(videoFile);
      }
    } catch (e) {
      // If compression fails, use original file
      await _addFile(videoFile);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _addFile(File file) async {
    // Validate file size
    final fileSize = await file.length();
    final fileSizeMB = fileSize / (1024 * 1024);

    int maxSize = 0;
    if (widget.mediaType == 'photo') maxSize = _maxPhotoSize;
    if (widget.mediaType == 'video') maxSize = _maxVideoSize;
    if (widget.mediaType == 'audio') maxSize = _maxAudioSize;

    if (fileSizeMB > maxSize) {
      _showErrorDialog(
          'File too large! Maximum size is ${maxSize}MB.\nYour file: ${fileSizeMB.toStringAsFixed(1)}MB'
      );
      return;
    }

    setState(() {
      _selectedFiles.add(file);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          widget.mediaType == 'audio'
              ? 'Microphone permission is required to record audio.'
              : 'Camera and storage permissions are required.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleDone() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Return file paths to previous screen
    final filePaths = _selectedFiles.map((file) => file.path).toList();
    Navigator.pop(context, filePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.mediaType == 'photo'
              ? 'Add Photos'
              : widget.mediaType == 'video'
              ? 'Add Video'
              : 'Record Audio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
        actions: [
          if (_selectedFiles.isNotEmpty)
            TextButton(
              onPressed: _handleDone,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? _buildProcessingIndicator()
          : Column(
        children: [
          if (_selectedFiles.isNotEmpty) ...[
            _buildSelectedFilesSection(),
            const Divider(height: 1),
          ],
          Expanded(child: _buildActionButtons()),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF36599F)),
          SizedBox(height: 20),
          Text(
            'Compressing video...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesSection() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Selected (${_selectedFiles.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFiles.clear();
                  });
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                return _buildFilePreview(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(int index) {
    final file = _selectedFiles[index];

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF36599F), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: widget.mediaType == 'photo'
                  ? Image.file(file, fit: BoxFit.cover, width: 80, height: 80)
                  : Center(
                child: Icon(
                  widget.mediaType == 'video'
                      ? Icons.video_library
                      : Icons.audiotrack,
                  size: 32,
                  color: const Color(0xFF36599F),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.mediaType == 'audio') ...[
            _buildAudioRecordingSection(),
          ] else ...[
            _buildCameraButton(),
            const SizedBox(height: 20),
            _buildGalleryButton(),
          ],
          const SizedBox(height: 30),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildAudioRecordingSection() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: _isRecording ? Colors.red : const Color(0xFF36599F),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_isRecording ? Colors.red : const Color(0xFF36599F))
                    .withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isRecording ? _stopAudioRecording : _startAudioRecording,
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _isRecording ? 'Tap to stop recording' : 'Tap to start recording',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF36599F),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _captureFromCamera,
        icon: const Icon(Icons.camera_alt, size: 28),
        label: Text(
          widget.mediaType == 'photo' ? 'Take Photo' : 'Record Video',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF36599F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: _selectFromGallery,
        icon: const Icon(Icons.photo_library, size: 28),
        label: Text(
          widget.mediaType == 'photo'
              ? 'Choose from Gallery'
              : 'Choose Video',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF36599F),
          side: const BorderSide(color: Color(0xFF36599F), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File Size Limits',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.mediaType == 'photo'
                      ? 'Max ${_maxPhotoSize}MB per photo'
                      : widget.mediaType == 'video'
                      ? 'Max ${_maxVideoSize}MB per video'
                      : 'Max ${_maxAudioSize}MB per audio',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}