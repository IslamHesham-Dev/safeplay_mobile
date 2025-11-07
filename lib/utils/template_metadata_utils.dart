import '../models/question_template.dart';
import '../models/game_activity.dart';
import '../models/activity.dart';
import '../models/user_type.dart';

/// Utility class for extracting and working with template metadata
class TemplateMetadataUtils {
  static const Map<String, GameType> _forcedGameTypes = {
    // BubblePop Grammar mapping
    'english_junior_001_spelling_suffixes_ing': GameType.bubblePopGrammar,
    'english_junior_003_vocabulary_plurals_f_to_v': GameType.bubblePopGrammar,
    'english_junior_004_adverbs_how': GameType.bubblePopGrammar,
    'english_junior_007_spelling_ed_endings': GameType.bubblePopGrammar,
    // Seashell Quiz mapping
    'english_junior_002_grammar_adverbs': GameType.seashellQuiz,
    'english_junior_005_language_strands_oral': GameType.seashellQuiz,
    'english_junior_006_comprehension_fact': GameType.seashellQuiz,
    // Fish Tank Quiz mapping
    'math_junior_003_addition_basic': GameType.fishTankQuiz,
    'math_junior_004_subtraction_basic': GameType.fishTankQuiz,
    'math_junior_008_data_handling': GameType.fishTankQuiz,
    'math_junior_011_shapes_triangle': GameType.fishTankQuiz,
    'math_junior_012_comparing_numbers': GameType.fishTankQuiz,
  };

  /// Extract game types from a template's JSON data
  static List<GameType> getGameTypesFromTemplate(QuestionTemplate template) {
    final forcedGameType = _forcedGameTypes[template.id];
    if (forcedGameType != null) {
      return [forcedGameType];
    }

    final json = template.toJson();
    final gameTypesData = json['gameTypes'] as List?;

    if (gameTypesData == null || gameTypesData.isEmpty) {
      return [];
    }

    final gameTypes = <GameType>[];
    for (final gameTypeName in gameTypesData) {
      try {
        final gameType = GameType.values.firstWhere(
          (e) => e.name == gameTypeName.toString(),
        );
        gameTypes.add(gameType);
      } catch (e) {
        // Ignore unknown game types
      }
    }

    return gameTypes;
  }

  /// Get the recommended game type from template (first in list, or inferred)
  static GameType? getRecommendedGameType(QuestionTemplate template) {
    final forcedGameType = _forcedGameTypes[template.id];
    if (forcedGameType != null) {
      return forcedGameType;
    }

    final gameTypes = getGameTypesFromTemplate(template);

    if (gameTypes.isNotEmpty) {
      return gameTypes.first;
    }

    // Try to infer from recommendedGameType field
    final json = template.toJson();
    final recommendedGameTypeName = json['recommendedGameType'] as String?;
    if (recommendedGameTypeName != null) {
      try {
        return GameType.values.firstWhere(
          (e) => e.name == recommendedGameTypeName,
        );
      } catch (e) {
        // Ignore
      }
    }

    // Infer from subject and question type
    if (template.subjects.contains(ActivitySubject.math)) {
      switch (template.type) {
        case QuestionType.multipleChoice:
        case QuestionType.textInput:
          return GameType.numberGridRace;
        case QuestionType.dragDrop:
          return GameType.ordinalDragOrder;
        case QuestionType.sequencing:
          return GameType.patternBuilder;
        default:
          return GameType.memoryMatch;
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
        default:
          return GameType.memoryMatch;
      }
    }

    // Default for break activities or other subjects
    if (template.subjects.isEmpty ||
        template.subjects.contains(ActivitySubject.science)) {
      return GameType.memoryMatch;
    }

    return GameType.memoryMatch;
  }

  /// Check if template is a break activity
  static bool isBreakActivity(QuestionTemplate template) {
    final json = template.toJson();
    return json['isBreakActivity'] == true ||
        json['subjects']?.toString().contains('wellbeing') == true;
  }

  /// Get difficulty level from template
  static String? getDifficultyLevel(QuestionTemplate template) {
    final json = template.toJson();
    return json['difficultyLevel']?.toString();
  }

  /// Get lesson/topic name from template
  static String getLessonName(QuestionTemplate template) {
    final json = template.toJson();
    final topics = json['topics'] as List?;
    if (topics != null && topics.isNotEmpty) {
      return topics.first.toString();
    }

    // Fallback to first skill or subject
    if (template.skills.isNotEmpty) {
      return template.skills.first;
    }

    if (template.subjects.isNotEmpty) {
      return template.subjects.first.displayName;
    }

    return 'General';
  }

  /// Generate friendly activity description from templates
  static String generateActivityDescription(
    List<QuestionTemplate> templates,
    AgeGroup ageGroup,
  ) {
    if (templates.isEmpty) {
      return 'An exciting learning adventure!';
    }

    final subject = templates.first.subjects.isNotEmpty
        ? templates.first.subjects.first
        : ActivitySubject.math;

    final subjectName =
        subject == ActivitySubject.reading ? 'English' : subject.displayName;

    final count = templates.length;
    final gameType = getRecommendedGameType(templates.first);
    final gameName = gameType?.displayName ?? 'Fun Games';

    // Age-appropriate language
    if (ageGroup == AgeGroup.junior) {
      return 'Join us for $count super fun $gameName! You\'ll learn about $subjectName in exciting ways. Ready to play and discover? 🌟';
    } else {
      return 'Explore $count engaging $gameName activities covering $subjectName! Challenge yourself, learn new skills, and have fun while mastering important concepts. Let\'s get started! 🚀';
    }
  }

  /// Generate learning objectives from templates
  static List<String> generateLearningObjectives(
    List<QuestionTemplate> templates,
  ) {
    final objectives = <String>[];

    // Collect all unique skills from templates
    final allSkills = <String>{};
    for (final template in templates) {
      allSkills.addAll(template.skills);
    }

    // Add skills as objectives
    for (final skill in allSkills) {
      objectives.add('Practice $skill');
    }

    // Collect emotional goals from break activities
    for (final template in templates) {
      if (isBreakActivity(template)) {
        final json = template.toJson();
        final emotionalGoal = json['metadata']?['emotionalGoal']?.toString();
        if (emotionalGoal != null && !objectives.contains(emotionalGoal)) {
          objectives.add(emotionalGoal);
        }
      }
    }

    // If no objectives generated, add defaults
    if (objectives.isEmpty) {
      if (templates.isNotEmpty) {
        final subject = templates.first.subjects.isNotEmpty
            ? templates.first.subjects.first.displayName
            : 'learning';
        objectives.add('Complete $subject challenges');
        objectives.add('Improve problem-solving skills');
      }
    }

    return objectives;
  }
}
