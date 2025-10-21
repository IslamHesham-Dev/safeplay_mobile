import 'package:equatable/equatable.dart';

import 'activity.dart';
import 'user_type.dart';

/// Reusable question templates teachers can instantiate into activities.
class QuestionTemplate extends Equatable {
  final String id;
  final String title;
  final QuestionType type;
  final String prompt;
  final List<String> options;
  final dynamic correctAnswer; // String or List<String>
  final String? explanation;
  final String? hint;
  final ActivityQuestionMedia defaultMedia;
  final int defaultPoints;
  final List<String> skills; // skills tags e.g., rounding, conjunctions
  final List<AgeGroup> ageGroups; // age groups this template is suitable for
  final List<ActivitySubject> subjects; // subjects this template covers

  const QuestionTemplate({
    required this.id,
    required this.title,
    required this.type,
    required this.prompt,
    this.options = const [],
    this.correctAnswer,
    this.explanation,
    this.hint,
    this.defaultMedia = const ActivityQuestionMedia(),
    this.defaultPoints = 0,
    this.skills = const [],
    this.ageGroups = const [],
    this.subjects = const [],
  });

  factory QuestionTemplate.fromJson(Map<String, dynamic> json) {
    return QuestionTemplate(
      id: (json['id'] ?? json['templateId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      type: QuestionType.fromRaw(json['type']?.toString()),
      prompt: (json['prompt'] ?? json['question'] ?? '').toString(),
      options: (json['options'] is List)
          ? List<String>.from((json['options'] as List)
              .map((e) => e?.toString())
              .whereType<String>())
          : const <String>[],
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation']?.toString(),
      hint: json['hint']?.toString(),
      defaultMedia: ActivityQuestionMedia.fromJson(
          json['media'] as Map<String, dynamic>?),
      defaultPoints: (json['points'] as num?)?.round() ?? 0,
      skills: (json['skills'] is List)
          ? List<String>.from((json['skills'] as List)
              .map((e) => e?.toString())
              .whereType<String>())
          : const <String>[],
      ageGroups: (json['ageGroups'] is List)
          ? (json['ageGroups'] as List)
              .map((e) => AgeGroup.fromString(e?.toString() ?? ''))
              .whereType<AgeGroup>()
              .toList()
          : const <AgeGroup>[],
      subjects: (json['subjects'] is List)
          ? (json['subjects'] as List)
              .map((e) => ActivitySubject.fromString(e?.toString() ?? ''))
              .whereType<ActivitySubject>()
              .toList()
          : const <ActivitySubject>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.rawValue,
      'prompt': prompt,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'hint': hint,
      'media': defaultMedia.isEmpty ? null : defaultMedia.toJson(),
      'points': defaultPoints,
      'skills': skills,
      'ageGroups': ageGroups.map((g) => g.name).toList(),
      'subjects': subjects.map((s) => s.name).toList(),
    }..removeWhere((_, v) => v == null);
  }

  ActivityQuestion instantiate({
    required String questionId,
    String? overridePrompt,
    List<String>? overrideOptions,
    dynamic overrideCorrectAnswer,
    ActivityQuestionMedia? overrideMedia,
    int? overridePoints,
  }) {
    return ActivityQuestion(
      id: questionId,
      type: type,
      question: overridePrompt ?? prompt,
      options: overrideOptions ?? options,
      correctAnswer: overrideCorrectAnswer ?? correctAnswer,
      explanation: explanation,
      hint: hint,
      media: overrideMedia ?? defaultMedia,
      points: overridePoints ?? defaultPoints,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        prompt,
        options,
        correctAnswer,
        explanation,
        hint,
        defaultMedia,
        defaultPoints,
        skills,
        ageGroups,
        subjects,
      ];
}
