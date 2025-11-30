import 'dart:io';

/// File Utility
/// Helper functions for file operations
class FileUtils {
  /// Get file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  static bool isImage(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file is a video
  static bool isVideo(String filePath) {
    final extension = getFileExtension(filePath);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  /// Check if file is a document
  static bool isDocument(String filePath) {
    final extension = getFileExtension(filePath);
    return ['pdf', 'doc', 'docx', 'txt'].contains(extension);
  }

  /// Get MIME type from file extension
  static String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// Validate file size
  static bool isValidFileSize(File file, int maxSizeInBytes) {
    return file.lengthSync() <= maxSizeInBytes;
  }
}

