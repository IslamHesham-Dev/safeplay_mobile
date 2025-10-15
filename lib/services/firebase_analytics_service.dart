import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics service
class FirebaseAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log user login
  Future<void> logLogin(String userId, String userType) async {
    await _analytics.logLogin(loginMethod: userType);
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_type', value: userType);
  }

  /// Log child selection
  Future<void> logChildSelection(String childId, String ageGroup) async {
    await _analytics.logEvent(
      name: 'child_selected',
      parameters: {
        'child_id': childId,
        'age_group': ageGroup,
      },
    );
  }

  /// Log activity start
  Future<void> logActivityStart(
    String activityId,
    String activityTitle,
    String subject,
  ) async {
    await _analytics.logEvent(
      name: 'activity_started',
      parameters: {
        'activity_id': activityId,
        'activity_title': activityTitle,
        'subject': subject,
      },
    );
  }

  /// Log activity completion
  Future<void> logActivityCompletion(
    String activityId,
    int score,
    int totalPoints,
    int duration,
  ) async {
    await _analytics.logEvent(
      name: 'activity_completed',
      parameters: {
        'activity_id': activityId,
        'score': score,
        'total_points': totalPoints,
        'duration_seconds': duration,
        'percentage': (score / totalPoints * 100).round(),
      },
    );
  }

  /// Log achievement unlocked
  Future<void> logAchievementUnlocked(String achievementId) async {
    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
      },
    );
  }

  /// Log level up
  Future<void> logLevelUp(int newLevel, int totalXp) async {
    await _analytics.logLevelUp(
      level: newLevel,
      character: 'child',
    );
    await _analytics.logEvent(
      name: 'level_up',
      parameters: {
        'new_level': newLevel,
        'total_xp': totalXp,
      },
    );
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  /// Log error
  Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    required String userType,
    String? ageGroup,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_type', value: userType);
    if (ageGroup != null) {
      await _analytics.setUserProperty(name: 'age_group', value: ageGroup);
    }
  }
}

