import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from camera
  static Future<File?> pickImageFromCamera({
    int quality = 85,
    bool compress = true,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
      );

      if (image == null) return null;

      File imageFile = File(image.path);

      // Compress if needed
      if (compress) {
        imageFile = await _compressImage(imageFile) ?? imageFile;
      }

      return imageFile;
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery({
    int quality = 85,
    bool compress = true,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      if (image == null) return null;

      File imageFile = File(image.path);

      // Compress if needed
      if (compress) {
        imageFile = await _compressImage(imageFile) ?? imageFile;
      }

      return imageFile;
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    int quality = 85,
    bool compress = true,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: quality,
      );

      if (images.isEmpty) return [];

      List<File> imageFiles = [];

      for (var image in images) {
        File imageFile = File(image.path);

        // Compress if needed
        if (compress) {
          imageFile = await _compressImage(imageFile) ?? imageFile;
        }

        imageFiles.add(imageFile);
      }

      return imageFiles;
    } catch (e) {
      print('❌ Error picking multiple images: $e');
      return [];
    }
  }

  /// Pick video from camera
  static Future<File?> pickVideoFromCamera({
    Duration maxDuration = const Duration(minutes: 5),
  }) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      print('❌ Error picking video from camera: $e');
      return null;
    }
  }

  /// Pick video from gallery
  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      print('❌ Error picking video from gallery: $e');
      return null;
    }
  }

  /// Pick any file
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) return null;

      final filePath = result.files.single.path;
      if (filePath == null) return null;

      return File(filePath);
    } catch (e) {
      print('❌ Error picking file: $e');
      return null;
    }
  }

  /// Pick multiple files
  static Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return [];

      List<File> files = [];
      for (var file in result.files) {
        if (file.path != null) {
          files.add(File(file.path!));
        }
      }

      return files;
    } catch (e) {
      print('❌ Error picking multiple files: $e');
      return [];
    }
  }

  /// Pick document
  static Future<File?> pickDocument() async {
    return pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
    );
  }

  /// Pick audio
  static Future<File?> pickAudio() async {
    return pickFile(
      type: FileType.audio,
    );
  }

  /// Compress image
  /// Note: Image compression requires flutter_image_compress package
  /// For now, returning original file
  static Future<File?> _compressImage(File file) async {
    try {
      // TODO: Implement image compression with flutter_image_compress package
      // For now, just return the original file
      return file;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return file;
    }
  }

  /// Get file size
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Get file extension
  static String getFileExtension(File file) {
    return path.extension(file.path).toLowerCase().replaceAll('.', '');
  }

  /// Get file name
  static String getFileName(File file) {
    return path.basename(file.path);
  }

  /// Check if file is image
  static bool isImage(File file) {
    final extension = getFileExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file is video
  static bool isVideo(File file) {
    final extension = getFileExtension(file);
    return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
  }

  /// Check if file is audio
  static bool isAudio(File file) {
    final extension = getFileExtension(file);
    return ['mp3', 'wav', 'aac', 'm4a'].contains(extension);
  }

  /// Check if file is document
  static bool isDocument(File file) {
    final extension = getFileExtension(file);
    return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'].contains(extension);
  }
}
