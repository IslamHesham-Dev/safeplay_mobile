import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import 'lesson_service.dart';

/// Service for filtering lessons specifically for Junior (6-8) age group
class JuniorLessonFilterService {
  final LessonService _lessonService = LessonService();

  /// Get lessons filtered for Junior age group only
  Future<List<Lesson>> getJuniorLessons({
    ExerciseType? exerciseType,
    MappedGameType? mappedGameType,
    String? subject,
    String? difficulty,
    bool? isActive,
    String? createdBy,
    int? limit,
  }) async {
    try {
      // Get all lessons and filter for Junior age group
      final allLessons = await _lessonService.getLessons(
        ageGroupTargets: ['6-8'], // Junior age group
        exerciseType: exerciseType,
        mappedGameType: mappedGameType,
        subject: subject,
        difficulty: difficulty,
        isActive: isActive,
        createdBy: createdBy,
        limit: limit,
      );

      // Additional filtering for Junior-specific requirements
      final juniorLessons = allLessons.where((lesson) {
        return _isSuitableForJunior(lesson);
      }).toList();

      return juniorLessons;
    } catch (e) {
      debugPrint('Error getting Junior lessons: $e');
      return [];
    }
  }

  /// Get today's tasks for Junior (filtered and limited)
  Future<List<Lesson>> getTodaysTasks({
    required String childId,
    int maxTasks = 5,
  }) async {
    try {
      // Get Junior lessons
      final juniorLessons = await getJuniorLessons(
        isActive: true,
        limit: maxTasks * 2, // Get more to filter from
      );

      // Filter lessons that are appropriate for today's tasks
      final todaysTasks = juniorLessons
          .where((lesson) {
            return _isSuitableForTodaysTasks(lesson);
          })
          .take(maxTasks)
          .toList();

      return todaysTasks;
    } catch (e) {
      debugPrint('Error getting today\'s tasks for Junior: $e');
      return [];
    }
  }

  /// Get lessons by exercise type for Junior
  Future<List<Lesson>> getJuniorLessonsByExerciseType(
      ExerciseType exerciseType) async {
    return getJuniorLessons(exerciseType: exerciseType);
  }

  /// Get lessons by game type for Junior
  Future<List<Lesson>> getJuniorLessonsByGameType(
      MappedGameType gameType) async {
    return getJuniorLessons(mappedGameType: gameType);
  }

  /// Get lessons by subject for Junior
  Future<List<Lesson>> getJuniorLessonsBySubject(String subject) async {
    return getJuniorLessons(subject: subject);
  }

  /// Get lessons by difficulty for Junior
  Future<List<Lesson>> getJuniorLessonsByDifficulty(String difficulty) async {
    return getJuniorLessons(difficulty: difficulty);
  }

  /// Search lessons for Junior with age-appropriate filtering
  Future<List<Lesson>> searchJuniorLessons({
    required String searchQuery,
    ExerciseType? exerciseType,
    MappedGameType? mappedGameType,
    String? subject,
    int? limit,
  }) async {
    try {
      // Search with Junior age group filter
      final searchResults = await _lessonService.searchLessons(
        searchQuery: searchQuery,
        ageGroupTargets: ['6-8'],
        exerciseType: exerciseType,
        mappedGameType: mappedGameType,
        subject: subject,
        limit: limit,
      );

      // Additional filtering for Junior-specific requirements
      final juniorSearchResults = searchResults.where((lesson) {
        return _isSuitableForJunior(lesson);
      }).toList();

      return juniorSearchResults;
    } catch (e) {
      debugPrint('Error searching Junior lessons: $e');
      return [];
    }
  }

  /// Get recommended lessons for Junior based on progress
  Future<List<Lesson>> getRecommendedLessons({
    required String childId,
    List<String>? completedLessonIds,
    int limit = 3,
  }) async {
    try {
      final juniorLessons = await getJuniorLessons(isActive: true);

      // Filter out completed lessons
      final availableLessons = juniorLessons.where((lesson) {
        return completedLessonIds == null ||
            !completedLessonIds.contains(lesson.id);
      }).toList();

      // Sort by difficulty and reward points for recommendations
      availableLessons.sort((a, b) {
        // Prioritize easier lessons for Junior
        final difficultyOrder = {'easy': 0, 'medium': 1, 'hard': 2};
        final aDifficulty = difficultyOrder[a.difficulty] ?? 1;
        final bDifficulty = difficultyOrder[b.difficulty] ?? 1;

        if (aDifficulty != bDifficulty) {
          return aDifficulty.compareTo(bDifficulty);
        }

        // Then by reward points (higher first)
        return b.rewardPoints.compareTo(a.rewardPoints);
      });

      return availableLessons.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting recommended lessons for Junior: $e');
      return [];
    }
  }

  /// Check if a lesson is suitable for Junior age group
  bool _isSuitableForJunior(Lesson lesson) {
    // Must target Junior age group
    if (!lesson.ageGroupTarget.contains('6-8')) {
      return false;
    }

    // Must be active
    if (!lesson.isActive) {
      return false;
    }

    // Check for age-appropriate content
    if (!_hasAgeAppropriateContent(lesson)) {
      return false;
    }

    // Check for appropriate difficulty
    if (!_hasAppropriateDifficulty(lesson)) {
      return false;
    }

    return true;
  }

