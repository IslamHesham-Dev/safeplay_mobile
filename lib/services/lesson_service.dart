import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/lesson.dart';
import '../models/user_type.dart';

/// Service for managing lessons and lesson-related operations
class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String lessonsCollection = 'lessons';

  /// Get all lessons with optional filtering
  Future<List<Lesson>> getLessons({
    List<String>? ageGroupTargets,
    ExerciseType? exerciseType,
    MappedGameType? mappedGameType,
    String? subject,
    String? difficulty,
    bool? isActive,
    String? createdBy,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(lessonsCollection);

      // Apply filters
      if (ageGroupTargets != null && ageGroupTargets.isNotEmpty) {
        query =
            query.where('ageGroupTarget', arrayContainsAny: ageGroupTargets);
      }

      if (exerciseType != null) {
        query = query.where('exerciseType', isEqualTo: exerciseType.name);
      }

      if (mappedGameType != null) {
        query = query.where('mappedGameType', isEqualTo: mappedGameType.name);
      }

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (createdBy != null) {
        query = query.where('createdBy', isEqualTo: createdBy);
      }

      // Order by creation date
      query = query.orderBy('createdAt', descending: true);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting lessons: $e');
      return [];
    }
  }

  /// Get lessons suitable for a specific age group
  Future<List<Lesson>> getLessonsForAgeGroup(String ageGroup) async {
    try {
      final snapshot = await _firestore
          .collection(lessonsCollection)
          .where('ageGroupTarget', arrayContains: ageGroup)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting lessons for age group $ageGroup: $e');
      return [];
    }
  }

  /// Get lessons suitable for a specific age group enum
  Future<List<Lesson>> getLessonsForAgeGroupEnum(AgeGroup ageGroup) async {
    final ageGroupString = _ageGroupToString(ageGroup);
    return getLessonsForAgeGroup(ageGroupString);
  }

  /// Get a specific lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      final doc =
          await _firestore.collection(lessonsCollection).doc(lessonId).get();
      if (!doc.exists) return null;

      return Lesson.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting lesson $lessonId: $e');
      return null;
    }
  }

  /// Create a new lesson
  Future<String> createLesson({
    required Lesson lesson,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can create lessons');
    }

    _validateLesson(lesson);

    try {
      final docRef = _firestore.collection(lessonsCollection).doc();
      final now = DateTime.now();

      final lessonData = lesson.toJson()
        ..remove('id')
        ..['id'] = docRef.id
        ..['createdAt'] = Timestamp.fromDate(now)
        ..['updatedAt'] = Timestamp.fromDate(now);

      await docRef.set(lessonData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating lesson: $e');
      rethrow;
    }
  }

  /// Update an existing lesson
  Future<void> updateLesson({
    required Lesson lesson,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can update lessons');
    }

    _validateLesson(lesson);

    try {
      final lessonData = lesson.toJson()
        ..['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection(lessonsCollection)
          .doc(lesson.id)
          .set(lessonData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating lesson ${lesson.id}: $e');
      rethrow;
    }
  }

  /// Delete a lesson (soft delete by setting isActive to false)
  Future<void> deleteLesson({
    required String lessonId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can delete lessons');
    }

    try {
      await _firestore.collection(lessonsCollection).doc(lessonId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error deleting lesson $lessonId: $e');
      rethrow;
    }
  }

  /// Permanently delete a lesson from the database
  Future<void> permanentlyDeleteLesson({
    required String lessonId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can permanently delete lessons');
    }

    try {
      await _firestore.collection(lessonsCollection).doc(lessonId).delete();
    } catch (e) {
      debugPrint('Error permanently deleting lesson $lessonId: $e');
      rethrow;
    }
  }

  /// Get lessons by IDs
  Future<List<Lesson>> getLessonsByIds(List<String> lessonIds) async {
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
      debugPrint('Error getting lessons by IDs: $e');
      return [];
    }
  }

  /// Search lessons by title or description
  Future<List<Lesson>> searchLessons({
    required String searchQuery,
    List<String>? ageGroupTargets,
    ExerciseType? exerciseType,
    MappedGameType? mappedGameType,
    String? subject,
    int? limit,
  }) async {
    try {
      // Note: This is a basic implementation. For better search functionality,
      // consider using Algolia or implementing full-text search with Firestore
      Query<Map<String, dynamic>> query =
          _firestore.collection(lessonsCollection);

      // Apply filters
      if (ageGroupTargets != null && ageGroupTargets.isNotEmpty) {
        query =
            query.where('ageGroupTarget', arrayContainsAny: ageGroupTargets);
      }

      if (exerciseType != null) {
        query = query.where('exerciseType', isEqualTo: exerciseType.name);
      }

      if (mappedGameType != null) {
        query = query.where('mappedGameType', isEqualTo: mappedGameType.name);
      }

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      query = query.where('isActive', isEqualTo: true);
      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final allLessons = snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Filter by search query (client-side filtering)
      final searchLower = searchQuery.toLowerCase();
      return allLessons.where((lesson) {
        return lesson.title.toLowerCase().contains(searchLower) ||
            (lesson.description?.toLowerCase().contains(searchLower) ??
                false) ||
            lesson.learningObjectives.any(
                (objective) => objective.toLowerCase().contains(searchLower)) ||
            lesson.skills
                .any((skill) => skill.toLowerCase().contains(searchLower));
      }).toList();
    } catch (e) {
      debugPrint('Error searching lessons: $e');
      return [];
    }
  }

  /// Get lessons created by a specific teacher
  Future<List<Lesson>> getLessonsByTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection(lessonsCollection)
          .where('createdBy', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting lessons by teacher $teacherId: $e');
      return [];
    }
  }

  /// Get lesson statistics
  Future<Map<String, dynamic>> getLessonStatistics() async {
    try {
      final snapshot = await _firestore.collection(lessonsCollection).get();
      final lessons = snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      final totalLessons = lessons.length;
      final activeLessons = lessons.where((l) => l.isActive).length;
      final inactiveLessons = totalLessons - activeLessons;

      // Count by exercise type
      final exerciseTypeCounts = <String, int>{};
      for (final lesson in lessons) {
        final type = lesson.exerciseType.name;
        exerciseTypeCounts[type] = (exerciseTypeCounts[type] ?? 0) + 1;
      }

      // Count by mapped game type
      final gameTypeCounts = <String, int>{};
      for (final lesson in lessons) {
        final type = lesson.mappedGameType.name;
        gameTypeCounts[type] = (gameTypeCounts[type] ?? 0) + 1;
      }

      // Count by age group
      final ageGroupCounts = <String, int>{};
      for (final lesson in lessons) {
        for (final ageGroup in lesson.ageGroupTarget) {
          ageGroupCounts[ageGroup] = (ageGroupCounts[ageGroup] ?? 0) + 1;
        }
      }

      return {
        'totalLessons': totalLessons,
        'activeLessons': activeLessons,
        'inactiveLessons': inactiveLessons,
        'exerciseTypeCounts': exerciseTypeCounts,
        'gameTypeCounts': gameTypeCounts,
        'ageGroupCounts': ageGroupCounts,
      };
    } catch (e) {
      debugPrint('Error getting lesson statistics: $e');
      return {};
    }
  }

  /// Convert AgeGroup enum to string format
  String _ageGroupToString(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.junior:
        return '6-8';
      case AgeGroup.bright:
        return '9-12';
    }
  }

  /// Validate lesson data
  void _validateLesson(Lesson lesson) {
    if (lesson.title.trim().isEmpty) {
      throw Exception('Lesson title cannot be empty');
    }

    if (lesson.ageGroupTarget.isEmpty) {
      throw Exception('Lesson must have at least one age group target');
    }

    if (lesson.rewardPoints < 0) {
      throw Exception('Reward points cannot be negative');
    }

    // Validate age group format
    for (final ageGroup in lesson.ageGroupTarget) {
      if (!RegExp(r'^\d+-\d+$').hasMatch(ageGroup)) {
        throw Exception(
            'Invalid age group format: $ageGroup. Expected format: "6-8" or "9-12"');
      }
    }
  }
}
