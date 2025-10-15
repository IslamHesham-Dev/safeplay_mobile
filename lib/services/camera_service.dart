import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

/// Camera and media service for photo/video capture
class CameraService {
  final ImagePicker _imagePicker = ImagePicker();
  List<CameraDescription>? _cameras;

  /// Initialize camera service
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Request microphone permission (for video)
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if camera is available
  bool get isCameraAvailable => _cameras != null && _cameras!.isNotEmpty;

  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;

  /// Take photo using camera
  Future<File?> takePhoto() async {
    if (!await requestCameraPermission()) {
      debugPrint('Camera permission denied');
      return null;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Pick photo from gallery
  Future<File?> pickFromGallery() async {
    if (!await requestPhotoLibraryPermission()) {
      debugPrint('Photo library permission denied');
      return null;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error picking photo: $e');
      return null;
    }
  }

  /// Record video
  Future<File?> recordVideo({int maxDurationSeconds = 60}) async {
    if (!await requestCameraPermission()) {
      debugPrint('Camera permission denied');
      return null;
    }

    if (!await requestMicrophonePermission()) {
      debugPrint('Microphone permission denied');
      return null;
    }

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: maxDurationSeconds),
      );

      if (video == null) return null;
      return File(video.path);
    } catch (e) {
      debugPrint('Error recording video: $e');
      return null;
    }
  }

  /// Pick video from gallery
  Future<File?> pickVideoFromGallery() async {
    if (!await requestPhotoLibraryPermission()) {
      debugPrint('Photo library permission denied');
      return null;
    }

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null) return null;
      return File(video.path);
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  /// Take multiple photos
  Future<List<File>> takeMultiplePhotos() async {
    if (!await requestPhotoLibraryPermission()) {
      debugPrint('Photo library permission denied');
      return [];
    }

    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return photos.map((photo) => File(photo.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple photos: $e');
      return [];
    }
  }

  /// Save photo to app directory
  Future<String?> savePhoto(File photo, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final savedPath = '${photosDir.path}/$filename';
      await photo.copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      return null;
    }
  }

  /// Get saved photos directory
  Future<Directory> getPhotosDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    return photosDir;
  }

  /// Get all saved photos
  Future<List<File>> getSavedPhotos() async {
    try {
      final photosDir = await getPhotosDirectory();
      final files = photosDir.listSync();

      return files
          .whereType<File>()
          .where((file) => _isImageFile(file.path))
          .toList();
    } catch (e) {
      debugPrint('Error getting saved photos: $e');
      return [];
    }
  }

  /// Delete photo
  Future<bool> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  /// Check if file is an image
  bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Get photo file size
  Future<int> getPhotoSize(String path) async {
    try {
      final file = File(path);
      return await file.length();
    } catch (e) {
      debugPrint('Error getting photo size: $e');
      return 0;
    }
  }

  /// Clear all saved photos
  Future<void> clearAllPhotos() async {
    try {
      final photosDir = await getPhotosDirectory();
      if (await photosDir.exists()) {
        await photosDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing photos: $e');
    }
  }
}

/// Camera screen widget
class CameraScreen extends StatefulWidget {
  final Function(File) onPhotoTaken;

  const CameraScreen({
    super.key,
    required this.onPhotoTaken,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameraService = CameraService();
    await cameraService.initialize();

    if (cameraService.cameras == null || cameraService.cameras!.isEmpty) {
      debugPrint('No cameras available');
      return;
    }

    _controller = CameraController(
      cameraService.cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      widget.onPhotoTaken(File(photo.path));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          Center(
            child: CameraPreview(_controller!),
          ),

          // Capture button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _takePicture,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

