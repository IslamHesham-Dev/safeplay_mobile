import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import '../models/activity_progress.dart';
import '../models/game_activity.dart';
import '../models/user_profile.dart';
import 'children_progress_service.dart';
import 'auth_service.dart';

// Import GameResponse from game_activity.dart
import '../models/game_activity.dart' show GameResponse;

/// Service for tracking child's progress through teacher-created activities
/// Tracks marks, solutions, and updates coin balance
class JuniorActivityProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChildrenProgressService _progressService = ChildrenProgressService();
  final AuthService _authService = AuthService();

  static const String activityProgressCollection = 'activityProgress';
  static const String gameSessionsCollection = 'gameSessions';
  static const String childrenCollection = 'children';

  /// Start tracking an activity session
  Future<String> startActivitySession({
    required String childId,
    required String activityId,
    required GameType gameType,
  }) async {
    try {
      final sessionId = _firestore.collection(gameSessionsCollection).doc().id;
      final now = DateTime.now();

      await _firestore.collection(gameSessionsCollection).doc(sessionId).set({
        'id': sessionId,
        'childId': childId,
        'activityId': activityId,
        'gameType': gameType.name,
        'startedAt': Timestamp.fromDate(now),
        'questionsAnswered': [],
        'totalScore': 0,
        'totalPointsEarned': 0,
        'timeSpentSeconds': 0,
        'isCompleted': false,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint('✅ Started activity session: $sessionId');
      return sessionId;
    } catch (e) {
      debugPrint('❌ Error starting activity session: $e');
      rethrow;
    }
  }

  /// Record a question answer with tracking
  Future<void> recordQuestionAnswer({
    required String sessionId,
    required String questionId,
    required String questionTemplateId,
    required dynamic userAnswer,
    required dynamic correctAnswer,
    required bool isCorrect,
    required int pointsEarned,
    required int timeSpentSeconds,
  }) async {
    try {
      final response = GameResponse(
        id: _firestore.collection('gameResponses').doc().id,
        questionId: questionId,
        questionTemplateId: questionTemplateId,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
        isCorrect: isCorrect,
        pointsEarned: isCorrect ? pointsEarned : 0,
        timeSpentSeconds: timeSpentSeconds,
        answeredAt: DateTime.now(),
        responseMetadata: {
          'sessionId': sessionId,
          'answeredAt': DateTime.now().toIso8601String(),
        },
      );

      // Update session document
      await _firestore
          .collection(gameSessionsCollection)
          .doc(sessionId)
          .update({
        'questionsAnswered': FieldValue.arrayUnion([response.toJson()]),
        'totalScore': FieldValue.increment(isCorrect ? 1 : 0),
        'totalPointsEarned': FieldValue.increment(isCorrect ? pointsEarned : 0),
        'timeSpentSeconds': FieldValue.increment(timeSpentSeconds),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
          '✅ Recorded question answer: $questionId (Correct: $isCorrect)');
    } catch (e) {
      debugPrint('❌ Error recording question answer: $e');
      rethrow;
    }
  }

  /// Complete an activity session and update child progress
  Future<void> completeActivitySession({
    required String sessionId,
    required String childId,
    required String activityId,
    required int totalScore,
    required int totalPoints,
    required int totalPointsEarned,
    required int totalTimeSeconds,
    required List<GameResponse> allResponses,
  }) async {
    try {
      final now = DateTime.now();

      // Mark session as completed
      await _firestore
          .collection(gameSessionsCollection)
          .doc(sessionId)
          .update({
        'isCompleted': true,
        'completedAt': Timestamp.fromDate(now),
        'totalScore': totalScore,
        'totalPoints': totalPoints,
        'totalPointsEarned': totalPointsEarned,
        'timeSpentSeconds': totalTimeSeconds,
        'updatedAt': Timestamp.fromDate(now),
      });

      // Update activity progress
      await _updateActivityProgress(
        childId: childId,
        activityId: activityId,
        score: totalScore,
        totalPoints: totalPoints,
        pointsEarned: totalPointsEarned,
        timeSpentSeconds: totalTimeSeconds,
        isCompleted: true,
      );

      // Update child's coin balance
      await _updateChildCoins(childId: childId, coinsEarned: totalPointsEarned);

      // Update child's overall progress
      await _progressService.addCompletedLesson(
        childId: childId,
        lessonId: activityId,
        score: totalScore,
        timeSpentMinutes: (totalTimeSeconds / 60).round(),
        pointsEarned: totalPointsEarned,
      );

      debugPrint('✅ Completed activity session: $sessionId');
      debugPrint('💰 Child earned $totalPointsEarned coins');
    } catch (e) {
      debugPrint('❌ Error completing activity session: $e');
      rethrow;
    }
  }

  /// Update activity progress document
  Future<void> _updateActivityProgress({
    required String childId,
    required String activityId,
    required int score,
    required int totalPoints,
    required int pointsEarned,
    required int timeSpentSeconds,
    required bool isCompleted,
  }) async {
    try {
      final progressDocId = '${childId}_$activityId';
      final progressPercent =
          totalPoints > 0 ? (score / totalPoints) * 100 : 0.0;

      final progressData = {
        'id': progressDocId,
        'childId': childId,
        'activityId': activityId,
        'status': isCompleted ? 'completed' : 'in-progress',
        'progressPercent': progressPercent,
        'score': score,
        'totalPoints': totalPoints,
        'pointsEarned': pointsEarned,
        'timeSpentSeconds': timeSpentSeconds,
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
        if (isCompleted) 'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(activityProgressCollection)
          .doc(progressDocId)
          .set(progressData, SetOptions(merge: true));

      debugPrint('✅ Updated activity progress: $activityId');
    } catch (e) {
      debugPrint('❌ Error updating activity progress: $e');
      rethrow;
    }
  }

  /// Update child's coin balance in the database
  Future<void> _updateChildCoins({
    required String childId,
    required int coinsEarned,
  }) async {
    try {
      // Get current child profile
      final child = await _authService.getChildProfile(childId);
      if (child == null) {
        debugPrint('⚠️ Child not found: $childId');
        return;
      }

      // Calculate new coin balance
      final currentCoins = child.stats.totalPoints;
      final newCoins = currentCoins + coinsEarned;
      final newLevel = _calculateLevel(newCoins);

      // Update child stats
      final updatedStats = child.stats.copyWith(
        totalPoints: newCoins,
        level: newLevel,
        totalActivitiesCompleted: child.stats.totalActivitiesCompleted + 1,
        lastActivityAt: DateTime.now(),
      );

      // Update streak
      final updatedStatsWithStreak = _updateStreak(updatedStats);

      // Update child profile in database
      await _authService.updateChildProfile(
        child.copyWith(stats: updatedStatsWithStreak),
      );

      debugPrint(
          '💰 Updated child coins: $currentCoins → $newCoins (Level: $newLevel)');
    } catch (e) {
      debugPrint('❌ Error updating child coins: $e');
      // Don't rethrow - coin update failure shouldn't block completion
    }
  }

  /// Calculate level based on total points (100 points per level)
  int _calculateLevel(int totalPoints) {
    return (totalPoints / 100).floor() + 1;
  }

  /// Update streak based on last activity date
  ChildStats _updateStreak(ChildStats stats) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = stats.lastActivityAt;

    if (lastActivity == null) {
      return stats.copyWith(currentStreak: 1);
    }

    final lastActivityDay =
        DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
    final daysDiff = today.difference(lastActivityDay).inDays;

    int newStreak;
    if (daysDiff == 0) {
      // Same day - keep current streak
      newStreak = stats.currentStreak;
    } else if (daysDiff == 1) {
      // Consecutive day - increment streak
      newStreak = stats.currentStreak + 1;
    } else {
      // Streak broken - reset to 1
      newStreak = 1;
    }

    final newLongestStreak =
        newStreak > stats.longestStreak ? newStreak : stats.longestStreak;

    return stats.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
    );
  }

  /// Get activity progress for a child
  Future<ActivityProgress?> getActivityProgress({
    required String childId,
    required String activityId,
  }) async {
    try {
      final progressDocId = '${childId}_$activityId';
      final doc = await _firestore
          .collection(activityProgressCollection)
          .doc(progressDocId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ActivityProgress.fromJson({
        'id': progressDocId,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('❌ Error getting activity progress: $e');
      return null;
    }
  }

  /// Get all activity progress for a child
  Future<List<ActivityProgress>> getAllActivityProgress(String childId) async {
    try {
      final snapshot = await _firestore
          .collection(activityProgressCollection)
          .where('childId', isEqualTo: childId)
          .get();

      return snapshot.docs
          .map((doc) => ActivityProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting all activity progress: $e');
      return [];
    }
  }
}
