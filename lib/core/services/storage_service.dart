import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Upload a file to Firebase Storage
  /// Returns the download URL
  static Future<String> uploadFile({
    required String filePath,
    required String folder,
    String? fileName,
  }) async {
    try {
      final file = File(filePath);
      final fileExtension = path.extension(filePath);

      // Generate unique filename if not provided
      final finalFileName = fileName ?? '${_uuid.v4()}$fileExtension';

      // Create reference to the file location
      final ref = _storage.ref().child('$folder/$finalFileName');

      // Upload file
      final uploadTask = ref.putFile(file);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload multiple files to Firebase Storage
  /// Returns list of download URLs
  static Future<List<String>> uploadFiles({
    required List<String> filePaths,
    required String folder,
  }) async {
    final List<String> urls = [];

    for (final filePath in filePaths) {
      try {
        final url = await uploadFile(filePath: filePath, folder: folder);
        urls.add(url);
      } catch (e) {
        // Log error but continue with other files
        print('Failed to upload file $filePath: $e');
      }
    }

    return urls;
  }

  /// Upload image file
  static Future<String> uploadImage({
    required String imagePath,
    String? fileName,
  }) async {
    return uploadFile(
      filePath: imagePath,
      folder: 'report_images',
      fileName: fileName,
    );
  }

  /// Upload video file
  static Future<String> uploadVideo({
    required String videoPath,
    String? fileName,
  }) async {
    return uploadFile(
      filePath: videoPath,
      folder: 'report_videos',
      fileName: fileName,
    );
  }

  /// Upload user avatar
  static Future<String> uploadAvatar({
    required String imagePath,
    required String userId,
  }) async {
    return uploadFile(
      filePath: imagePath,
      folder: 'user_avatars',
      fileName: '${userId}_avatar.jpg',
    );
  }

  /// Delete file from Firebase Storage
  static Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get file metadata
  static Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  /// Get storage usage for a user
  static Future<int> getUserStorageUsage(String userId) async {
    try {
      final listResult = await _storage.ref('report_images').listAll();
      final videoResult = await _storage.ref('report_videos').listAll();

      int totalSize = 0;

      // Calculate size for images
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      // Calculate size for videos
      for (final item in videoResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return totalSize;
    } catch (e) {
      throw Exception('Failed to calculate storage usage: $e');
    }
  }
}

