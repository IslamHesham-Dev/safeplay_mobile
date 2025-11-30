import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/question_template.dart';
import '../models/activity.dart';
import '../models/game_activity.dart';
import '../providers/auth_provider.dart';
import '../screens/junior/games/junior_game_player_screen.dart';
import 'activity_session_service.dart';
import 'simple_template_service.dart';

/// Service for launching games with questions from templates
class JuniorGameLauncher {
  final SimpleTemplateService _templateService = SimpleTemplateService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivitySessionService _activitySessionService =
      ActivitySessionService();

  /// Launch a game based on a lesson
  /// Loads question templates and navigates to the appropriate game screen
  Future<void> launchGame({
    required BuildContext context,
    required Lesson lesson,
    Future<void> Function()? onGameClosed,
  }) async {
    try {
      debugPrint('🎮 JuniorGameLauncher: Launching game ${lesson.title}...');

      // Extract game type from lesson content/metadata
      final gameTypeName = lesson.content['gameType'] as String? ??
          lesson.metadata['gameType'] as String?;

      if (gameTypeName == null) {
        debugPrint('⚠️ JuniorGameLauncher: No gameType found in lesson');
        _showError(context, 'Game type not found');
        return;
      }

      // Parse game type
      GameType gameType;
      try {
        gameType = GameType.values.firstWhere(
          (e) => e.name == gameTypeName,
        );
      } catch (e) {
        debugPrint('❌ JuniorGameLauncher: Invalid gameType: $gameTypeName');
        _showError(context, 'Invalid game type');
        return;
      }

      // Check if this is a demo game
      final isDemo =
          lesson.content['isDemo'] == true || lesson.metadata['isDemo'] == true;

      List<ActivityQuestion> questions = [];

      if (isDemo) {
        // Use demo questions for testing - these work immediately!
        debugPrint(
            '🎮 JuniorGameLauncher: Using demo questions for ${lesson.title}');
        questions = _createDemoQuestions(gameType);
      } else {
        // Load question templates for this game
        final templateIds = (lesson.content['questionTemplateIds'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        if (templateIds.isEmpty) {
          debugPrint(
              '⚠️ JuniorGameLauncher: No template IDs found, using demo questions');
          questions = _createDemoQuestions(gameType);
        } else {
          debugPrint(
              '📚 JuniorGameLauncher: Loading ${templateIds.length} templates...');

          // Load templates from Firebase (try templates first, fallback to activities)
          try {
            final templates = await _loadTemplatesByIds(templateIds);

            if (templates.isNotEmpty) {
              debugPrint(
                  '✅ JuniorGameLauncher: Loaded ${templates.length} templates');
              // Convert templates to ActivityQuestions
              questions = templates
                  .asMap()
                  .entries
                  .map((entry) => entry.value.instantiate(
                        questionId: 'q_${entry.value.id}_${entry.key}',
                      ))
                  .toList();
            } else {
              // Fallback: Try loading from activity if available
              debugPrint(
                  '⚠️ JuniorGameLauncher: No templates loaded, trying activity fallback...');
              questions = await _loadQuestionsFromActivity(lesson);

              // If still empty, use demo questions
              if (questions.isEmpty) {
                debugPrint(
                    '⚠️ JuniorGameLauncher: No questions from activity, using demo questions');
                questions = _createDemoQuestions(gameType);
              }
            }
          } on FirebaseException catch (e) {
            if (e.code == 'permission-denied') {
              debugPrint(
                  '⚠️ JuniorGameLauncher: Permission denied, using demo questions...');
              questions = _createDemoQuestions(gameType);
            } else {
              rethrow;
            }
          } catch (e) {
            debugPrint(
                '⚠️ JuniorGameLauncher: Error loading templates: $e, using demo questions');
            questions = _createDemoQuestions(gameType);
          }
        }
      }

      if (questions.isEmpty) {
        debugPrint('⚠️ JuniorGameLauncher: No questions loaded');
        _showError(context, 'Failed to load questions');
        return;
      }

      debugPrint('✅ JuniorGameLauncher: Loaded ${questions.length} questions');

      // Navigate to game player screen
      if (context.mounted) {
        _logSession(context, lesson);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JuniorGamePlayerScreen(
              gameType: gameType,
              gameTitle: lesson.title,
              questions: questions,
              lesson: lesson,
            ),
          ),
        );
        if (onGameClosed != null) {
          await onGameClosed();
        }
      }
    } catch (e) {
      debugPrint('❌ JuniorGameLauncher: Error launching game: $e');
      if (context.mounted) {
        _showError(context, 'Error starting game: $e');
      }
    }
  }