  /// Check if lesson has age-appropriate content for Junior
  bool _hasAgeAppropriateContent(Lesson lesson) {
    // Check title length (should be short for Junior)
    if (lesson.title.length > 30) {
      return false;
    }

    // Check learning objectives (should be simple)
    for (final objective in lesson.learningObjectives) {
      if (objective.length > 50) {
        return false;
      }
    }

    // Check skills (should be basic)
    final basicSkills = [
      'counting',
      'addition',
      'subtraction',
      'reading',
      'writing',
      'colors',
      'shapes',
      'letters',
      'numbers',
      'animals',
      'nature',
      'family',
      'friends',
      'sharing',
      'listening'
    ];

    final hasBasicSkills = lesson.skills.any((skill) => basicSkills
        .any((basic) => skill.toLowerCase().contains(basic.toLowerCase())));

    if (!hasBasicSkills && lesson.skills.isNotEmpty) {
      return false;
    }

    return true;
  }

  /// Check if lesson has appropriate difficulty for Junior
  bool _hasAppropriateDifficulty(Lesson lesson) {
    // Junior should focus on easy and some medium difficulty
    if (lesson.difficulty == 'hard') {
      return false;
    }

    // Check reward points (should be reasonable for Junior)
    if (lesson.rewardPoints > 100) {
      return false;
    }

    return true;
  }

  /// Check if lesson is suitable for today's tasks
  bool _isSuitableForTodaysTasks(Lesson lesson) {
    // Must be suitable for Junior
    if (!_isSuitableForJunior(lesson)) {
      return false;
    }

    // Should be easy or medium difficulty for daily tasks
    if (lesson.difficulty == 'hard') {
      return false;
    }

    // Should have reasonable duration (estimated by reward points)
    if (lesson.rewardPoints < 10 || lesson.rewardPoints > 50) {
      return false;
    }

    // Should be engaging for daily tasks
    if (lesson.exerciseType == ExerciseType.puzzle &&
        lesson.difficulty == 'medium') {
      return false; // Puzzles might be too complex for daily tasks
    }

    return true;
  }

  /// Get lesson statistics for Junior age group
  Future<Map<String, dynamic>> getJuniorLessonStatistics() async {
    try {
      final juniorLessons = await getJuniorLessons();

      if (juniorLessons.isEmpty) {
        return {
          'totalLessons': 0,
          'exerciseTypeDistribution': {},
          'gameTypeDistribution': {},
          'subjectDistribution': {},
          'difficultyDistribution': {},
          'averageRewardPoints': 0.0,
        };
      }

      // Calculate distributions
      final exerciseTypeDistribution = <String, int>{};
      final gameTypeDistribution = <String, int>{};
      final subjectDistribution = <String, int>{};
      final difficultyDistribution = <String, int>{};
      int totalRewardPoints = 0;

      for (final lesson in juniorLessons) {
        // Exercise type distribution
        final exerciseType = lesson.exerciseType.name;
        exerciseTypeDistribution[exerciseType] =
            (exerciseTypeDistribution[exerciseType] ?? 0) + 1;

        // Game type distribution
        final gameType = lesson.mappedGameType.name;
        gameTypeDistribution[gameType] =
            (gameTypeDistribution[gameType] ?? 0) + 1;

        // Subject distribution
        if (lesson.subject != null) {
          final subject = lesson.subject!;
          subjectDistribution[subject] =
              (subjectDistribution[subject] ?? 0) + 1;
        }

        // Difficulty distribution
        if (lesson.difficulty != null) {
          final difficulty = lesson.difficulty!;
          difficultyDistribution[difficulty] =
              (difficultyDistribution[difficulty] ?? 0) + 1;
        }

        // Total reward points
        totalRewardPoints += lesson.rewardPoints;
      }

      return {
        'totalLessons': juniorLessons.length,
        'exerciseTypeDistribution': exerciseTypeDistribution,
        'gameTypeDistribution': gameTypeDistribution,
        'subjectDistribution': subjectDistribution,
        'difficultyDistribution': difficultyDistribution,
        'averageRewardPoints': totalRewardPoints / juniorLessons.length,
      };
    } catch (e) {
      debugPrint('Error getting Junior lesson statistics: $e');
      return {};
    }
  }

  /// Get popular lessons for Junior (based on completion rates)
  Future<List<Lesson>> getPopularJuniorLessons({
    int limit = 5,
  }) async {
    try {
      final juniorLessons = await getJuniorLessons(isActive: true);

      // Sort by reward points (higher reward = more popular)
      juniorLessons.sort((a, b) => b.rewardPoints.compareTo(a.rewardPoints));

      return juniorLessons.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting popular Junior lessons: $e');
      return [];
    }
  }

  /// Filter lessons by completion status for a specific child
  Future<Map<String, List<Lesson>>> getLessonsByCompletionStatus({
    required String childId,
    List<String>? completedLessonIds,
  }) async {
    try {
      final juniorLessons = await getJuniorLessons(isActive: true);

      final completedLessons = <Lesson>[];
      final availableLessons = <Lesson>[];

      for (final lesson in juniorLessons) {
        if (completedLessonIds != null &&
            completedLessonIds.contains(lesson.id)) {
          completedLessons.add(lesson);
        } else {
          availableLessons.add(lesson);
        }
      }

      return {
        'completed': completedLessons,
        'available': availableLessons,
      };
    } catch (e) {
      debugPrint('Error getting lessons by completion status: $e');
      return {'completed': <Lesson>[], 'available': <Lesson>[]};
    }
  }
}
