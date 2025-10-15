import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Performance monitoring and optimization service
class PerformanceService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    // Enable Crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterFatalError(details);
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Set up platform dispatcher error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('Performance monitoring initialized');
  }

  /// Log custom error
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Log custom event for analytics
  Future<void> logEvent(
      String eventName, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    String? ageGroup,
    String? userType,
  }) async {
    await _crashlytics.setUserIdentifier(userId);
    await _analytics.setUserId(id: userId);

    if (ageGroup != null) {
      await _analytics.setUserProperty(name: 'age_group', value: ageGroup);
    }
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
  }

  /// Log performance metric
  Future<void> logPerformance(
    String metricName,
    Duration duration,
  ) async {
    await _analytics.logEvent(
      name: 'performance_$metricName',
      parameters: {
        'duration_ms': duration.inMilliseconds,
      },
    );

    if (duration.inSeconds > 5) {
      debugPrint('⚠️ Slow operation: $metricName took ${duration.inSeconds}s');
    }
  }

  /// Track app startup time
  Future<void> trackStartupTime(Duration startupDuration) async {
    await logPerformance('app_startup', startupDuration);
  }

  /// Track screen load time
  Future<void> trackScreenLoadTime(String screenName, Duration loadTime) async {
    await _analytics.logEvent(
      name: 'screen_load',
      parameters: {
        'screen_name': screenName,
        'load_time_ms': loadTime.inMilliseconds,
      },
    );
  }

  /// Track activity completion time
  Future<void> trackActivityCompletion({
    required String activityId,
    required Duration completionTime,
    required int score,
  }) async {
    await _analytics.logEvent(
      name: 'activity_completed',
      parameters: {
        'activity_id': activityId,
        'completion_time_ms': completionTime.inMilliseconds,
        'score': score,
      },
    );
  }

  /// Log memory usage
  void logMemoryUsage() {
    if (kDebugMode) {
      // This is approximate and for debugging only
      debugPrint('📊 Memory check triggered');
    }
  }

  /// Check app health
  Future<HealthStatus> checkHealth() async {
    // Placeholder for health check logic
    return HealthStatus(
      isHealthy: true,
      issues: [],
      lastCheck: DateTime.now(),
    );
  }
}

/// App health status
class HealthStatus {
  final bool isHealthy;
  final List<String> issues;
  final DateTime lastCheck;

  HealthStatus({
    required this.isHealthy,
    required this.issues,
    required this.lastCheck,
  });
}

/// Performance metrics tracker
class PerformanceMetrics {
  static final PerformanceMetrics _instance = PerformanceMetrics._internal();
  factory PerformanceMetrics() => _instance;
  PerformanceMetrics._internal();

  final Map<String, DateTime> _startTimes = {};

  /// Start timing an operation
  void startTiming(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// End timing and return duration
  Duration? endTiming(String operationName) {
    final startTime = _startTimes.remove(operationName);
    if (startTime == null) return null;
    return DateTime.now().difference(startTime);
  }

  /// Clear all timers
  void clearTimers() {
    _startTimes.clear();
  }
}

