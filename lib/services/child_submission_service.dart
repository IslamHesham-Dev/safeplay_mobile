import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import '../models/game_activity.dart';

/// Service for managing child game submissions and progress tracking
class ChildSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String gameSessionsCollection = 'gameSessions';
  static const String gameResponsesCollection = 'gameResponses';
  static const String childProgressCollection = 'childProgress';

  /// Start a new game session for a child
  Future<String> startGameSession({
    required String childId,
    required String gameActivityId,
    required GameType gameType,
  }) async {
    try {
      final sessionId = _generateSessionId();
      final now = DateTime.now();

      final session = GameSessionProgress(
        id: sessionId,
        childId: childId,
        gameActivityId: gameActivityId,
        sessionId: sessionId,
        gameType: gameType,
        gameState: {},
        responses: [],
        currentLevel: 1,
        pointsEarned: 0,
        timeSpentSeconds: 0,
        startedAt: now,
        isCompleted: false,
        metadata: {
          'deviceInfo': 'mobile',
          'appVersion': '1.0.0',
        },
      );

      await _firestore
          .collection(gameSessionsCollection)
          .doc(sessionId)
          .set(session.toJson());

      debugPrint('Game session started: $sessionId');
      return sessionId;
    } catch (e) {
      debugPrint('Error starting game session: $e');
      rethrow;
    }
  }

  /// Save a game response from the child
  Future<void> saveGameResponse(GameResponse response) async {
    try {
      await _firestore
          .collection(gameResponsesCollection)
          .doc(response.id)
          .set(response.toJson());

      debugPrint('Game response saved: ${response.id}');
    } catch (e) {
      debugPrint('Error saving game response: $e');
      rethrow;
    }
  }

  /// Update game session progress
  Future<void> updateGameSession({
    required String sessionId,
    required Map<String, dynamic> gameState,
    required List<GameResponse> responses,
    required int currentLevel,
    required int pointsEarned,
    required int timeSpentSeconds,
  }) async {
    try {
      await _firestore
          .collection(gameSessionsCollection)
          .doc(sessionId)
          .update({
        'gameState': gameState,
        'responses': responses.map((r) => r.toJson()).toList(),
        'currentLevel': currentLevel,
        'pointsEarned': pointsEarned,
        'timeSpentSeconds': timeSpentSeconds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Game session updated: $sessionId');
    } catch (e) {
      debugPrint('Error updating game session: $e');
      rethrow;
    }
  }

  /// Mark a game session as completed
  Future<void> completeGameSession({
    required String sessionId,
    required int finalPoints,
    required int totalTimeSeconds,
  }) async {
    try {
      await _firestore
          .collection(gameSessionsCollection)
          .doc(sessionId)
          .update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
        'pointsEarned': finalPoints,
        'timeSpentSeconds': totalTimeSeconds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Game session completed: $sessionId');
    } catch (e) {
      debugPrint('Error completing game session: $e');
      rethrow;
    }
  }

  /// Mark an activity as completed for a child
  Future<void> markActivityCompleted(String activityId, String childId) async {
    try {
      final progressId = '${childId}_$activityId';

      await _firestore.collection(childProgressCollection).doc(progressId).set({
        'childId': childId,
        'activityId': activityId,
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint(
          'Activity marked as completed: $activityId for child $childId');
    } catch (e) {
      debugPrint('Error marking activity as completed: $e');
      rethrow;
    }
  }

  /// Get child's progress for all activities
  Future<List<GameSessionProgress>> getChildProgress(String childId) async {
    try {
      final snapshot = await _firestore
          .collection(gameSessionsCollection)
          .where('childId', isEqualTo: childId)
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GameSessionProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting child progress: $e');
      return [];
    }
  }

  /// Get child's progress for a specific activity
  Future<List<GameSessionProgress>> getChildActivityProgress({
    required String childId,
    required String activityId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(gameSessionsCollection)
          .where('childId', isEqualTo: childId)
          .where('gameActivityId', isEqualTo: activityId)
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GameSessionProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting child activity progress: $e');
      return [];
    }
  }

  /// Get child's game responses for analysis
  Future<List<GameResponse>> getChildResponses({
    required String childId,
    String? activityId,
    String? sessionId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(gameResponsesCollection)
          .where('childId', isEqualTo: childId);

      if (activityId != null) {
        query = query.where('activityId', isEqualTo: activityId);
      }

      if (sessionId != null) {
        query = query.where('sessionId', isEqualTo: sessionId);
      }

      final snapshot =
          await query.orderBy('answeredAt', descending: true).get();

      return snapshot.docs
          .map((doc) => GameResponse.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting child responses: $e');
      return [];
    }
  }

  /// Get child's learning analytics
  Future<ChildLearningAnalytics> getChildAnalytics(String childId) async {
    try {
      final progress = await getChildProgress(childId);
      final responses = await getChildResponses(childId: childId);

      final completedSessions = progress.where((p) => p.isCompleted).length;
      final totalPoints = progress.fold(0, (sum, p) => sum + p.pointsEarned);
      final totalTimeSpent =
          progress.fold(0, (sum, p) => sum + p.timeSpentSeconds);

      final correctResponses = responses.where((r) => r.isCorrect).length;
      final totalResponses = responses.length;
      final accuracy =
          totalResponses > 0 ? (correctResponses / totalResponses) * 100 : 0.0;

      // Calculate average time per question
      final totalQuestionTime =
          responses.fold(0, (sum, r) => sum + r.timeSpentSeconds);
      final avgTimePerQuestion =
          responses.isNotEmpty ? totalQuestionTime / responses.length : 0.0;

      // Get most challenging game types
      final gameTypeStats = <GameType, int>{};
      for (final response in responses) {
        final session = progress.firstWhere(
          (p) => p.responses.any((r) => r.id == response.id),
          orElse: () => progress.first,
        );
        gameTypeStats[session.gameType] =
            (gameTypeStats[session.gameType] ?? 0) + 1;
      }

      final mostPlayedGameType = gameTypeStats.isNotEmpty
          ? gameTypeStats.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : null;

      return ChildLearningAnalytics(
        childId: childId,
        totalSessions: progress.length,
        completedSessions: completedSessions,
        totalPoints: totalPoints,
        totalTimeSpent: totalTimeSpent,
        accuracy: accuracy,
        averageTimePerQuestion: avgTimePerQuestion,
        mostPlayedGameType: mostPlayedGameType,
        totalResponses: totalResponses,
        correctResponses: correctResponses,
        lastPlayedAt: progress.isNotEmpty ? progress.first.startedAt : null,
      );
    } catch (e) {
      debugPrint('Error getting child analytics: $e');
      return ChildLearningAnalytics(
        childId: childId,
        totalSessions: 0,
        completedSessions: 0,
        totalPoints: 0,
        totalTimeSpent: 0,
        accuracy: 0.0,
        averageTimePerQuestion: 0.0,
        mostPlayedGameType: null,
        totalResponses: 0,
        correctResponses: 0,
        lastPlayedAt: null,
      );
    }
  }

  /// Get leaderboard for a specific game type
  Future<List<ChildLeaderboardEntry>> getLeaderboard({
    required GameType gameType,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(gameSessionsCollection)
          .where('gameType', isEqualTo: gameType.name)
          .where('isCompleted', isEqualTo: true)
          .orderBy('pointsEarned', descending: true)
          .limit(limit)
          .get();

      final leaderboard = <ChildLeaderboardEntry>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final childId = data['childId'] as String;

        // Get child name (you might want to fetch this from a separate collection)
        final childName = await _getChildName(childId);

        leaderboard.add(ChildLeaderboardEntry(
          childId: childId,
          childName: childName,
          points: data['pointsEarned'] as int? ?? 0,
          timeSpent: data['timeSpentSeconds'] as int? ?? 0,
          completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
        ));
      }

      return leaderboard;
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Get child name from user profile
  Future<String> _getChildName(String childId) async {
    try {
      final doc = await _firestore.collection('users').doc(childId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return data['name'] as String? ?? 'Unknown Player';
      }

      return 'Unknown Player';
    } catch (e) {
      debugPrint('Error getting child name: $e');
      return 'Unknown Player';
    }
  }

  /// Generate a unique session ID
  String _generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'session_${timestamp}_$randomSuffix';
  }

  /// Clean up old incomplete sessions (call this periodically)
  Future<void> cleanupOldSessions({int daysOld = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final snapshot = await _firestore
          .collection(gameSessionsCollection)
          .where('isCompleted', isEqualTo: false)
          .where('startedAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint('Cleaned up ${snapshot.docs.length} old incomplete sessions');
    } catch (e) {
      debugPrint('Error cleaning up old sessions: $e');
    }
  }
}

/// Child learning analytics model
class ChildLearningAnalytics {
  final String childId;
  final int totalSessions;
  final int completedSessions;
  final int totalPoints;
  final int totalTimeSpent;
  final double accuracy;
  final double averageTimePerQuestion;
  final GameType? mostPlayedGameType;
  final int totalResponses;
  final int correctResponses;
  final DateTime? lastPlayedAt;

  const ChildLearningAnalytics({
    required this.childId,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalPoints,
    required this.totalTimeSpent,
    required this.accuracy,
    required this.averageTimePerQuestion,
    this.mostPlayedGameType,
    required this.totalResponses,
    required this.correctResponses,
    this.lastPlayedAt,
  });

  double get completionRate {
    return totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0.0;
  }

  Duration get totalTimeSpentDuration {
    return Duration(seconds: totalTimeSpent);
  }

  Duration get averageTimePerQuestionDuration {
    return Duration(seconds: averageTimePerQuestion.round());
  }
}

/// Child leaderboard entry model
class ChildLeaderboardEntry {
  final String childId;
  final String childName;
  final int points;
  final int timeSpent;
  final DateTime? completedAt;

  const ChildLeaderboardEntry({
    required this.childId,
    required this.childName,
    required this.points,
    required this.timeSpent,
    this.completedAt,
  });

  Duration get timeSpentDuration {
    return Duration(seconds: timeSpent);
  }
}
