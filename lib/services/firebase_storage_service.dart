import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Firebase Storage service for file uploads
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  Future<String?> uploadFile(File file, String folderPath) async {
    try {
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$folderPath/${timestamp}_$fileName';

      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Upload child avatar
  Future<String?> uploadChildAvatar(String childId, File file) async {
    return uploadFile(file, 'avatars/children/$childId');
  }

  /// Upload activity image
  Future<String?> uploadActivityImage(String activityId, File file) async {
    return uploadFile(file, 'activities/$activityId/images');
  }

  /// Upload child's creative work
  Future<String?> uploadCreativeWork(String childId, File file) async {
    return uploadFile(file, 'creative/$childId');
  }

  /// Upload audio recording
  Future<String?> uploadAudioRecording(String childId, File file) async {
    return uploadFile(file, 'audio/$childId');
  }

  /// Delete a file from Firebase Storage
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }
}

