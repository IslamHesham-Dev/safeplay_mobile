import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

/// Image cache manager for optimized image loading
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  static const int _maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration _cacheExpiry = Duration(days: 7);

  /// Get cached image path (not available on web)
  Future<String?> getCacheDirectory() async {
    if (kIsWeb) {
      return null;
    }
    final directory = await getTemporaryDirectory();
    final cacheDir = io.Directory('${directory.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  /// Generate cache key from URL
  String _getCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  /// Get cached file path (not available on web)
  Future<io.File?> _getCacheFile(String url) async {
    if (kIsWeb) return null;
    final cacheDir = await getCacheDirectory();
    if (cacheDir == null) return null;
    final cacheKey = _getCacheKey(url);
    return io.File('$cacheDir/$cacheKey');
  }

  /// Check if image is cached
  Future<bool> isCached(String url) async {
    if (kIsWeb) {
      // On web, rely on browser cache
      return false;
    }
    final file = await _getCacheFile(url);
    if (file == null || !await file.exists()) return false;

    // Check if cache is expired
    final lastModified = await file.lastModified();
    final age = DateTime.now().difference(lastModified);
    return age < _cacheExpiry;
  }

  /// Get cached image
  Future<Uint8List?> getCachedImage(String url) async {
    if (kIsWeb) {
      // On web, just download (browser handles caching)
      return null;
    }
    if (!await isCached(url)) return null;

    try {
      final file = await _getCacheFile(url);
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error reading cached image: $e');
      return null;
    }
  }

  /// Download and cache image
  Future<Uint8List?> downloadAndCache(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final bytes = response.bodyBytes;

      // Only cache to file system on non-web platforms
      if (!kIsWeb) {
        final file = await _getCacheFile(url);
        if (file != null) {
          await file.writeAsBytes(bytes);
        }
      }

      return bytes;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  /// Get image (from cache or download)
  Future<Uint8List?> getImage(String url) async {
    // Try cache first
    final cached = await getCachedImage(url);
    if (cached != null) return cached;

    // Download and cache
    return await downloadAndCache(url);
  }

  /// Clear expired cache (not available on web)
  Future<void> clearExpiredCache() async {
    if (kIsWeb) return;
    final cacheDir = await getCacheDirectory();
    if (cacheDir == null) return;
    final directory = io.Directory(cacheDir);

    if (!await directory.exists()) return;

    final files = directory.listSync();
    for (final file in files) {
      if (file is io.File) {
        final lastModified = await file.lastModified();
        final age = DateTime.now().difference(lastModified);
        if (age > _cacheExpiry) {
          await file.delete();
        }
      }
    }
  }

  /// Clear all cache (not available on web)
  Future<void> clearAllCache() async {
    if (kIsWeb) return;
    final cacheDir = await getCacheDirectory();
    if (cacheDir == null) return;
    final directory = io.Directory(cacheDir);

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  /// Get cache size (not available on web)
  Future<int> getCacheSize() async {
    if (kIsWeb) return 0;
    final cacheDir = await getCacheDirectory();
    if (cacheDir == null) return 0;
    final directory = io.Directory(cacheDir);

    if (!await directory.exists()) return 0;

    int totalSize = 0;
    final files = directory.listSync();
    for (final file in files) {
      if (file is io.File) {
        totalSize += await file.length();
      }
    }

    return totalSize;
  }

  /// Check and manage cache size
  Future<void> manageCacheSize() async {
    final size = await getCacheSize();

    if (size > _maxCacheSize) {
      // Clear expired first
      await clearExpiredCache();

      // If still too large, clear oldest files
      final currentSize = await getCacheSize();
      if (currentSize > _maxCacheSize) {
        await _clearOldestFiles(_maxCacheSize ~/ 2);
      }
    }
  }

  /// Clear oldest files (not available on web)
  Future<void> _clearOldestFiles(int targetSize) async {
    if (kIsWeb) return;
    final cacheDir = await getCacheDirectory();
    if (cacheDir == null) return;
    final directory = io.Directory(cacheDir);

    final files = directory.listSync().whereType<io.File>().toList();

    // Sort by last modified (oldest first)
    files.sort((a, b) {
      return a.lastModifiedSync().compareTo(b.lastModifiedSync());
    });

    int currentSize = await getCacheSize();

    for (final file in files) {
      if (currentSize <= targetSize) break;

      final fileSize = await file.length();
      await file.delete();
      currentSize -= fileSize;
    }
  }
}

/// Cached network image widget
class CachedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: ImageCacheManager().getImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              Center(
                child: CircularProgressIndicator(),
              );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return errorWidget ??
              Icon(
                Icons.broken_image,
                size: 48,
              );
        }

        return Image.memory(
          snapshot.data!,
          fit: fit ?? BoxFit.cover,
          width: width,
          height: height,
        );
      },
    );
  }
}
