import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Camera and media service for photo/video capture
class CameraService {
  final ImagePicker _imagePicker = ImagePicker();
  List<CameraDescription>? _cameras;

  /// Initialize camera service
  Future<void> initialize() async {
    // Camera package doesn't work on web
    if (kIsWeb) {
      debugPrint('Camera initialization skipped on web');
      return;
    }
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
  Future<XFile?> takePhoto() async {
    if (!kIsWeb && !await requestCameraPermission()) {
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

      return photo;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Pick photo from gallery
  Future<XFile?> pickFromGallery() async {
    if (!kIsWeb && !await requestPhotoLibraryPermission()) {
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

      return photo;
    } catch (e) {
      debugPrint('Error picking photo: $e');
      return null;
    }
  }

  /// Record video
  Future<XFile?> recordVideo({int maxDurationSeconds = 60}) async {
    if (!kIsWeb && !await requestCameraPermission()) {
      debugPrint('Camera permission denied');
      return null;
    }

    if (!kIsWeb && !await requestMicrophonePermission()) {
      debugPrint('Microphone permission denied');
      return null;
    }

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: maxDurationSeconds),
      );

      return video;
    } catch (e) {
      debugPrint('Error recording video: $e');
      return null;
    }
  }

  /// Pick video from gallery
  Future<XFile?> pickVideoFromGallery() async {
    if (!kIsWeb && !await requestPhotoLibraryPermission()) {
      debugPrint('Photo library permission denied');
      return null;
    }

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      return video;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  /// Take multiple photos
  Future<List<XFile>> takeMultiplePhotos() async {
    if (!kIsWeb && !await requestPhotoLibraryPermission()) {
      debugPrint('Photo library permission denied');
      return [];
    }

    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return photos;
    } catch (e) {
      debugPrint('Error picking multiple photos: $e');
      return [];
    }
  }

  /// Save photo to app directory (not available on web)
  Future<String?> savePhoto(XFile photo, String filename) async {
    if (kIsWeb) {
      debugPrint('Saving photos to local directory not supported on web');
      return null;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = io.Directory('${directory.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final savedPath = '${photosDir.path}/$filename';
      final file = io.File(photo.path);
      await file.copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      return null;
    }
  }

  /// Get saved photos directory (not available on web)
  Future<io.Directory?> getPhotosDirectory() async {
    if (kIsWeb) {
      return null;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = io.Directory('${directory.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      return photosDir;
    } catch (e) {
      debugPrint('Error getting photos directory: $e');
      return null;
    }
  }

  /// Get all saved photos (not available on web)
  Future<List<XFile>> getSavedPhotos() async {
    if (kIsWeb) {
      return [];
    }
    try {
      final photosDir = await getPhotosDirectory();
      if (photosDir == null) return [];

      final files = photosDir.listSync();

      return files
          .whereType<io.File>()
          .where((file) => _isImageFile(file.path))
          .map((file) => XFile(file.path))
          .toList();
    } catch (e) {
      debugPrint('Error getting saved photos: $e');
      return [];
    }
  }

  /// Delete photo (not available on web)
  Future<bool> deletePhoto(String path) async {
    if (kIsWeb) {
      return false;
    }
    try {
      final file = io.File(path);
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

  /// Get photo file size (not available on web)
  Future<int> getPhotoSize(String path) async {
    if (kIsWeb) {
      return 0;
    }
    try {
      final file = io.File(path);
      return await file.length();
    } catch (e) {
      debugPrint('Error getting photo size: $e');
      return 0;
    }
  }

  /// Clear all saved photos (not available on web)
  Future<void> clearAllPhotos() async {
    if (kIsWeb) {
      return;
    }
    try {
      final photosDir = await getPhotosDirectory();
      if (photosDir != null && await photosDir.exists()) {
        await photosDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing photos: $e');
    }
  }
}

/// Camera screen widget
class CameraScreen extends StatefulWidget {
  final Function(XFile) onPhotoTaken;

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
    if (kIsWeb) {
      debugPrint('Camera preview not available on web');
      return;
    }

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
      widget.onPhotoTaken(photo);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera'),
        ),
        body: const Center(
          child: Text(
              'Camera preview not available on web. Use image picker instead.'),
        ),
      );
    }

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
