import 'package:equatable/equatable.dart';

/// Model for web-based educational games
class WebGame extends Equatable {
  final String id;
  final String title;
  final String description;
  final String websiteUrl;
  final String? canvasSelector; // CSS selector for the game element to isolate
  final List<String> topics;
  final List<String> learningGoals;
  final String explanation;
  final String? warning;
  final int estimatedMinutes;
  final String difficulty;
  final String ageGroup; // 'junior' or 'bright'
  final String subject; // 'math', 'science', 'reading', etc.
  final String iconEmoji;
  final String color; // Hex color for the card
  final bool disableCustomScripts;

  const WebGame({
    required this.id,
    required this.title,
    required this.description,
    required this.websiteUrl,
    this.canvasSelector,
    required this.topics,
    required this.learningGoals,
    required this.explanation,
    this.warning,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.ageGroup,
    required this.subject,
    required this.iconEmoji,
    required this.color,
    this.disableCustomScripts = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        websiteUrl,
        canvasSelector,
        topics,
        learningGoals,
        explanation,
        warning,
        estimatedMinutes,
        difficulty,
        ageGroup,
        subject,
        iconEmoji,
        color,
        disableCustomScripts,
      ];
}
