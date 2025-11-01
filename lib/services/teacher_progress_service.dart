import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/children_progress.dart';
import '../models/lesson.dart';
import '../models/teacher_assignment.dart';

/// Service for teachers to view children's progress in their groups
class TeacherProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String childrenProgressCollection = 'childrenProgress';
  static const String lessonsCollection = 'lessons';
  static const String teacherAssignmentsCollection = 'teacherAssignments';
  static const String childrenCollection = 'children';

  /// Get progress for all children in teacher's groups
  Future<List<ChildrenProgress>> getGroupProgress({
    required String teacherId,
    List<String>? childGroupIds,
  }) async {
    try {
      // If specific child group IDs are provided, use them
      if (childGroupIds != null && childGroupIds.isNotEmpty) {
        return await _getProgressForSpecificChildren(childGroupIds);
      }

      // Otherwise, get all children in teacher's groups
      final children = await _getTeacherChildren(teacherId);
      if (children.isEmpty) return [];

      final childIdsList =
          children.map((child) => child['id'] as String).toList();
      return await _getProgressForSpecificChildren(childIdsList);
    } catch (e) {
      debugPrint('Error getting group progress for teacher $teacherId: $e');
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

  /// Get all children in teacher's groups
  Future<List<Map<String, dynamic>>> _getTeacherChildren(
      String teacherId) async {
    try {
      // This would typically involve getting children from teacher's groups
      // For now, we'll get children from assignments created by this teacher
      final assignments = await _getTeacherAssignments(teacherId);
      final childIds = <String>{};

      for (final assignment in assignments) {
        childIds.addAll(assignment.childGroupIds);
      }

      if (childIds.isEmpty) return [];

      final snapshot = await _firestore
          .collection(childrenCollection)
          .where(FieldPath.documentId, whereIn: childIds.toList())
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error getting teacher children: $e');
      return [];
    }
  }

  /// Get teacher's assignments
  Future<List<TeacherAssignment>> _getTeacherAssignments(
      String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection(teacherAssignmentsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting teacher assignments: $e');
      return [];
    }
  }

  /// Get detailed progress for a specific child
  Future<Map<String, dynamic>?> getChildDetailedProgress({
    required String childId,
    required String teacherId,
  }) async {
    try {
      // Verify the teacher has access to this child
      final hasAccess = await _verifyTeacherAccess(teacherId, childId);
      if (!hasAccess) {
        throw Exception(
            'Access denied: Teacher does not have access to this child');
      }

      // Get child's progress
      final progress = await _getChildProgress(childId);
      if (progress == null) return null;

      // Get child details
      final child = await _getChild(childId);
      if (child == null) return null;

      // Get completed lessons details
      final completedLessons =
          await _getLessonsDetails(progress.completedLessons);

      // Get assignments for this child
      final assignments = await _getChildAssignments(childId);

      // Get lesson attempts and scores
      final lessonAttempts = progress.lessonAttempts;
      final lessonScores = progress.lessonScores;

      return {
        'child': child,
        'progress': progress,
        'completedLessons': completedLessons,
        'assignments': assignments,
        'lessonAttempts': lessonAttempts,
        'lessonScores': lessonScores,
        'statistics': _calculateChildStatistics(progress, completedLessons),
      };
    } catch (e) {
      debugPrint('Error getting detailed progress for child $childId: $e');
      return null;
    }
  }

  /// Verify teacher has access to a child
  Future<bool> _verifyTeacherAccess(String teacherId, String childId) async {
    try {
      final assignments = await _getTeacherAssignments(teacherId);
      return assignments
          .any((assignment) => assignment.childGroupIds.contains(childId));
    } catch (e) {
      debugPrint('Error verifying teacher access: $e');
      return false;
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

  /// Get group progress comparison
  Future<Map<String, dynamic>> getGroupProgressComparison({
    required String teacherId,
    List<String>? childGroupIds,
  }) async {
    try {
      final childrenProgress = await getGroupProgress(
        teacherId: teacherId,
        childGroupIds: childGroupIds,
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
      debugPrint('Error getting group progress comparison: $e');
      return {
        'children': [],
        'comparison': {},
        'leaderboard': [],
      };
    }
  }

  /// Get assignment progress for a specific assignment
  Future<Map<String, dynamic>> getAssignmentProgress({
    required String assignmentId,
    required String teacherId,
  }) async {
    try {
      // Get the assignment
      final assignment = await _getAssignment(assignmentId);
      if (assignment == null) {
        throw Exception('Assignment not found');
      }

      // Verify teacher has access to this assignment
      if (assignment.teacherId != teacherId) {
        throw Exception(
            'Access denied: Teacher does not have access to this assignment');
      }

      // Get progress for all children in the assignment
      final childrenProgress =
          await _getProgressForSpecificChildren(assignment.childGroupIds);

      // Get lesson details
      final lessons = await _getLessonsDetails(assignment.lessonIds);

      // Calculate completion statistics
      final completionStats = <String, Map<String, dynamic>>{};
      for (final lesson in lessons) {
        final completedCount = childrenProgress
            .where((progress) => progress.isLessonCompleted(lesson.id))
            .length;

        completionStats[lesson.id] = {
          'lesson': lesson,
          'totalChildren': childrenProgress.length,
          'completedCount': completedCount,
          'completionRate': childrenProgress.isEmpty
              ? 0.0
              : completedCount / childrenProgress.length,
        };
      }

      // Calculate overall assignment progress
      final totalLessons = lessons.length;
      final totalChildren = childrenProgress.length;
      final totalPossibleCompletions = totalLessons * totalChildren;
      final actualCompletions = childrenProgress.fold(0, (sum, progress) {
        return sum +
            assignment.lessonIds
                .where((lessonId) => progress.isLessonCompleted(lessonId))
                .length;
      });

      return {
        'assignment': assignment,
        'lessons': lessons,
        'childrenProgress': childrenProgress,
        'completionStats': completionStats,
        'overallProgress': {
          'totalLessons': totalLessons,
          'totalChildren': totalChildren,
          'totalPossibleCompletions': totalPossibleCompletions,
          'actualCompletions': actualCompletions,
          'completionRate': totalPossibleCompletions == 0
              ? 0.0
              : actualCompletions / totalPossibleCompletions,
        },
      };
    } catch (e) {
      debugPrint('Error getting assignment progress: $e');
      return {};
    }
  }

  /// Get assignment
  Future<TeacherAssignment?> _getAssignment(String assignmentId) async {
    try {
      final doc = await _firestore
          .collection(teacherAssignmentsCollection)
          .doc(assignmentId)
          .get();

      if (!doc.exists) return null;

      return TeacherAssignment.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting assignment $assignmentId: $e');
      return null;
    }
  }

  /// Get progress trends for a group over time
  Future<Map<String, dynamic>> getGroupProgressTrends({
    required String teacherId,
    List<String>? childGroupIds,
    int days = 30,
  }) async {
    try {
      final childrenProgress = await getGroupProgress(
        teacherId: teacherId,
        childGroupIds: childGroupIds,
      );

      if (childrenProgress.isEmpty) {
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
        var lessonsCompletedOnDate = 0;

        for (final progress in childrenProgress) {
          lessonsCompletedOnDate += progress.lessonCompletionDates.values
              .where((completionDate) => _isSameDay(completionDate, date))
              .length;
        }

        dailyProgress.add({
          'date': date,
          'lessonsCompleted': lessonsCompletedOnDate,
          'childrenActive': childrenProgress.where((progress) {
            return progress.lessonCompletionDates.values
                .any((completionDate) => _isSameDay(completionDate, date));
          }).length,
        });
      }

      // Calculate weekly progress
      final weeklyProgress = <Map<String, dynamic>>[];
      for (int i = (days / 7).ceil() - 1; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: (i + 1) * 7));
        final weekEnd = now.subtract(Duration(days: i * 7));

        var lessonsCompletedInWeek = 0;
        var childrenActiveInWeek = 0;

        for (final progress in childrenProgress) {
          final lessonsInWeek = progress.lessonCompletionDates.values
              .where((completionDate) =>
                  completionDate.isAfter(weekStart) &&
                  completionDate.isBefore(weekEnd))
              .length;

          if (lessonsInWeek > 0) {
            childrenActiveInWeek++;
            lessonsCompletedInWeek += lessonsInWeek;
          }
        }

        weeklyProgress.add({
          'weekStart': weekStart,
          'weekEnd': weekEnd,
          'lessonsCompleted': lessonsCompletedInWeek,
          'childrenActive': childrenActiveInWeek,
        });
      }

      return {
        'dailyProgress': dailyProgress,
        'weeklyProgress': weeklyProgress,
        'monthlyProgress': [], // Could be implemented similarly
      };
    } catch (e) {
      debugPrint('Error getting group progress trends: $e');
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

  /// Get group statistics
  Future<Map<String, dynamic>> getGroupStatistics({
    required String teacherId,
    List<String>? childGroupIds,
  }) async {
    try {
      final childrenProgress = await getGroupProgress(
        teacherId: teacherId,
        childGroupIds: childGroupIds,
      );

      if (childrenProgress.isEmpty) {
        return {
          'totalChildren': 0,
          'totalPoints': 0,
          'totalLessonsCompleted': 0,
          'averagePointsPerChild': 0.0,
          'averageLessonsPerChild': 0.0,
          'averageScore': 0.0,
        };
      }

      final totalPoints = childrenProgress.fold(
          0, (sum, progress) => sum + progress.earnedPoints);
      final totalLessonsCompleted = childrenProgress.fold(
          0, (sum, progress) => sum + progress.totalLessonsCompleted);
      final totalScores = childrenProgress.fold(
          0.0, (sum, progress) => sum + progress.averageScore);

      return {
        'totalChildren': childrenProgress.length,
        'totalPoints': totalPoints,
        'totalLessonsCompleted': totalLessonsCompleted,
        'averagePointsPerChild': totalPoints / childrenProgress.length,
        'averageLessonsPerChild':
            totalLessonsCompleted / childrenProgress.length,
        'averageScore': totalScores / childrenProgress.length,
      };
    } catch (e) {
      debugPrint('Error getting group statistics: $e');
      return {};
    }
  }
}
