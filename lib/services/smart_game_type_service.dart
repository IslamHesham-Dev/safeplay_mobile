import 'package:flutter/foundation.dart';
import '../models/question_template.dart';
import '../models/game_activity.dart';
import '../models/activity.dart';
import '../models/user_type.dart';

/// Service that intelligently maps question types to the best game type
/// Considers question type, subject, age group, and content to select optimal games
class SmartGameTypeService {
  /// Determine the best game type for a collection of question templates
  /// Analyzes all templates and selects the most suitable game type
  Future<GameType?> determineBestGameType({
    required List<QuestionTemplate> templates,
    required AgeGroup ageGroup,
    required ActivitySubject subject,
  }) async {
    try {
      debugPrint(
          '🎮 SmartGameTypeService: Analyzing ${templates.length} templates...');

      // Count question types
      final questionTypeCounts = <QuestionType, int>{};
      for (final template in templates) {
        questionTypeCounts[template.type] =
            (questionTypeCounts[template.type] ?? 0) + 1;
      }

      // Count dominant question type
      final dominantQuestionType = questionTypeCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      debugPrint('🎮 Dominant question type: $dominantQuestionType');

      // Map question type + subject + age group to best game type
      final gameType = _mapToGameType(
        questionType: dominantQuestionType,
        subject: subject,
        ageGroup: ageGroup,
      );

      debugPrint('✅ SmartGameTypeService: Recommended game type: $gameType');
      return gameType;
    } catch (e) {
      debugPrint('❌ SmartGameTypeService: Error determining game type: $e');
      return null;
    }
  }

  /// Map question type + subject + age group to optimal game type
  GameType? _mapToGameType({
    required QuestionType questionType,
    required ActivitySubject subject,
    required AgeGroup ageGroup,
  }) {
    // Junior Age Group (6-8) - Simple, visual, interactive games
    if (ageGroup == AgeGroup.junior) {
      if (subject == ActivitySubject.math) {
        switch (questionType) {
          case QuestionType.multipleChoice:
          case QuestionType.textInput:
            // Number patterns, counting, basic operations
            return GameType.numberGridRace;
          case QuestionType.dragDrop:
            // Ordinal numbers, ordering
            return GameType.ordinalDragOrder;
          case QuestionType.sequencing:
            // Patterns, sequences
            return GameType.patternBuilder;
          case QuestionType.matching:
            // Number matching, shape matching
            return GameType.memoryMatch;
          case QuestionType.trueFalse:
            // Simple true/false math facts
            return GameType.numberGridRace;
        }
      }

      if (subject == ActivitySubject.reading) {
        switch (questionType) {
          case QuestionType.multipleChoice:
          case QuestionType.trueFalse:
            // Word recognition, phonics
            return GameType.memoryMatch;
          case QuestionType.dragDrop:
            // Building words from letters
            return GameType.wordBuilder;
          case QuestionType.sequencing:
            // Story sequencing
            return GameType.storySequencer;
          case QuestionType.matching:
            // Rhyming words, letter sounds
            return GameType.memoryMatch;
          case QuestionType.textInput:
            // Spelling, word building
            return GameType.wordBuilder;
        }
      }
    }

    // Bright Age Group (9-12) - More complex, strategic games
    if (ageGroup == AgeGroup.bright) {
      if (subject == ActivitySubject.math) {
        switch (questionType) {
          case QuestionType.multipleChoice:
          case QuestionType.textInput:
            // Fractions, decimals, complex operations
            return GameType.fractionNavigator;
          case QuestionType.dragDrop:
          case QuestionType.sequencing:
            // Number ordering, data visualization
            return GameType.dataVisualization;
          case QuestionType.matching:
            // Equation matching, inverse operations
            return GameType.inverseOperationChain;
          case QuestionType.trueFalse:
            // Math facts, properties
            return GameType.fractionNavigator;
        }
      }

      if (subject == ActivitySubject.reading) {
        switch (questionType) {
          case QuestionType.multipleChoice:
          case QuestionType.trueFalse:
            // Comprehension, vocabulary
            return GameType.memoryMatch;
          case QuestionType.dragDrop:
            // Complex word building
            return GameType.wordBuilder;
          case QuestionType.sequencing:
            // Story analysis, plot sequencing
            return GameType.storySequencer;
          case QuestionType.matching:
            // Concept matching, vocabulary
            return GameType.memoryMatch;
          case QuestionType.textInput:
            // Creative writing, spelling
            return GameType.wordBuilder;
        }
      }
    }

    // Default fallback
    return null;
  }

  /// Calculate recommended points for an activity based on questions
  int calculateRecommendedPoints({
    required List<QuestionTemplate> templates,
    required AgeGroup ageGroup,
    required Difficulty difficulty,
  }) {
    // Base points per question
    int basePointsPerQuestion = 10;

    // Age group multiplier
    if (ageGroup == AgeGroup.junior) {
      basePointsPerQuestion = 15; // Higher for junior (reward-focused)
    } else {
      basePointsPerQuestion = 20; // Higher for bright (mastery-focused)
    }

    // Difficulty multiplier
    double difficultyMultiplier = 1.0;
    switch (difficulty) {
      case Difficulty.easy:
        difficultyMultiplier = 1.0;
      case Difficulty.medium:
        difficultyMultiplier = 1.5;
      case Difficulty.hard:
        difficultyMultiplier = 2.0;
    }

    // Calculate total
    final totalPoints =
        (templates.length * basePointsPerQuestion * difficultyMultiplier)
            .round();

    // Minimum points
    return totalPoints.clamp(50, 500);
  }

  /// Get game type recommendations for a subject and age group
  List<GameType> getRecommendedGameTypes({
    required ActivitySubject subject,
    required AgeGroup ageGroup,
  }) {
    final allGames = GameType.values.where((game) {
      return game.supportedAgeGroups.contains(ageGroup) &&
          game.supportedSubjects.contains(subject);
    }).toList();

    // Sort by relevance (games that work best for this subject/age combo)
    allGames.sort((a, b) {
      final aScore = _getGameRelevanceScore(a, subject, ageGroup);
      final bScore = _getGameRelevanceScore(b, subject, ageGroup);
      return bScore.compareTo(aScore); // Higher score first
    });

    return allGames;
  }

  /// Get relevance score for a game type based on subject and age group
  int _getGameRelevanceScore(
    GameType gameType,
    ActivitySubject subject,
    AgeGroup ageGroup,
  ) {
    int score = 0;

    // Age group match
    if (gameType.supportedAgeGroups.contains(ageGroup)) {
      score += 10;
    }

    // Subject match
    if (gameType.supportedSubjects.contains(subject)) {
      score += 10;
    }

    // Specific combinations get bonus points
    if (ageGroup == AgeGroup.junior && subject == ActivitySubject.math) {
      if (gameType == GameType.numberGridRace ||
          gameType == GameType.koalaCounterAdventure) {
        score += 5;
      }
    }

    if (ageGroup == AgeGroup.junior && subject == ActivitySubject.reading) {
      if (gameType == GameType.memoryMatch ||
          gameType == GameType.wordBuilder) {
        score += 5;
      }
    }

    if (ageGroup == AgeGroup.bright && subject == ActivitySubject.math) {
      if (gameType == GameType.fractionNavigator ||
          gameType == GameType.inverseOperationChain) {
        score += 5;
      }
    }

    return score;
  }
}
