import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'activity.dart';
import 'user_type.dart';

/// Model for storing child submissions and progress
class ChildSubmission extends Equatable {
  final String id;
  final String childId;
  final String activityId;
  final String teacherId;
  final List<QuestionSubmission> questionSubmissions;
  final int totalScore;
  final int maxPossibleScore;
  final double completionPercentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Duration? timeSpent;
  final SubmissionStatus status;
  final Map<String, dynamic> metadata; // Additional data like device info, etc.

  const ChildSubmission({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.teacherId,
    required this.questionSubmissions,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.completionPercentage,
    required this.startedAt,
    this.completedAt,
    this.timeSpent,
    required this.status,
    this.metadata = const {},
  });

  factory ChildSubmission.fromJson(Map<String, dynamic> json) {
    return ChildSubmission(
      id: json['id'] as String,
      childId: json['childId'] as String,
      activityId: json['activityId'] as String,
      teacherId: json['teacherId'] as String,
      questionSubmissions: (json['questionSubmissions'] as List<dynamic>)
          .map((q) => QuestionSubmission.fromJson(q as Map<String, dynamic>))
          .toList(),
      totalScore: json['totalScore'] as int,
      maxPossibleScore: json['maxPossibleScore'] as int,
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      timeSpent: json['timeSpent'] != null
          ? Duration(seconds: json['timeSpent'] as int)
          : null,
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubmissionStatus.inProgress,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'activityId': activityId,
      'teacherId': teacherId,
      'questionSubmissions':
          questionSubmissions.map((q) => q.toJson()).toList(),
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
      'completionPercentage': completionPercentage,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'timeSpent': timeSpent?.inSeconds,
      'status': status.name,
      'metadata': metadata,
    };
  }

