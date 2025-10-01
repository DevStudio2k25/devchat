import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class FileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Allowed file types
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi', 'mkv'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'aac', 'm4a'];

  /// Max file size (100MB)
  static const int maxFileSize = 100 * 1024 * 1024;

  /// Upload file to Supabase Storage
  Future<Map<String, dynamic>?> uploadFile({
    required File file,
    required String chatId,
    String? customFileName,
  }) async {
    try {
      // Validate file
      final validation = _validateFile(file);
      if (!validation['valid']) {
        print('❌ File validation failed: ${validation['error']}');
        return null;
      }

      // Generate file path
      final fileName = customFileName ?? _generateFileName(file);
      final filePath = 'chats/$chatId/$fileName';

      // Upload to storage
      await _supabase.storage.from('chat-files').upload(
            filePath,
            file,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _getContentType(file),
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from('chat-files').getPublicUrl(filePath);

      // Get file info
      final fileInfo = await file.stat();

      // Save file metadata to database
      final fileData = await _saveFileMetadata(
        chatId: chatId,
        fileName: fileName,
        filePath: filePath,
        publicUrl: publicUrl,
        fileSize: fileInfo.size,
        mimeType: _getContentType(file),
      );

      print('✅ File uploaded successfully: $fileName');
      return fileData;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Save file metadata to database
  Future<Map<String, dynamic>> _saveFileMetadata({
    required String chatId,
    required String fileName,
    required String filePath,
    required String publicUrl,
    required int fileSize,
    required String mimeType,
  }) async {
    final response = await _supabase.from('files').insert({
      'chat_id': chatId,
      'uploaded_by': currentUserId,
      'file_name': fileName,
      'file_type': _getFileType(fileName),
      'file_size': fileSize,
      'storage_path': filePath,
      'public_url': publicUrl,
      'mime_type': mimeType,
    }).select().single();

    return response;
  }

  /// Validate file
  Map<String, dynamic> _validateFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      return {'valid': false, 'error': 'File does not exist'};
    }

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > maxFileSize) {
      return {
        'valid': false,
        'error': 'File size exceeds 100MB limit'
      };
    }

    // Check file type
    final extension = path.extension(file.path).toLowerCase().replaceAll('.', '');
    final allAllowedTypes = [
      ...allowedImageTypes,
      ...allowedDocumentTypes,
      ...allowedVideoTypes,
      ...allowedAudioTypes,
    ];

    if (!allAllowedTypes.contains(extension)) {
      return {
        'valid': false,
        'error': 'File type not supported'
      };
    }

    return {'valid': true};
  }

  /// Generate unique file name
  String _generateFileName(File file) {
    final extension = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = currentUserId ?? 'unknown';
    return '${userId}_$timestamp$extension';
  }

  /// Get file type based on extension
  String _getFileType(String fileName) {
    final extension = path.extension(fileName).toLowerCase().replaceAll('.', '');

    if (allowedImageTypes.contains(extension)) {
      return 'image';
    } else if (allowedVideoTypes.contains(extension)) {
      return 'video';
    } else if (allowedAudioTypes.contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  /// Get content type
  String _getContentType(File file) {
    final extension = path.extension(file.path).toLowerCase().replaceAll('.', '');

    // Images
    if (extension == 'jpg' || extension == 'jpeg') return 'image/jpeg';
    if (extension == 'png') return 'image/png';
    if (extension == 'gif') return 'image/gif';
    if (extension == 'webp') return 'image/webp';

    // Videos
    if (extension == 'mp4') return 'video/mp4';
    if (extension == 'mov') return 'video/quicktime';
    if (extension == 'avi') return 'video/x-msvideo';
    if (extension == 'mkv') return 'video/x-matroska';

    // Audio
    if (extension == 'mp3') return 'audio/mpeg';
    if (extension == 'wav') return 'audio/wav';
    if (extension == 'aac') return 'audio/aac';
    if (extension == 'm4a') return 'audio/mp4';

    // Documents
    if (extension == 'pdf') return 'application/pdf';
    if (extension == 'doc') return 'application/msword';
    if (extension == 'docx') return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    if (extension == 'txt') return 'text/plain';
    if (extension == 'xls') return 'application/vnd.ms-excel';
    if (extension == 'xlsx') return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    return 'application/octet-stream';
  }

  /// Delete file
  Future<bool> deleteFile(String fileId) async {
    try {
      // Get file metadata
      final fileData = await _supabase
          .from('files')
          .select()
          .eq('id', fileId)
          .single();

      final storagePath = fileData['storage_path'] as String;

      // Delete from storage
      await _supabase.storage.from('chat-files').remove([storagePath]);

      // Delete from database
      await _supabase.from('files').delete().eq('id', fileId);

      print('✅ File deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  /// Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String fileId) async {
    try {
      final response = await _supabase
          .from('files')
          .select()
          .eq('id', fileId)
          .single();

      return response;
    } catch (e) {
      print('❌ Error getting file metadata: $e');
      return null;
    }
  }

  /// Get files for a chat
  Future<List<Map<String, dynamic>>> getChatFiles(String chatId) async {
    try {
      final response = await _supabase
          .from('files')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting chat files: $e');
      return [];
    }
  }

  /// Download file (returns file path)
  Future<String?> downloadFile(String publicUrl, String fileName) async {
    try {
      // TODO: Implement actual file download
      // This is a placeholder
      print('⚠️ File download not yet implemented');
      return null;
    } catch (e) {
      print('❌ Error downloading file: $e');
      return null;
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file icon based on type
  static String getFileIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return '🖼️';
      case 'video':
        return '🎥';
      case 'audio':
        return '🎵';
      case 'pdf':
        return '📄';
      default:
        return '📎';
    }
  }
}
