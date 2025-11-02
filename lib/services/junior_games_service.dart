import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/lesson.dart';
import '../models/question_template.dart';
import '../models/user_type.dart';
import '../models/game_activity.dart';
import '../models/activity.dart';

/// Service for loading and managing junior games from question templates
class JuniorGamesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load all games for junior age group from question templates
  /// Groups templates by gameType and creates lessons for each game
  ///
  /// NOTE: This method attempts to read from questionTemplates collection.
  /// If permission denied, it will fall back to published activities or use
  /// a workaround approach.
  Future<List<Lesson>> loadJuniorGames() async {
    try {
      debugPrint(
          '🎮 JuniorGamesService: Loading junior games from templates...');

      // Try loading templates directly from Firebase
      try {
        final snapshot = await _firestore
            .collection('questionTemplates')
            .where('isActive', isEqualTo: true)
            .where('ageGroups', arrayContains: 'junior')
            .get();

        if (snapshot.docs.isNotEmpty) {
          return _processTemplates(snapshot.docs);
        }
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          debugPrint(
              '⚠️ JuniorGamesService: Permission denied reading templates, using fallback...');
          final activities = await _loadGamesFromActivities();
          // If no activities found, use demo games
          if (activities.isEmpty) {
            debugPrint(
                '⚠️ JuniorGamesService: No activities found after permission denied, using demo games');
            return _createDemoGames();
          }
          return activities;
        }
        rethrow;
      }

      // If no templates found, try loading from published activities
      final activities = await _loadGamesFromActivities();

      // If no activities found, use demo games for testing
      if (activities.isEmpty) {
        debugPrint(
            '⚠️ JuniorGamesService: No activities found, using demo games');
        return _createDemoGames();
      }

      return activities;
    } catch (e) {
      debugPrint('❌ JuniorGamesService: Error loading games: $e');
      // Final fallback: return demo games so children can test
      debugPrint('🎮 JuniorGamesService: Using demo games as final fallback');
      return _createDemoGames();
    }
  }

  /// Fallback: Load games from published activities collection
  /// This collection should be accessible to children
  Future<List<Lesson>> _loadGamesFromActivities() async {
    try {
      debugPrint(
          '📚 JuniorGamesService: Loading from activities collection...');

      final snapshot = await _firestore
          .collection('activities')
          .where('ageGroup', isEqualTo: 'junior')
          .where('published', isEqualTo: true)
          .where('publishState', isEqualTo: 'published')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ JuniorGamesService: No published activities found');
        return [];
      }

      debugPrint(
          '✅ JuniorGamesService: Found ${snapshot.docs.length} published activities');

      // Group activities by game type
      final gamesMap = <GameType, List<Map<String, dynamic>>>{};

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Extract game type from activity metadata
          final gameTypeName = data['gameConfig']?['gameType'] as String? ??
              data['metadata']?['gameType'] as String?;

          if (gameTypeName != null) {
            try {
              final gameType = GameType.values.firstWhere(
                (e) => e.name == gameTypeName,
              );

              if (gameType.supportedAgeGroups.contains(AgeGroup.junior)) {
                gamesMap.putIfAbsent(gameType, () => []).add({
                  'id': doc.id,
                  ...data,
                });
              }
            } catch (e) {
              debugPrint(
                  '⚠️ JuniorGamesService: Unknown gameType: $gameTypeName');
            }
          }
        } catch (e) {
          debugPrint(
              '⚠️ JuniorGamesService: Error parsing activity ${doc.id}: $e');
        }
      }

      // Create lessons from activities
      final lessons = <Lesson>[];
      for (final entry in gamesMap.entries) {
        final gameType = entry.key;
        final activities = entry.value;

        // Create a lesson from the first activity of this game type
        if (activities.isNotEmpty) {
          final activity = activities.first;
          final lesson = _createLessonFromActivity(gameType, activity);
          lessons.add(lesson);
        }
      }

      debugPrint(
          '✅ JuniorGamesService: Created ${lessons.length} games from activities');
      return lessons;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
            '⚠️ JuniorGamesService: Permission denied reading activities: $e');
      } else {
        debugPrint(
            '❌ JuniorGamesService: Firestore error loading activities: $e');
      }
      return [];
    } catch (e) {
      debugPrint('❌ JuniorGamesService: Error loading from activities: $e');
      return [];
    }
  }

  /// Process templates and create lessons
  List<Lesson> _processTemplates(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    debugPrint(
        '✅ JuniorGamesService: Found ${docs.length} templates for junior');

    // Group templates by gameType
    final gamesMap = <GameType, List<QuestionTemplate>>{};

    for (final doc in docs) {
      try {
        final data = doc.data();
        final template = QuestionTemplate.fromJson({
          'id': doc.id,
          ...data,
        });

        // Extract gameTypes from Firebase document data
        final gameTypesData = data['gameTypes'] as List?;

        if (gameTypesData != null && gameTypesData.isNotEmpty) {
          for (final gameTypeName in gameTypesData) {
            try {
              final gameType = GameType.values.firstWhere(
                (e) => e.name == gameTypeName.toString(),
              );

              // Only include junior-specific games
              if (gameType.supportedAgeGroups.contains(AgeGroup.junior)) {
                gamesMap.putIfAbsent(gameType, () => []).add(template);
              }
            } catch (e) {
              debugPrint(
                  '⚠️ JuniorGamesService: Unknown gameType: $gameTypeName');
            }
          }
        } else {
          // If no gameType specified, try to infer from subject and question type
          final inferredGameType = _inferGameType(template);
          if (inferredGameType != null &&
              inferredGameType.supportedAgeGroups.contains(AgeGroup.junior)) {
            gamesMap.putIfAbsent(inferredGameType, () => []).add(template);
          }
        }
      } catch (e) {
        debugPrint(
            '⚠️ JuniorGamesService: Error parsing template ${doc.id}: $e');
      }
    }

    // Create lessons for each game
    final lessons = <Lesson>[];
    for (final entry in gamesMap.entries) {
      final gameType = entry.key;
      final gameTemplates = entry.value;

      // Create a lesson for each game type
      final lesson = _createLessonFromGameType(gameType, gameTemplates);
      lessons.add(lesson);
    }

    debugPrint(
        '✅ JuniorGamesService: Created ${lessons.length} games for junior');
    return lessons;
  }

  /// Create a lesson from a published activity
  Lesson _createLessonFromActivity(
    GameType gameType,
    Map<String, dynamic> activityData,
  ) {
    final primarySubject = ActivitySubject.fromString(
          activityData['subject']?.toString() ?? 'math',
        ) ??
        ActivitySubject.math;

    final gameConfig = activityData['gameConfig'] as Map<String, dynamic>?;
    final templateIds = gameConfig?['questionTemplateIds'] as List? ?? [];

    return Lesson(
      id: activityData['id'] ?? 'activity_${gameType.name}',
      title: activityData['title']?.toString() ?? gameType.displayName,
      description:
          activityData['description']?.toString() ?? gameType.description,
      ageGroupTarget: ['6-8'],
      exerciseType: _getExerciseTypeFromGameType(gameType),
      mappedGameType: _getMappedGameTypeFromGameType(gameType),
      rewardPoints: (activityData['points'] as num?)?.toInt() ?? 50,
      subject: primarySubject.name.toLowerCase(),
      difficulty: (activityData['difficulty']?.toString() ?? 'easy'),
      learningObjectives: (activityData['learningObjectives'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skills: (activityData['skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      content: {
        'gameType': gameType.name,
        'questionTemplateIds': templateIds.map((e) => e.toString()).toList(),
        'templateCount': templateIds.length,
        'activityId': activityData['id'],
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'gameType': gameType.name,
        'questionTemplateIds': templateIds.map((e) => e.toString()).toList(),
        'isGameBased': true,
        'activityId': activityData['id'],
      },
    );
  }

  /// Create a lesson from a game type and its templates
  Lesson _createLessonFromGameType(
    GameType gameType,
    List<QuestionTemplate> templates,
  ) {
    // Get the first template's subject for the lesson
    final primarySubject = templates.first.subjects.isNotEmpty
        ? templates.first.subjects.first
        : ActivitySubject.math;

    // Calculate total points from all templates
    final totalPoints = templates.fold<int>(
      0,
      (sum, template) => sum + template.defaultPoints,
    );

    // Get all unique skills
    final allSkills = <String>{};
    for (final template in templates) {
      allSkills.addAll(template.skills);
    }

    // Get template IDs for teacher control
    final templateIds = templates.map((t) => t.id).toList();

    // Create lesson ID based on game type
    final lessonId = 'junior_game_${gameType.name}';

    return Lesson(
      id: lessonId,
      title: gameType.displayName,
      description: gameType.description,
      ageGroupTarget: ['6-8'],
      exerciseType: _getExerciseTypeFromGameType(gameType),
      mappedGameType: _getMappedGameTypeFromGameType(gameType),
      rewardPoints:
          totalPoints > 0 ? totalPoints : 50, // Default to 50 if no points
      subject: primarySubject.name.toLowerCase(),
      difficulty: 'easy', // Default for junior
      learningObjectives: [
        'Practice ${primarySubject.displayName.toLowerCase()} skills',
        'Complete ${gameType.displayName} challenges',
      ],
      skills: allSkills.toList(),
      content: {
        'gameType': gameType.name,
        'questionTemplateIds': templateIds,
        'templateCount': templates.length,
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'gameType': gameType.name,
        'questionTemplateIds': templateIds,
        'isGameBased': true,
      },
    );
  }

  /// Infer game type from template properties
  GameType? _inferGameType(QuestionTemplate template) {
    // Try to match based on subject and question type
    if (template.subjects.contains(ActivitySubject.math)) {
      switch (template.type) {
        case QuestionType.multipleChoice:
        case QuestionType.textInput:
          return GameType.numberGridRace;
        case QuestionType.dragDrop:
          return GameType.ordinalDragOrder;
        case QuestionType.sequencing:
          return GameType.patternBuilder;
        case QuestionType.matching:
        case QuestionType.trueFalse:
          return null; // Not typically used for math games
      }
    }

    if (template.subjects.contains(ActivitySubject.reading)) {
      switch (template.type) {
        case QuestionType.matching:
          return GameType.memoryMatch;
        case QuestionType.dragDrop:
          return GameType.wordBuilder;
        case QuestionType.sequencing:
          return GameType.storySequencer;
        case QuestionType.multipleChoice:
        case QuestionType.textInput:
        case QuestionType.trueFalse:
          return null; // Could be used, but infer from context
      }
    }

    return null;
  }

  /// Map GameType to ExerciseType
  ExerciseType _getExerciseTypeFromGameType(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
      case GameType.koalaCounterAdventure:
        return ExerciseType.multipleChoice;
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
      case GameType.wordBuilder:
        return ExerciseType.puzzle;
      case GameType.memoryMatch:
      case GameType.storySequencer:
        return ExerciseType.flashcard;
      default:
        return ExerciseType.multipleChoice;
    }
  }

  /// Map GameType to MappedGameType
  MappedGameType _getMappedGameTypeFromGameType(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
      case GameType.koalaCounterAdventure:
        return MappedGameType.quizGame;
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
      case GameType.wordBuilder:
        return MappedGameType.dragDrop;
      case GameType.memoryMatch:
      case GameType.storySequencer:
        return MappedGameType.tapGame;
      default:
        return MappedGameType.quizGame;
    }
  }

  /// Load question templates for a specific game
  Future<List<QuestionTemplate>> loadTemplatesForGame(String gameId) async {
    try {
      // First, try to find the game/lesson in Firebase
      final lessonDoc =
          await _firestore.collection('lessons').doc(gameId).get();

      if (lessonDoc.exists) {
        final data = lessonDoc.data();
        final templateIds = (data?['content']?['questionTemplateIds'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        // Try loading templates directly (may have permission issues)
        try {
          final templates = <QuestionTemplate>[];
          for (final templateId in templateIds) {
            try {
              final templateDoc = await _firestore
                  .collection('questionTemplates')
                  .doc(templateId)
                  .get();

              if (templateDoc.exists &&
                  templateDoc.data()?['isActive'] == true) {
                templates.add(QuestionTemplate.fromJson({
                  'id': templateDoc.id,
                  ...templateDoc.data()!,
                }));
              }
            } catch (e) {
              debugPrint(
                  '⚠️ JuniorGamesService: Error loading template $templateId: $e');
            }
          }
          if (templates.isNotEmpty) return templates;
        } catch (e) {
          debugPrint(
              '⚠️ JuniorGamesService: Permission denied loading templates: $e');
        }

        // Fallback: Load from activity if activityId exists
        final activityId = data?['metadata']?['activityId'] as String?;
        if (activityId != null) {
          try {
            final activityDoc =
                await _firestore.collection('activities').doc(activityId).get();

            if (activityDoc.exists) {
              final activity = Activity.fromJson({
                'id': activityDoc.id,
                ...activityDoc.data()!,
              });

              // Convert activity questions back to templates format
              final templates = activity.questions.map((q) {
                return QuestionTemplate(
                  id: q.id,
                  title: q.question,
                  type: q.type,
                  prompt: q.question,
                  options: q.options,
                  correctAnswer: q.correctAnswer,
                  explanation: q.explanation,
                  hint: q.hint,
                  defaultMedia: q.media,
                  defaultPoints: q.points,
                  skills: [],
                  ageGroups: [AgeGroup.junior],
                  subjects: [],
                );
              }).toList();

              return templates;
            }
          } catch (e) {
            debugPrint(
                '⚠️ JuniorGamesService: Error loading activity $activityId: $e');
          }
        }
      }

      // Final fallback: return empty list
      return [];
    } catch (e) {
      debugPrint('❌ JuniorGamesService: Error loading templates for game: $e');
      return [];
    }
  }

  /// Create demo games for testing when Firebase has no data or permissions are denied
  /// These games will work immediately and allow children to test the game system
  List<Lesson> _createDemoGames() {
    debugPrint('🎮 JuniorGamesService: Creating demo games for testing...');

    return [
      Lesson(
        id: 'demo_number_grid_race',
        title: 'Number Grid Race',
        description: 'Skip counting and number patterns',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.multipleChoice,
        mappedGameType: MappedGameType.quizGame,
        rewardPoints: 60,
        subject: 'math',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Skip counting by 2s and 5s', 'Number patterns'],
        skills: ['skip-counting', 'number-patterns'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'numberGridRace',
          'questionTemplateIds': [
            'demo_skip_2s',
            'demo_skip_5s',
            'demo_missing_number'
          ],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'numberGridRace',
          'isDemo': true,
        },
      ),
      Lesson(
        id: 'demo_koala_counter',
        title: 'Koala Counter\'s Adventure',
        description: 'Addition and subtraction with number lines',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.multipleChoice,
        mappedGameType: MappedGameType.quizGame,
        rewardPoints: 85,
        subject: 'math',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Number line addition', 'Number line subtraction'],
        skills: ['addition', 'subtraction', 'number-line'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'koalaCounterAdventure',
          'questionTemplateIds': [
            'demo_add_numberline',
            'demo_sub_numberline',
            'demo_count_on'
          ],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'koalaCounterAdventure',
          'isDemo': true,
        },
      ),
      Lesson(
        id: 'demo_ordinal_order',
        title: 'Ordinal Order Challenge',
        description: 'Ordering and positional language',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.puzzle,
        mappedGameType: MappedGameType.dragDrop,
        rewardPoints: 35,
        subject: 'math',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Ordinal numbers', 'Positional language'],
        skills: ['ordinal-numbers', 'ordering'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'ordinalDragOrder',
          'questionTemplateIds': [
            'demo_ordinal_1st_5th',
            'demo_positional_lang'
          ],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'ordinalDragOrder',
          'isDemo': true,
        },
      ),
      Lesson(
        id: 'demo_pattern_builder',
        title: 'Pattern Builder',
        description: 'Complete color and shape patterns',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.puzzle,
        mappedGameType: MappedGameType.dragDrop,
        rewardPoints: 45,
        subject: 'math',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Pattern recognition', 'Pattern completion'],
        skills: ['patterns', 'sequencing'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'patternBuilder',
          'questionTemplateIds': ['demo_color_pattern', 'demo_shape_pattern'],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'patternBuilder',
          'isDemo': true,
        },
      ),
      Lesson(
        id: 'demo_memory_match',
        title: 'Memory Match',
        description: 'Match rhyming words and letter sounds',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.flashcard,
        mappedGameType: MappedGameType.tapGame,
        rewardPoints: 45,
        subject: 'reading',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Rhyming words', 'Letter sounds'],
        skills: ['rhyming', 'phonemic-awareness', 'letter-sounds'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'memoryMatch',
          'questionTemplateIds': [
            'demo_rhyming_words',
            'demo_letter_sound_match'
          ],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'memoryMatch',
          'isDemo': true,
        },
      ),
      Lesson(
        id: 'demo_word_builder',
        title: 'Word Builder',
        description: 'Build words from letters',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.puzzle,
        mappedGameType: MappedGameType.dragDrop,
        rewardPoints: 45,
        subject: 'reading',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Word building', 'Phonics', 'Spelling'],
        skills: ['word-building', 'phonics', 'spelling'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'wordBuilder',
          'questionTemplateIds': ['demo_cvc_word', 'demo_sight_word'],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'wordBuilder',
          'isDemo': true,
        },
      ),
      Lesson(
        id: 'demo_story_sequencer',
        title: 'Story Sequencer',
        description: 'Put story events in order',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.flashcard,
        mappedGameType: MappedGameType.tapGame,
        rewardPoints: 25,
        subject: 'reading',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Story sequencing', 'Story structure'],
        skills: ['sequencing', 'story-structure'],
        isActive: true,
        createdBy: 'system',
        content: {
          'gameType': 'storySequencer',
          'questionTemplateIds': ['demo_story_sequence'],
          'isDemo': true,
        },
        metadata: {
          'gameType': 'storySequencer',
          'isDemo': true,
        },
      ),
    ];
  }
}