  ChildSubmission copyWith({
    String? id,
    String? childId,
    String? activityId,
    String? teacherId,
    List<QuestionSubmission>? questionSubmissions,
    int? totalScore,
    int? maxPossibleScore,
    double? completionPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
    Duration? timeSpent,
    SubmissionStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ChildSubmission(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      activityId: activityId ?? this.activityId,
      teacherId: teacherId ?? this.teacherId,
      questionSubmissions: questionSubmissions ?? this.questionSubmissions,
      totalScore: totalScore ?? this.totalScore,
      maxPossibleScore: maxPossibleScore ?? this.maxPossibleScore,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpent: timeSpent ?? this.timeSpent,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        activityId,
        teacherId,
        questionSubmissions,
        totalScore,
        maxPossibleScore,
        completionPercentage,
        startedAt,
        completedAt,
        timeSpent,
        status,
        metadata,
      ];
}

/// Individual question submission within an activity
class QuestionSubmission extends Equatable {
  final String questionId;
  final String questionText;
  final QuestionType questionType;
  final dynamic userAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final int pointsEarned;
  final int maxPoints;
  final DateTime answeredAt;
  final Duration? timeSpent;
  final List<String> hintsUsed;
  final Map<String, dynamic> metadata;

  const QuestionSubmission({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    required this.maxPoints,
    required this.answeredAt,
    this.timeSpent,
    this.hintsUsed = const [],
    this.metadata = const {},
  });

  factory QuestionSubmission.fromJson(Map<String, dynamic> json) {
    return QuestionSubmission(
      questionId: json['questionId'] as String,
      questionText: json['questionText'] as String,
      questionType: QuestionType.values.firstWhere(
        (e) => e.name == json['questionType'],
        orElse: () => QuestionType.multipleChoice,
      ),
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: json['pointsEarned'] as int,
      maxPoints: json['maxPoints'] as int,
      answeredAt: (json['answeredAt'] as Timestamp).toDate(),
      timeSpent: json['timeSpent'] != null
          ? Duration(seconds: json['timeSpent'] as int)
          : null,
      hintsUsed: List<String>.from(json['hintsUsed'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionType': questionType.name,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'maxPoints': maxPoints,
      'answeredAt': Timestamp.fromDate(answeredAt),
      'timeSpent': timeSpent?.inSeconds,
      'hintsUsed': hintsUsed,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        questionId,
        questionText,
        questionType,
        userAnswer,
        correctAnswer,
        isCorrect,
        pointsEarned,
        maxPoints,
        answeredAt,
        timeSpent,
        hintsUsed,
        metadata,
      ];
}

/// Status of a child's submission
enum SubmissionStatus {
  inProgress('In Progress'),
  completed('Completed'),
  abandoned('Abandoned'),
  reviewed('Reviewed');

  const SubmissionStatus(this.displayName);
  final String displayName;
}

/// Analytics data for teachers to track child progress
class ChildProgressAnalytics {
  final String childId;
  final String teacherId;
  final Map<AgeGroup, int> activitiesByAgeGroup;
  final Map<ActivitySubject, int> activitiesBySubject;
  final Map<Difficulty, int> activitiesByDifficulty;
  final int totalActivitiesCompleted;
  final int totalScoreEarned;
  final double averageCompletionPercentage;
  final Duration totalTimeSpent;
  final List<String> strengths; // Skills where child performs well
  final List<String> areasForImprovement; // Skills that need work
  final DateTime lastActivityDate;
  final DateTime analyticsGeneratedAt;

  const ChildProgressAnalytics({
    required this.childId,
    required this.teacherId,
    required this.activitiesByAgeGroup,
    required this.activitiesBySubject,
    required this.activitiesByDifficulty,
    required this.totalActivitiesCompleted,
    required this.totalScoreEarned,
    required this.averageCompletionPercentage,
    required this.totalTimeSpent,
    required this.strengths,
    required this.areasForImprovement,
    required this.lastActivityDate,
    required this.analyticsGeneratedAt,
  });

  factory ChildProgressAnalytics.fromJson(Map<String, dynamic> json) {
    return ChildProgressAnalytics(
      childId: json['childId'] as String,
      teacherId: json['teacherId'] as String,
      activitiesByAgeGroup: Map<AgeGroup, int>.from(
        (json['activitiesByAgeGroup'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
              AgeGroup.values.firstWhere((e) => e.name == key), value as int),
        ),
      ),
      activitiesBySubject: Map<ActivitySubject, int>.from(
        (json['activitiesBySubject'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
              ActivitySubject.values.firstWhere((e) => e.name == key),
              value as int),
        ),
      ),
      activitiesByDifficulty: Map<Difficulty, int>.from(
        (json['activitiesByDifficulty'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
              Difficulty.values.firstWhere((e) => e.name == key), value as int),
        ),
      ),
      totalActivitiesCompleted: json['totalActivitiesCompleted'] as int,
      totalScoreEarned: json['totalScoreEarned'] as int,
      averageCompletionPercentage:
          (json['averageCompletionPercentage'] as num).toDouble(),
      totalTimeSpent: Duration(seconds: json['totalTimeSpent'] as int),
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement: List<String>.from(json['areasForImprovement'] ?? []),
      lastActivityDate: (json['lastActivityDate'] as Timestamp).toDate(),
      analyticsGeneratedAt:
          (json['analyticsGeneratedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'teacherId': teacherId,
      'activitiesByAgeGroup':
          activitiesByAgeGroup.map((key, value) => MapEntry(key.name, value)),
      'activitiesBySubject':
          activitiesBySubject.map((key, value) => MapEntry(key.name, value)),
      'activitiesByDifficulty':
          activitiesByDifficulty.map((key, value) => MapEntry(key.name, value)),
      'totalActivitiesCompleted': totalActivitiesCompleted,
      'totalScoreEarned': totalScoreEarned,
      'averageCompletionPercentage': averageCompletionPercentage,
      'totalTimeSpent': totalTimeSpent.inSeconds,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'lastActivityDate': Timestamp.fromDate(lastActivityDate),
      'analyticsGeneratedAt': Timestamp.fromDate(analyticsGeneratedAt),
    };
  }
}
