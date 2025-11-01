import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/children_progress.dart';
import '../models/user_type.dart';

/// Service for managing children's progress and points tracking
class ChildrenProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String childrenProgressCollection = 'childrenProgress';

  /// Get progress for a specific child
  Future<ChildrenProgress?> getChildProgress(String childId) async {
    try {
      final doc = await _firestore
          .collection(childrenProgressCollection)
          .doc(childId)
          .get();

      if (!doc.exists) {
        // Create initial progress record if it doesn't exist
        return await _createInitialProgress(childId);
      }

      return ChildrenProgress.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting child progress for $childId: $e');
      return null;
    }
  }

  /// Create initial progress record for a new child
  Future<ChildrenProgress?> _createInitialProgress(String childId) async {
    try {
      final now = DateTime.now();
      final initialProgress = ChildrenProgress(
        id: childId,
        childId: childId,
        lastActiveDate: now,
      );

      await _firestore
          .collection(childrenProgressCollection)
          .doc(childId)
          .set(initialProgress.toJson());

      return initialProgress;
    } catch (e) {
      debugPrint('Error creating initial progress for $childId: $e');
      return null;
    }
  }

  /// Update child progress (create if doesn't exist)
  Future<void> updateChildProgress(ChildrenProgress progress) async {
    try {
      await _firestore
          .collection(childrenProgressCollection)
          .doc(progress.childId)
          .set(progress.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating child progress for ${progress.childId}: $e');
      rethrow;
    }
  }

  /// Add a completed lesson to child's progress
  Future<void> addCompletedLesson({
    required String childId,
    required String lessonId,
    required int score,
    required int timeSpentMinutes,
    int pointsEarned = 0,
  }) async {
    try {
      final currentProgress = await getChildProgress(childId);
      if (currentProgress == null) {
        throw Exception('Could not retrieve or create child progress');
      }

      final updatedProgress = currentProgress.addCompletedLesson(
        lessonId: lessonId,
        score: score,
        timeSpentMinutes: timeSpentMinutes,
        pointsEarned: pointsEarned,
      );

      await updateChildProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error adding completed lesson for $childId: $e');
      rethrow;
    }
  }

  /// Add points to child's progress
  Future<void> addPoints({
    required String childId,
    required int points,
  }) async {
    try {
      final currentProgress = await getChildProgress(childId);
      if (currentProgress == null) {
        throw Exception('Could not retrieve or create child progress');
      }

      final updatedProgress = currentProgress.addPoints(points);
      await updateChildProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error adding points for $childId: $e');
      rethrow;
    }
  }

  /// Get progress for multiple children (for parents/teachers)
  Future<List<ChildrenProgress>> getChildrenProgress(
      List<String> childIds) async {
    if (childIds.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(childrenProgressCollection)
          .where(FieldPath.documentId, whereIn: childIds)
          .get();

      return snapshot.docs
          .map((doc) => ChildrenProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting children progress: $e');
      return [];
    }
  }

  /// Get all children's progress (admin only)
  Future<List<ChildrenProgress>> getAllChildrenProgress({
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(childrenProgressCollection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('lastActiveDate', descending: true);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ChildrenProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting all children progress: $e');
      return [];
    }
  }

  /// Get children progress by earned points range
  Future<List<ChildrenProgress>> getChildrenProgressByPointsRange({
    int? minPoints,
    int? maxPoints,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(childrenProgressCollection);

      if (minPoints != null) {
        query = query.where('earnedPoints', isGreaterThanOrEqualTo: minPoints);
      }

      if (maxPoints != null) {
        query = query.where('earnedPoints', isLessThanOrEqualTo: maxPoints);
      }

      query = query.orderBy('earnedPoints', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ChildrenProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting children progress by points range: $e');
      return [];
    }
  }

  /// Get children progress by completion percentage
  Future<List<ChildrenProgress>> getChildrenProgressByCompletion({
    required List<String> lessonIds,
    double? minCompletionPercentage,
    double? maxCompletionPercentage,
    int? limit,
  }) async {
    try {
      final allProgress = await getAllChildrenProgress();

      List<ChildrenProgress> filteredProgress = allProgress.where((progress) {
        final completionPercentage =
            progress.getCompletionPercentage(lessonIds);

        if (minCompletionPercentage != null &&
            completionPercentage < minCompletionPercentage) {
          return false;
        }

        if (maxCompletionPercentage != null &&
            completionPercentage > maxCompletionPercentage) {
          return false;
        }

        return true;
      }).toList();

      // Sort by completion percentage
      filteredProgress.sort((a, b) {
        final aCompletion = a.getCompletionPercentage(lessonIds);
        final bCompletion = b.getCompletionPercentage(lessonIds);
        return bCompletion.compareTo(aCompletion);
      });

      if (limit != null && filteredProgress.length > limit) {
        filteredProgress = filteredProgress.take(limit).toList();
      }

      return filteredProgress;
    } catch (e) {
      debugPrint('Error getting children progress by completion: $e');
      return [];
    }
  }

  /// Get leaderboard (top performers)
  Future<List<ChildrenProgress>> getLeaderboard({
    int limit = 10,
    String? orderBy, // 'earnedPoints', 'totalLessonsCompleted', 'averageScore'
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(childrenProgressCollection);

      switch (orderBy) {
        case 'totalLessonsCompleted':
          // This requires a composite index or client-side sorting
          final allProgress = await getAllChildrenProgress();
          allProgress.sort((a, b) =>
              b.totalLessonsCompleted.compareTo(a.totalLessonsCompleted));
          return allProgress.take(limit).toList();
        case 'averageScore':
          // This requires client-side sorting
          final allProgress = await getAllChildrenProgress();
          allProgress.sort((a, b) => b.averageScore.compareTo(a.averageScore));
          return allProgress.take(limit).toList();
        default:
          // Default to earned points
          query = query.orderBy('earnedPoints', descending: true);
          break;
      }

      if (orderBy == 'earnedPoints') {
        query = query.limit(limit);
        final snapshot = await query.get();
        return snapshot.docs
            .map((doc) => ChildrenProgress.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Get progress statistics
  Future<Map<String, dynamic>> getProgressStatistics() async {
    try {
      final allProgress = await getAllChildrenProgress();

      if (allProgress.isEmpty) {
        return {
          'totalChildren': 0,
          'totalPointsEarned': 0,
          'totalLessonsCompleted': 0,
          'averagePointsPerChild': 0.0,
          'averageLessonsPerChild': 0.0,
          'averageScore': 0.0,
        };
      }

      final totalPointsEarned =
          allProgress.fold(0, (sum, progress) => sum + progress.earnedPoints);
      final totalLessonsCompleted = allProgress.fold(
          0, (sum, progress) => sum + progress.totalLessonsCompleted);
      final totalScores =
          allProgress.fold(0.0, (sum, progress) => sum + progress.averageScore);

      return {
        'totalChildren': allProgress.length,
        'totalPointsEarned': totalPointsEarned,
        'totalLessonsCompleted': totalLessonsCompleted,
        'averagePointsPerChild': totalPointsEarned / allProgress.length,
        'averageLessonsPerChild': totalLessonsCompleted / allProgress.length,
        'averageScore': totalScores / allProgress.length,
      };
    } catch (e) {
      debugPrint('Error getting progress statistics: $e');
      return {};
    }
  }

  /// Reset child progress (admin only)
  Future<void> resetChildProgress({
    required String childId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can reset child progress');
    }

    try {
      final now = DateTime.now();
      final resetProgress = ChildrenProgress(
        id: childId,
        childId: childId,
        lastActiveDate: now,
      );

      await _firestore
          .collection(childrenProgressCollection)
          .doc(childId)
          .set(resetProgress.toJson());
    } catch (e) {
      debugPrint('Error resetting child progress for $childId: $e');
      rethrow;
    }
  }

  /// Delete child progress (admin only)
  Future<void> deleteChildProgress({
    required String childId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can delete child progress');
    }

    try {
      await _firestore
          .collection(childrenProgressCollection)
          .doc(childId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting child progress for $childId: $e');
      rethrow;
    }
  }

  /// Get progress for children in a specific group
  Future<List<ChildrenProgress>> getGroupProgress(
      List<String> childGroupIds) async {
    if (childGroupIds.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(childrenProgressCollection)
          .where(FieldPath.documentId, whereIn: childGroupIds)
          .get();

      return snapshot.docs
          .map((doc) => ChildrenProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting group progress: $e');
      return [];
    }
  }

  /// Update last active date for a child
  Future<void> updateLastActiveDate(String childId) async {
    try {
      await _firestore
          .collection(childrenProgressCollection)
          .doc(childId)
          .update({
        'lastActiveDate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating last active date for $childId: $e');
      // Don't rethrow as this is not critical
    }
  }
}