  /// Load question templates by their IDs
  Future<List<QuestionTemplate>> _loadTemplatesByIds(
      List<String> templateIds) async {
    try {
      final templates = <QuestionTemplate>[];

      for (final templateId in templateIds) {
        try {
          // Load template from Firebase
          final template = await _templateService.getTemplateById(templateId);
          if (template != null) {
            templates.add(template);
          }
        } catch (e) {
          debugPrint(
              '⚠️ JuniorGameLauncher: Error loading template $templateId: $e');
        }
      }

      return templates;
    } catch (e) {
      debugPrint('❌ JuniorGameLauncher: Error loading templates: $e');
      return [];
    }
  }

  /// Fallback: Load questions from published activity
  Future<List<ActivityQuestion>> _loadQuestionsFromActivity(
      Lesson lesson) async {
    try {
      // Check if lesson has activityId in metadata
      final activityId = lesson.metadata['activityId'] as String? ??
          lesson.content['activityId'] as String?;

      if (activityId != null) {
        debugPrint('📚 JuniorGameLauncher: Loading from activity: $activityId');

        final activityDoc =
            await _firestore.collection('activities').doc(activityId).get();

        if (activityDoc.exists) {
          final activity = Activity.fromJson({
            'id': activityDoc.id,
            ...activityDoc.data()!,
          });

          debugPrint(
              '✅ JuniorGameLauncher: Loaded ${activity.questions.length} questions from activity');
          return activity.questions;
        }
      }

      // Try to find activity by game type
      final gameTypeName = lesson.content['gameType'] as String? ??
          lesson.metadata['gameType'] as String?;

      if (gameTypeName != null) {
        debugPrint(
            '📚 JuniorGameLauncher: Searching for activity with gameType: $gameTypeName');

        final snapshot = await _firestore
            .collection('activities')
            .where('ageGroup', isEqualTo: 'junior')
            .where('published', isEqualTo: true)
            .where('publishState', isEqualTo: 'published')
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final activityGameType = data['gameConfig']?['gameType'] as String? ??
              data['metadata']?['gameType'] as String?;

          if (activityGameType == gameTypeName) {
            final activity = Activity.fromJson({
              'id': doc.id,
              ...data,
            });

            debugPrint(
                '✅ JuniorGameLauncher: Found activity with matching gameType');
            return activity.questions;
          }
        }
      }

      debugPrint('⚠️ JuniorGameLauncher: No activity found for fallback');
      return [];
    } catch (e) {
      debugPrint('❌ JuniorGameLauncher: Error loading from activity: $e');
      return [];
    }
  }

  /// Create demo questions based on game type for immediate testing
  List<ActivityQuestion> _createDemoQuestions(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.multipleChoice,
            question: 'What comes next in the pattern? 2, 4, 6, 8, __',
            options: ['9', '10', '11', '12'],
            correctAnswer: '10',
            explanation: 'We are counting by 2s, so 8 + 2 = 10',
            hint: 'Add 2 to the last number',
            points: 20,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.multipleChoice,
            question: 'What comes next? 5, 10, 15, 20, __',
            options: ['22', '25', '30', '35'],
            correctAnswer: '25',
            explanation: 'We are counting by 5s, so 20 + 5 = 25',
            hint: 'Add 5 to the last number',
            points: 25,
          ),
          ActivityQuestion(
            id: 'demo_q3',
            type: QuestionType.textInput,
            question: 'Fill in the missing number: 12, 13, __, 15, 16',
            correctAnswer: '14',
            explanation: 'The numbers are counting up by 1, so 13 + 1 = 14',
            hint: 'Count up by 1 from 13',
            points: 15,
          ),
        ];

      case GameType.koalaCounterAdventure:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.textInput,
            question: 'Use the number line to solve: 7 + 5 = ?',
            correctAnswer: '12',
            explanation:
                'Start at 7 and count forward 5 spaces: 7, 8, 9, 10, 11, 12',
            hint: 'Start at 7 and count forward 5',
            points: 30,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.textInput,
            question: 'Use the number line to solve: 15 - 8 = ?',
            correctAnswer: '7',
            explanation: 'Start at 15 and count backward 8 spaces',
            hint: 'Start at 15 and count backward 8',
            points: 30,
          ),
          ActivityQuestion(
            id: 'demo_q3',
            type: QuestionType.textInput,
            question: 'Use counting on: 9 + 6 = ?',
            correctAnswer: '15',
            explanation: 'Start with the bigger number 9 and count on 6',
            hint: 'Start with 9 and count forward 6',
            points: 25,
          ),
        ];

      case GameType.ordinalDragOrder:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.dragDrop,
            question: 'Put the animals in order from 1st to 5th',
            options: ['3rd', '1st', '5th', '2nd', '4th'],
            correctAnswer: ['1st', '2nd', '3rd', '4th', '5th'],
            explanation:
                'Ordinal numbers show position: 1st, 2nd, 3rd, 4th, 5th',
            hint: 'Think about the order: first, second, third, fourth, fifth',
            points: 20,
          ),
        ];

      case GameType.patternBuilder:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.sequencing,
            question: 'Complete the pattern: Red, Blue, Red, Blue, __, __',
            options: ['Red', 'Blue', 'Green', 'Yellow'],
            correctAnswer: ['Red', 'Blue'],
            explanation:
                'The pattern repeats Red, Blue, so the next two are Red, Blue',
            hint: 'Look for the repeating pattern',
            points: 20,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.sequencing,
            question: 'What comes next? Circle, Square, Circle, Square, __',
            options: ['Triangle', 'Circle', 'Square', 'Rectangle'],
            correctAnswer: 'Circle',
            explanation: 'The pattern alternates between Circle and Square',
            hint: 'Look at the alternating pattern',
            points: 25,
          ),
        ];
      case GameType.bubblePopGrammar:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.multipleChoice,
            question: 'Find the part you add to DROP to make it "dropped".',
            options: ['ed', 'dropp', 'er'],
            correctAnswer: 'ed',
            explanation: 'We double the consonant and add -ed.',
            hint: 'Which part is added at the end?',
            points: 10,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.multipleChoice,
            question: 'To change LIVE to "living", what ending do we add?',
            options: ['ing', 'liv', 'ed'],
            correctAnswer: 'ing',
            explanation: 'Drop the silent e and add -ing.',
            hint: 'Remove the e before adding the new ending.',
            points: 10,
          ),
        ];
      case GameType.seashellQuiz:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.multipleChoice,
            question: 'An adverb gives more information about...?',
            options: ['A noun', 'A person', 'An action (verb)'],
            correctAnswer: 'An action (verb)',
            explanation: 'Adverbs describe actions.',
            hint: 'Think about words like quickly or slowly.',
            points: 10,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.multipleChoice,
            question: 'Which language strand involves listening and speaking?',
            options: ['Oral language', 'Visual language', 'Written language'],
            correctAnswer: 'Oral language',
            explanation: 'Oral language is communication we speak and hear.',
            hint: 'It is how we talk and listen.',
            points: 10,
          ),
        ];
      case GameType.fishTankQuiz:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.multipleChoice,
            question:
                'If you have 4 cookies and you get 2 more, how many do you have?',
            options: ['4', '5', '6'],
            correctAnswer: '6',
            explanation: '4 + 2 = 6.',
            hint: 'Count on from four.',
            points: 10,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.multipleChoice,
            question: 'What is 17 take away 5?',
            options: ['12', '10', '22'],
            correctAnswer: '12',
            explanation: '17 - 5 = 12.',
            hint: 'Count backwards five steps.',
            points: 10,
          ),
        ];
      case GameType.addEquations:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.dragDrop,
            question: '_ + 6 = 9',
            options: ['2', '1', '3'],
            correctAnswer: '3',
            explanation: 'Three plus six equals nine.',
            hint: 'What number plus 6 makes 9?',
            points: 20,
          ),
          ActivityQuestion(
            id: 'demo_q2',
            type: QuestionType.dragDrop,
            question: '4 + 4 = _',
            options: ['7', '9', '8'],
            correctAnswer: '8',
            explanation: 'Four plus four equals eight.',
            hint: 'Count all the items.',
            points: 20,
          ),
          ActivityQuestion(
            id: 'demo_q3',
            type: QuestionType.dragDrop,
            question: '11 + _ = 14',
            options: ['2', '3', '4'],
            correctAnswer: '3',
            explanation: 'Eleven plus three equals fourteen.',
            hint: 'Start at 11 and count up to 14.',
            points: 25,
          ),
        ];

      case GameType.memoryMatch:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.matching,
            question: 'Match the words that rhyme',
            options: ['cat', 'hat', 'dog', 'log', 'sun', 'fun'],
            correctAnswer: [
              ['cat', 'hat'],
              ['dog', 'log'],
              ['sun', 'fun']
            ],
            explanation: 'Words that rhyme have the same ending sounds',
            hint: 'Listen for words that sound the same at the end',
            points: 20,
          ),
        ];

      case GameType.wordBuilder:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.dragDrop,
            question: 'Build the word "cat" using the letters',
            options: ['c', 'a', 't', 'b', 'o', 'g'],
            correctAnswer: ['c', 'a', 't'],
            explanation: 'C-A-T spells cat',
            hint: 'Think about the sounds in the word cat',
            points: 30,
          ),
        ];

      case GameType.storySequencer:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.sequencing,
            question: 'Put the story in order',
            options: ['Wake up', 'Brush teeth', 'Eat breakfast', 'Get dressed'],
            correctAnswer: [
              'Wake up',
              'Brush teeth',
              'Get dressed',
              'Eat breakfast'
            ],
            explanation:
                'The correct order is: wake up, brush teeth, get dressed, eat breakfast',
            hint: 'Think about what you do first when you wake up',
            points: 25,
          ),
        ];

      default:
        return [
          ActivityQuestion(
            id: 'demo_q1',
            type: QuestionType.multipleChoice,
            question: 'Demo question - select an answer',
            options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
            correctAnswer: 'Option 1',
            points: 10,
          ),
        ];
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _logSession(BuildContext context, Lesson lesson) {
    final authProvider = context.read<AuthProvider>();
    final child = authProvider.currentChild;
    if (child == null) return;
    final duration = _extractLessonDuration(lesson);
    unawaited(
      _activitySessionService.logSession(
        childId: child.id,
        activityId: lesson.id,
        title: lesson.title,
        subject: (lesson.subject ?? 'general').toLowerCase(),
        durationMinutes: duration,
      ),
    );
  }

  int? _extractLessonDuration(Lesson lesson) {
    final candidates = [
      lesson.metadata['durationMinutes'],
      lesson.metadata['duration'],
      lesson.metadata['estimatedDuration'],
      lesson.content['durationMinutes'],
      lesson.content['duration'],
    ];
    for (final value in candidates) {
      if (value == null) continue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
