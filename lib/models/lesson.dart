import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'user_type.dart';

/// Exercise types for lessons
enum ExerciseType {
  multipleChoice('Multiple Choice'),
  flashcard('Flashcard'),
  puzzle('Puzzle');

  const ExerciseType(this.displayName);
  final String displayName;
}

/// Game types that lessons can be mapped to
enum MappedGameType {
  tapGame('Tap Game'),
  dragDrop('Drag & Drop'),
  quizGame('Quiz Game');

  const MappedGameType(this.displayName);
  final String displayName;
}

/// Lesson model for structured learning content
class Lesson extends Equatable {
  final String id;
  final String title;
  final String? description;
  final List<String> ageGroupTarget; // e.g., ["6-9", "9-12"]
  final ExerciseType exerciseType;
  final MappedGameType mappedGameType;
  final int rewardPoints;
  final String? subject; // e.g., "math", "reading"
  final String? difficulty; // e.g., "easy", "medium", "hard"
  final List<String> learningObjectives;
  final List<String> skills; // Skills this lesson teaches
  final Map<String, dynamic> content; // Lesson-specific content data
  final bool isActive;
  final String? createdBy; // Teacher ID who created this lesson
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.ageGroupTarget,
    required this.exerciseType,
    required this.mappedGameType,
    required this.rewardPoints,
    this.subject,
    this.difficulty,
    this.learningObjectives = const [],
    this.skills = const [],
    this.content = const {},
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      ageGroupTarget:
          _parseStringList(json['ageGroupTarget'] ?? json['age_group_target']),
      exerciseType:
          _parseExerciseType(json['exerciseType'] ?? json['exercise_type']),
      mappedGameType: _parseMappedGameType(
          json['mappedGameType'] ?? json['mapped_game_type']),
      rewardPoints: _parseInt(json['rewardPoints'] ?? json['reward_points'], 0),
      subject: json['subject']?.toString(),
      difficulty: json['difficulty']?.toString(),
      learningObjectives: _parseStringList(
          json['learningObjectives'] ?? json['learning_objectives']),
      skills: _parseStringList(json['skills']),
      content: _parseMap(json['content']),
      isActive: _parseBool(json['isActive'] ?? json['is_active'], true),
      createdBy: json['createdBy'] ?? json['created_by']?.toString(),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']) ??
          DateTime.now(),
      metadata: _parseMap(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ageGroupTarget': ageGroupTarget,
      'exerciseType': exerciseType.name,
      'mappedGameType': mappedGameType.name,
      'rewardPoints': rewardPoints,
      'subject': subject,
      'difficulty': difficulty,
      'learningObjectives': learningObjectives,
      'skills': skills,
      'content': content,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  /// Check if this lesson is suitable for a given age group
  bool isSuitableForAgeGroup(String ageGroup) {
    return ageGroupTarget.contains(ageGroup);
  }

  /// Check if this lesson is suitable for a given age group enum
  bool isSuitableForAgeGroupEnum(AgeGroup ageGroup) {
    final ageGroupString = _ageGroupToString(ageGroup);
    return ageGroupTarget.contains(ageGroupString);
  }

  /// Convert AgeGroup enum to string format used in ageGroupTarget
  String _ageGroupToString(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.junior:
        return '6-8';
      case AgeGroup.bright:
        return '9-12';
    }
  }

  /// Create a copy of this lesson with updated fields
  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ageGroupTarget,
    ExerciseType? exerciseType,
    MappedGameType? mappedGameType,
    int? rewardPoints,
    String? subject,
    String? difficulty,
    List<String>? learningObjectives,
    List<String>? skills,
    Map<String, dynamic>? content,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ageGroupTarget: ageGroupTarget ?? this.ageGroupTarget,
      exerciseType: exerciseType ?? this.exerciseType,
      mappedGameType: mappedGameType ?? this.mappedGameType,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      skills: skills ?? this.skills,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        ageGroupTarget,
        exerciseType,
        mappedGameType,
        rewardPoints,
        subject,
        difficulty,
        learningObjectives,
        skills,
        content,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
        metadata,
      ];

  // Helper methods for parsing JSON
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item?.toString())
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [value.toString()];
  }

  static ExerciseType _parseExerciseType(dynamic value) {
    if (value == null) return ExerciseType.multipleChoice;
    final stringValue = value.toString().toLowerCase();
    for (final type in ExerciseType.values) {
      if (type.name.toLowerCase() == stringValue) {
        return type;
      }
    }
    return ExerciseType.multipleChoice;
  }

  static MappedGameType _parseMappedGameType(dynamic value) {
    if (value == null) return MappedGameType.quizGame;
    final stringValue = value.toString().toLowerCase();
    for (final type in MappedGameType.values) {
      if (type.name.toLowerCase() == stringValue) {
        return type;
      }
    }
    return MappedGameType.quizGame;
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}
