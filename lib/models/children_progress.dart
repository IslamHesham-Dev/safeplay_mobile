import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Children's progress tracking model
class ChildrenProgress extends Equatable {
  final String id;
  final String childId;
  final List<String> completedLessons; // Array of lesson IDs
  final int earnedPoints; // XP or coins
  final DateTime lastActiveDate;
  final Map<String, int> lessonScores; // lessonId -> best score
  final Map<String, int> lessonAttempts; // lessonId -> number of attempts
  final Map<String, DateTime>
      lessonCompletionDates; // lessonId -> completion date
  final Map<String, dynamic> achievements; // Achievement data
  final int totalTimeSpent; // Total time spent in minutes
  final Map<String, dynamic> metadata;

  const ChildrenProgress({
    required this.id,
    required this.childId,
    this.completedLessons = const [],
    this.earnedPoints = 0,
    required this.lastActiveDate,
    this.lessonScores = const {},
    this.lessonAttempts = const {},
    this.lessonCompletionDates = const {},
    this.achievements = const {},
    this.totalTimeSpent = 0,
    this.metadata = const {},
  });

  factory ChildrenProgress.fromJson(Map<String, dynamic> json) {
    return ChildrenProgress(
      id: json['id']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      completedLessons: _parseStringList(
          json['completedLessons'] ?? json['completed_lessons']),
      earnedPoints: _parseInt(json['earnedPoints'] ?? json['earned_points'], 0),
      lastActiveDate:
          _parseDateTime(json['lastActiveDate'] ?? json['last_active_date']) ??
              DateTime.now(),
      lessonScores:
          _parseStringIntMap(json['lessonScores'] ?? json['lesson_scores']),
      lessonAttempts:
          _parseStringIntMap(json['lessonAttempts'] ?? json['lesson_attempts']),
      lessonCompletionDates: _parseStringDateTimeMap(
          json['lessonCompletionDates'] ?? json['lesson_completion_dates']),
      achievements: _parseMap(json['achievements']),
      totalTimeSpent:
          _parseInt(json['totalTimeSpent'] ?? json['total_time_spent'], 0),
      metadata: _parseMap(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'completedLessons': completedLessons,
      'earnedPoints': earnedPoints,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'lessonScores': lessonScores,
      'lessonAttempts': lessonAttempts,
      'lessonCompletionDates':
          _dateTimeMapToTimestampMap(lessonCompletionDates),
      'achievements': achievements,
      'totalTimeSpent': totalTimeSpent,
      'metadata': metadata,
    };
  }

  /// Check if a lesson is completed
  bool isLessonCompleted(String lessonId) {
    return completedLessons.contains(lessonId);
  }

  /// Get the best score for a lesson
  int getLessonScore(String lessonId) {
    return lessonScores[lessonId] ?? 0;
  }

  /// Get the number of attempts for a lesson
  int getLessonAttempts(String lessonId) {
    return lessonAttempts[lessonId] ?? 0;
  }

  /// Get the completion date for a lesson
  DateTime? getLessonCompletionDate(String lessonId) {
    return lessonCompletionDates[lessonId];
  }

  /// Add a completed lesson with score and time spent
  ChildrenProgress addCompletedLesson({
    required String lessonId,
    required int score,
    required int timeSpentMinutes,
    int pointsEarned = 0,
  }) {
    final now = DateTime.now();
    final newCompletedLessons = List<String>.from(completedLessons);
    if (!newCompletedLessons.contains(lessonId)) {
      newCompletedLessons.add(lessonId);
    }

    final newLessonScores = Map<String, int>.from(lessonScores);
    final currentBestScore = newLessonScores[lessonId] ?? 0;
    newLessonScores[lessonId] =
        score > currentBestScore ? score : currentBestScore;

    final newLessonAttempts = Map<String, int>.from(lessonAttempts);
    newLessonAttempts[lessonId] = (newLessonAttempts[lessonId] ?? 0) + 1;

    final newLessonCompletionDates =
        Map<String, DateTime>.from(lessonCompletionDates);
    newLessonCompletionDates[lessonId] = now;

    return copyWith(
      completedLessons: newCompletedLessons,
      earnedPoints: earnedPoints + pointsEarned,
      lastActiveDate: now,
      lessonScores: newLessonScores,
      lessonAttempts: newLessonAttempts,
      lessonCompletionDates: newLessonCompletionDates,
      totalTimeSpent: totalTimeSpent + timeSpentMinutes,
    );
  }

  /// Update points without completing a lesson
  ChildrenProgress addPoints(int points) {
    return copyWith(
      earnedPoints: earnedPoints + points,
      lastActiveDate: DateTime.now(),
    );
  }

  /// Get completion percentage for a set of lessons
  double getCompletionPercentage(List<String> lessonIds) {
    if (lessonIds.isEmpty) return 0.0;
    final completedCount =
        lessonIds.where((id) => completedLessons.contains(id)).length;
    return completedCount / lessonIds.length;
  }

  /// Get total lessons completed
  int get totalLessonsCompleted => completedLessons.length;

  /// Get average score across all completed lessons
  double get averageScore {
    if (lessonScores.isEmpty) return 0.0;
    final totalScore = lessonScores.values.fold(0, (sum, score) => sum + score);
    return totalScore / lessonScores.length;
  }

  /// Create a copy with updated fields
  ChildrenProgress copyWith({
    String? id,
    String? childId,
    List<String>? completedLessons,
    int? earnedPoints,
    DateTime? lastActiveDate,
    Map<String, int>? lessonScores,
    Map<String, int>? lessonAttempts,
    Map<String, DateTime>? lessonCompletionDates,
    Map<String, dynamic>? achievements,
    int? totalTimeSpent,
    Map<String, dynamic>? metadata,
  }) {
    return ChildrenProgress(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      completedLessons: completedLessons ?? this.completedLessons,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lessonScores: lessonScores ?? this.lessonScores,
      lessonAttempts: lessonAttempts ?? this.lessonAttempts,
      lessonCompletionDates:
          lessonCompletionDates ?? this.lessonCompletionDates,
      achievements: achievements ?? this.achievements,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        completedLessons,
        earnedPoints,
        lastActiveDate,
        lessonScores,
        lessonAttempts,
        lessonCompletionDates,
        achievements,
        totalTimeSpent,
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

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
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

  static Map<String, int> _parseStringIntMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, int>) return value;
    if (value is Map) {
      final result = <String, int>{};
      value.forEach((key, val) {
        if (key is String && val is int) {
          result[key] = val;
        } else if (key is String && val is double) {
          result[key] = val.toInt();
        } else if (key is String && val is String) {
          final intVal = int.tryParse(val);
          if (intVal != null) result[key] = intVal;
        }
      });
      return result;
    }
    return {};
  }

  static Map<String, DateTime> _parseStringDateTimeMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, DateTime>) return value;
    if (value is Map) {
      final result = <String, DateTime>{};
      value.forEach((key, val) {
        if (key is String) {
          final dateTime = _parseDateTime(val);
          if (dateTime != null) {
            result[key] = dateTime;
          }
        }
      });
      return result;
    }
    return {};
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  static Map<String, Timestamp> _dateTimeMapToTimestampMap(
      Map<String, DateTime> dateTimeMap) {
    final result = <String, Timestamp>{};
    dateTimeMap.forEach((key, dateTime) {
      result[key] = Timestamp.fromDate(dateTime);
    });
    return result;
  }
}


