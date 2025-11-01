import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/children_progress.dart';
import '../models/lesson.dart';
import '../models/teacher_assignment.dart';

/// Service for parents to view their children's progress
class ParentProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String childrenProgressCollection = 'childrenProgress';
  static const String lessonsCollection = 'lessons';
  static const String teacherAssignmentsCollection = 'teacherAssignments';
  static const String childrenCollection = 'children';

  /// Get progress for all children of a parent
  Future<List<ChildrenProgress>> getChildrenProgress({
    required String parentId,
    List<String>? childIds,
  }) async {
    try {
      // If specific child IDs are provided, use them
      if (childIds != null && childIds.isNotEmpty) {
        return await _getProgressForSpecificChildren(childIds);
      }

      // Otherwise, get all children for this parent
      final children = await _getParentChildren(parentId);
      if (children.isEmpty) return [];

      final childIdsList =
          children.map((child) => child['id'] as String).toList();
      return await _getProgressForSpecificChildren(childIdsList);
    } catch (e) {
      debugPrint('Error getting children progress for parent $parentId: $e');
      return [];
    }
  }

  /// Get progress for specific children
  Future<List<ChildrenProgress>> _getProgressForSpecificChildren(
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
      debugPrint('Error getting progress for specific children: $e');
      return [];
    }
  }

  /// Get all children for a parent
  Future<List<Map<String, dynamic>>> _getParentChildren(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection(childrenCollection)
          .where('parentId', isEqualTo: parentId)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error getting parent children: $e');
      return [];
    }
  }

  /// Get detailed progress for a specific child
  Future<Map<String, dynamic>?> getChildDetailedProgress({
    required String childId,
    required String parentId,
  }) async {
    try {
      // Verify the child belongs to this parent
      final child = await _getChild(childId);
      if (child == null || child['parentId'] != parentId) {
        throw Exception('Child not found or access denied');
      }

      // Get child's progress
      final progress = await _getChildProgress(childId);
      if (progress == null) return null;

      // Get completed lessons details
      final completedLessons =
          await _getLessonsDetails(progress.completedLessons);

      // Get assignments for this child
      final assignments = await _getChildAssignments(childId);

      return {
        'child': child,
        'progress': progress,
        'completedLessons': completedLessons,
        'assignments': assignments,
        'statistics': _calculateChildStatistics(progress, completedLessons),
      };
    } catch (e) {
      debugPrint('Error getting detailed progress for child $childId: $e');
      return null;
    }
  }

  /// Get a specific child
  Future<Map<String, dynamic>?> _getChild(String childId) async {
    try {
      final doc =
          await _firestore.collection(childrenCollection).doc(childId).get();
      if (!doc.exists) return null;

      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      debugPrint('Error getting child $childId: $e');
      return null;
    }
  }

  /// Get child's progress
  Future<ChildrenProgress?> _getChildProgress(String childId) async {
    try {
      final doc = await _firestore
          .collection(childrenProgressCollection)
          .doc(childId)
          .get();

      if (!doc.exists) return null;

      return ChildrenProgress.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting child progress $childId: $e');
      return null;
    }
  }

  /// Get lessons details
  Future<List<Lesson>> _getLessonsDetails(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(lessonsCollection)
          .where(FieldPath.documentId, whereIn: lessonIds)
          .get();

      return snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting lessons details: $e');
      return [];
    }
  }

  /// Get assignments for a child
  Future<List<TeacherAssignment>> _getChildAssignments(String childId) async {
    try {
      final snapshot = await _firestore
          .collection(teacherAssignmentsCollection)
          .where('childGroupIds', arrayContains: childId)
          .where('status', isEqualTo: AssignmentStatus.active.name)
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting child assignments: $e');
      return [];
    }
  }

  /// Calculate child statistics
  Map<String, dynamic> _calculateChildStatistics(
    ChildrenProgress progress,
    List<Lesson> completedLessons,
  ) {
    final totalPoints = progress.earnedPoints;
    final totalLessonsCompleted = progress.totalLessonsCompleted;
    final averageScore = progress.averageScore;
    final totalTimeSpent = progress.totalTimeSpent;

    // Calculate points by subject
    final pointsBySubject = <String, int>{};
    for (final lesson in completedLessons) {
      if (lesson.subject != null) {
        final subject = lesson.subject!;
        pointsBySubject[subject] =
            (pointsBySubject[subject] ?? 0) + lesson.rewardPoints;
      }
    }

    // Calculate completion rate by exercise type
    final completionByExerciseType = <String, int>{};
    for (final lesson in completedLessons) {
      final exerciseType = lesson.exerciseType.name;
      completionByExerciseType[exerciseType] =
          (completionByExerciseType[exerciseType] ?? 0) + 1;
    }

    // Calculate recent activity (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentActivity = progress.lessonCompletionDates.values
        .where((date) => date.isAfter(weekAgo))
        .length;

    return {
      'totalPoints': totalPoints,
      'totalLessonsCompleted': totalLessonsCompleted,
      'averageScore': averageScore,
      'totalTimeSpent': totalTimeSpent,
      'pointsBySubject': pointsBySubject,
      'completionByExerciseType': completionByExerciseType,
      'recentActivity': recentActivity,
      'lastActiveDate': progress.lastActiveDate,
    };
  }

  /// Get progress comparison between children
  Future<Map<String, dynamic>> getChildrenProgressComparison({
    required String parentId,
    List<String>? childIds,
  }) async {
    try {
      final childrenProgress = await getChildrenProgress(
        parentId: parentId,
        childIds: childIds,
      );

      if (childrenProgress.isEmpty) {
        return {
          'children': [],
          'comparison': {},
          'leaderboard': [],
        };
      }

      // Get children details
      final children = <Map<String, dynamic>>[];
      for (final progress in childrenProgress) {
        final child = await _getChild(progress.childId);
        if (child != null) {
          children.add({
            'id': child['id'],
            'name': child['name'],
            'progress': progress,
          });
        }
      }

      // Calculate comparison metrics
      final totalPoints =
          childrenProgress.fold(0, (sum, p) => sum + p.earnedPoints);
      final totalLessons =
          childrenProgress.fold(0, (sum, p) => sum + p.totalLessonsCompleted);
      final averagePoints = totalPoints / childrenProgress.length;
      final averageLessons = totalLessons / childrenProgress.length;

      // Create leaderboard
      final leaderboard = List<Map<String, dynamic>>.from(children);
      leaderboard.sort((a, b) {
        final aProgress = a['progress'] as ChildrenProgress;
        final bProgress = b['progress'] as ChildrenProgress;
        return bProgress.earnedPoints.compareTo(aProgress.earnedPoints);
      });

      return {
        'children': children,
        'comparison': {
          'totalPoints': totalPoints,
          'totalLessons': totalLessons,
          'averagePoints': averagePoints,
          'averageLessons': averageLessons,
          'childrenCount': childrenProgress.length,
        },
        'leaderboard': leaderboard,
      };
    } catch (e) {
      debugPrint('Error getting children progress comparison: $e');
      return {
        'children': [],
        'comparison': {},
        'leaderboard': [],
      };
    }
  }

  /// Get progress trends for a child over time
  Future<Map<String, dynamic>> getChildProgressTrends({
    required String childId,
    required String parentId,
    int days = 30,
  }) async {
    try {
      // Verify the child belongs to this parent
      final child = await _getChild(childId);
      if (child == null || child['parentId'] != parentId) {
        throw Exception('Child not found or access denied');
      }

      final progress = await _getChildProgress(childId);
      if (progress == null) {
        return {
          'dailyProgress': [],
          'weeklyProgress': [],
          'monthlyProgress': [],
        };
      }

      // Calculate daily progress for the last N days
      final now = DateTime.now();
      final dailyProgress = <Map<String, dynamic>>[];

      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final lessonsCompletedOnDate = progress.lessonCompletionDates.entries
            .where((entry) => _isSameDay(entry.value, date))
            .length;

        dailyProgress.add({
          'date': date,
          'lessonsCompleted': lessonsCompletedOnDate,
          'pointsEarned':
              0, // This would need to be calculated from lesson completion data
        });
      }

      // Calculate weekly progress
      final weeklyProgress = <Map<String, dynamic>>[];
      for (int i = (days / 7).ceil() - 1; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: (i + 1) * 7));
        final weekEnd = now.subtract(Duration(days: i * 7));

        final lessonsCompletedInWeek = progress.lessonCompletionDates.entries
            .where((entry) =>
                entry.value.isAfter(weekStart) && entry.value.isBefore(weekEnd))
            .length;

        weeklyProgress.add({
          'weekStart': weekStart,
          'weekEnd': weekEnd,
          'lessonsCompleted': lessonsCompletedInWeek,
        });
      }

      return {
        'dailyProgress': dailyProgress,
        'weeklyProgress': weeklyProgress,
        'monthlyProgress': [], // Could be implemented similarly
      };
    } catch (e) {
      debugPrint('Error getting child progress trends: $e');
      return {
        'dailyProgress': [],
        'weeklyProgress': [],
        'monthlyProgress': [],
      };
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get achievements for a child
  Future<List<Map<String, dynamic>>> getChildAchievements({
    required String childId,
    required String parentId,
  }) async {
    try {
      // Verify the child belongs to this parent
      final child = await _getChild(childId);
      if (child == null || child['parentId'] != parentId) {
        throw Exception('Child not found or access denied');
      }

      final progress = await _getChildProgress(childId);
      if (progress == null) return [];

      // This would typically come from an achievements system
      // For now, we'll create some basic achievements based on progress
      final achievements = <Map<String, dynamic>>[];

      // First lesson achievement
      if (progress.totalLessonsCompleted >= 1) {
        achievements.add({
          'id': 'first_lesson',
          'title': 'First Steps',
          'description': 'Completed your first lesson!',
          'icon': '🎉',
          'unlockedAt': progress.lessonCompletionDates.values.isNotEmpty
              ? progress.lessonCompletionDates.values.first
              : null,
        });
      }

      // Points milestones
      if (progress.earnedPoints >= 100) {
        achievements.add({
          'id': 'points_100',
          'title': 'Point Collector',
          'description': 'Earned 100 points!',
          'icon': '⭐',
          'unlockedAt': progress.lastActiveDate,
        });
      }

      if (progress.earnedPoints >= 500) {
        achievements.add({
          'id': 'points_500',
          'title': 'Point Master',
          'description': 'Earned 500 points!',
          'icon': '🏆',
          'unlockedAt': progress.lastActiveDate,
        });
      }

      // Lesson completion milestones
      if (progress.totalLessonsCompleted >= 10) {
        achievements.add({
          'id': 'lessons_10',
          'title': 'Learning Enthusiast',
          'description': 'Completed 10 lessons!',
          'icon': '📚',
          'unlockedAt': progress.lastActiveDate,
        });
      }

      return achievements;
    } catch (e) {
      debugPrint('Error getting child achievements: $e');
      return [];
    }
  }
}
