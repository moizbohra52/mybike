import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../services/cache_service.dart';

/// Central Performance and Memory Management Optimizer for MYBIKE ERP.
class PerformanceOptimizer {
  PerformanceOptimizer._();

  static const int kDefaultMaxImageCacheCount = 250;
  static const int kDefaultMaxImageCacheBytes = 50 * 1024 * 1024; // 50MB

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Bootstrap performance optimizations during application startup.
  static Future<int> initialize({
    int maxImageCount = kDefaultMaxImageCacheCount,
    int maxImageBytes = kDefaultMaxImageCacheBytes,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 1. Configure Flutter Image Cache bounds
    configureImageCache(
      maxCount: maxImageCount,
      maxSizeBytes: maxImageBytes,
    );

    _initialized = true;
    stopwatch.stop();

    if (kDebugMode) {
      debugPrint(
        '⚡ [PERF] PerformanceOptimizer initialized in ${stopwatch.elapsedMilliseconds}ms '
        '(ImageCache: $maxImageCount items, ${(maxImageBytes / (1024 * 1024)).toStringAsFixed(0)}MB max)',
      );
    }

    return stopwatch.elapsedMilliseconds;
  }

  /// Configure Flutter's ImageCache memory limits to prevent memory bloat on Web & Desktop.
  static void configureImageCache({
    int maxCount = kDefaultMaxImageCacheCount,
    int maxSizeBytes = kDefaultMaxImageCacheBytes,
  }) {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.maximumSize = maxCount;
      imageCache.maximumSizeBytes = maxSizeBytes;
    } catch (e) {
      // PaintingBinding may not be bound in non-widget unit test environments.
      if (kDebugMode) {
        debugPrint('⚠️ [PERF] ImageCache configuration bypassed: $e');
      }
    }
  }

  /// Clear the image cache completely (useful on logout, low-memory warnings, or tenant switch).
  static void clearImageCache() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.clear();
      imageCache.clearLiveImages();
    } catch (e) {
      // Ignored if test binding
    }
  }

  /// Comprehensive memory trim for low-memory events or session resets.
  static void trimMemory() {
    clearImageCache();
    // Invalidate stale entries across CacheService
    CacheService.instance.clear();
  }
}
