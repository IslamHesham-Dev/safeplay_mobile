import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'user_type.dart';

/// Activity difficulty levels
enum Difficulty {
  easy,
  medium,
  hard;
}

/// Activity subjects shared across clients.
enum ActivitySubject {
  math('Math'),
  reading('Reading'),
  writing('Writing'),
  science('Science'),
  social('Social Studies'),
  art('Art'),
  music('Music'),
  coding('Coding');

  const ActivitySubject(this.displayName);
  final String displayName;

  static ActivitySubject fromRaw(dynamic value) {
    if (value == null) return ActivitySubject.reading;
    if (value is Map<String, dynamic>) {
      value =
          value['id'] ?? value['name'] ?? value['value'] ?? value['subject'];
    }
    final rawValue = value.toString().trim().toLowerCase();
    String sanitize(String input) => input.replaceAll(RegExp(r'[\s_\-]+'), '');

    final candidates = <String>{
      rawValue,
      rawValue.replaceAll(RegExp(r'[\s_]+'), '-'),
      sanitize(rawValue),
    };

    for (final candidate in candidates) {
      for (final subject in ActivitySubject.values) {
        if (subject.name == candidate) {
          return subject;
        }
      }
    }

    final aliasMap = <String, ActivitySubject>{
      sanitize('mathematics'): ActivitySubject.math,
      sanitize('maths'): ActivitySubject.math,
      sanitize('numeracy'): ActivitySubject.math,
      sanitize('language-arts'): ActivitySubject.reading,
      sanitize('language arts'): ActivitySubject.reading,
      sanitize('literacy'): ActivitySubject.reading,
      sanitize('reading comprehension'): ActivitySubject.reading,
      sanitize('ela'): ActivitySubject.reading,
      sanitize('writing skills'): ActivitySubject.writing,
      sanitize('creative writing'): ActivitySubject.writing,
      sanitize('storytelling'): ActivitySubject.writing,
      sanitize('science lab'): ActivitySubject.science,
      sanitize('stem'): ActivitySubject.science,
      sanitize('social studies'): ActivitySubject.social,
      sanitize('history'): ActivitySubject.social,
      sanitize('humanities'): ActivitySubject.social,
      sanitize('visual arts'): ActivitySubject.art,
      sanitize('art studio'): ActivitySubject.art,
      sanitize('performing arts'): ActivitySubject.music,
      sanitize('music theory'): ActivitySubject.music,
      sanitize('music arts'): ActivitySubject.music,
      sanitize('computer science'): ActivitySubject.coding,
      sanitize('technology'): ActivitySubject.coding,
      sanitize('coding basics'): ActivitySubject.coding,
    };

    for (final candidate in candidates) {
      final aliasSubject = aliasMap[sanitize(candidate)];
      if (aliasSubject != null) {
        return aliasSubject;
      }
    }

    return ActivitySubject.reading;
  }

  static ActivitySubject? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'math':
        return ActivitySubject.math;
      case 'reading':
        return ActivitySubject.reading;
      case 'writing':
        return ActivitySubject.writing;
      case 'science':
        return ActivitySubject.science;
      case 'social':
        return ActivitySubject.social;
      case 'art':
        return ActivitySubject.art;
      case 'music':
        return ActivitySubject.music;
      case 'coding':
        return ActivitySubject.coding;
      default:
        return null;
    }
  }
}

/// Optional curriculum phase (retained for compatibility).
enum PYPPhase {
  phase1('Phase 1'),
  phase2('Phase 2'),
  phase3('Phase 3'),
  phase4('Phase 4'),
  phase5('Phase 5');

  const PYPPhase(this.displayName);
  final String displayName;
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) {
    return value.toString();
  }
  return value.toString();
}

List<String> _stringList(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    final results = <String>[];
    for (final item in value) {
      if (item == null) continue;
      if (item is String) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) results.add(trimmed);
        continue;
      }
      if (item is Map<String, dynamic>) {
        final raw =
            item['id'] ?? item['value'] ?? item['name'] ?? item['title'];
        final extracted = _asString(raw)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          results.add(extracted);
        }
        continue;
      }
      final extracted = _asString(item)?.trim();
      if (extracted != null && extracted.isNotEmpty) {
        results.add(extracted);
      }
    }
    return results.toList(growable: false);
  }
  if (value is Map<String, dynamic>) {
    final raw =
        value['id'] ?? value['value'] ?? value['name'] ?? value['title'];
    final extracted = _asString(raw)?.trim();
    if (extracted != null && extracted.isNotEmpty) {
      return [extracted];
    }
    return const [];
  }
  final str = _asString(value)?.trim();
  if (str == null || str.isEmpty) return const [];
  return [str];
}

dynamic _normalizeCorrectAnswer(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value
        .map((item) => item is num || item is bool ? item : _asString(item))
        .map((item) => item is String ? item.trim() : item)
        .toList();
  }
  if (value is num || value is bool) {
    return value;
  }
  return _asString(value)?.trim();
}

int _asInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.round();
  final parsed = int.tryParse(value.toString());
  return parsed ?? defaultValue;
}

int _parseDurationMinutes(dynamic value) {
  if (value is Map<String, dynamic>) {
    final minutes = value['minutes'] ?? value['value'];
    return _asInt(minutes);
  }
  return _asInt(value);
}

String _normalizeTagValue(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Activity question media bundle.
class ActivityQuestionMedia extends Equatable {
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  // Accessibility text for images or visuals
  final String? altText;

  const ActivityQuestionMedia({
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.altText,
  });

  factory ActivityQuestionMedia.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ActivityQuestionMedia();
    }
    final data = Map<String, dynamic>.from(json);
    if (data['sources'] is Map) {
      final sources = Map<String, dynamic>.from(data['sources'] as Map);
      data.putIfAbsent(
          'imageUrl', () => sources['image'] ?? sources['imageUrl']);
      data.putIfAbsent(
          'audioUrl', () => sources['audio'] ?? sources['audioUrl']);
      data.putIfAbsent(
          'videoUrl', () => sources['video'] ?? sources['videoUrl']);
    }
    final image = data['imageUrl'] ??
        data['image'] ??
        data['thumbnail'] ??
        data['url'] ??
        data['src'];
    final audio =
        data['audioUrl'] ?? data['audio'] ?? data['sound'] ?? data['audioSrc'];
    final video =
        data['videoUrl'] ?? data['video'] ?? data['clip'] ?? data['videoSrc'];
    final altText = data['altText'] ?? data['alt'] ?? data['accessibilityText'];
    return ActivityQuestionMedia(
      imageUrl: _asString(image),
      audioUrl: _asString(audio),
      videoUrl: _asString(video),
      altText: _asString(altText),
    );
  }

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'videoUrl': videoUrl,
        'altText': altText,
      }..removeWhere((_, value) => value == null);

  bool get isEmpty => imageUrl == null && audioUrl == null && videoUrl == null;

  @override
  List<Object?> get props => [imageUrl, audioUrl, videoUrl];
}

/// Supported question types.
enum QuestionType {
  multipleChoice,
  textInput,
  dragDrop,
  matching,
  sequencing,
  trueFalse;

  static QuestionType fromRaw(String? value) {
    switch (value) {
      case 'text-input':
        return QuestionType.textInput;
      case 'drag-drop':
        return QuestionType.dragDrop;
      case 'matching':
        return QuestionType.matching;
      case 'sequencing':
        return QuestionType.sequencing;
      case 'true-false':
        return QuestionType.trueFalse;
      case 'multiple-choice':
      default:
        return QuestionType.multipleChoice;
    }
  }

  String get rawValue {
    switch (this) {
      case QuestionType.textInput:
        return 'text-input';
      case QuestionType.dragDrop:
        return 'drag-drop';
      case QuestionType.matching:
        return 'matching';
      case QuestionType.sequencing:
        return 'sequencing';
      case QuestionType.trueFalse:
        return 'true-false';
      case QuestionType.multipleChoice:
        return 'multiple-choice';
    }
  }
}

/// Activity question model aligned with Firestore schema.
class ActivityQuestion extends Equatable {
  final String id;
  final QuestionType type;
  final String question;
  final List<String> options;
  final dynamic correctAnswer; // String or List<String>
  final String? explanation;
  final String? hint;
  final ActivityQuestionMedia media;
  final int points;

  const ActivityQuestion({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    this.correctAnswer,
    this.explanation,
    this.hint,
    this.media = const ActivityQuestionMedia(),
    this.points = 0,
  });

  factory ActivityQuestion.fromJson(Map<String, dynamic> json) {
    return ActivityQuestion(
      id: json['id'] as String,
      type: QuestionType.fromRaw(json['type'] as String?),
      question: (json['prompt'] ?? json['question'] ?? '') as String,
      options: _stringList(json['options']),
      correctAnswer: _normalizeCorrectAnswer(json['correctAnswer']),
      explanation: _asString(json['explanation']),
      hint: _asString(json['hint']),
      media: ActivityQuestionMedia.fromJson(
          json['media'] as Map<String, dynamic>?),
      points: (json['points'] as num?)?.round() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'type': type.rawValue,
      'prompt': question,
      'question': question, // backwards compatibility
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'hint': hint,
      'points': points,
    };

    if (!media.isEmpty) {
      map['media'] = media.toJson();
    }

    map.removeWhere((_, value) => value == null);
    return map;
  }

  String? get imageUrl => media.imageUrl;
  String? get audioUrl => media.audioUrl;
  String? get videoUrl => media.videoUrl;

  @override
  List<Object?> get props => [
        id,
        type,
        question,
        options,
        correctAnswer,
        explanation,
        hint,
        media,
        points,
      ];
}

/// Activity model shared across clients.
class Activity extends Equatable {
  final String id;
  final String title;
  final String description;
  final ActivitySubject subject;
  final PYPPhase? pypPhase;
  final AgeGroup ageGroup;
  final Difficulty difficulty;
  final int durationMinutes;
  final int points;
  final List<String> learningObjectives;
  final List<String> prerequisites;
  final String? thumbnailUrl;
  final List<ActivityQuestion> questions;
  final String createdBy;
  final bool published; // Derived from publishState when present
  final PublishState publishState;
  final List<String> skills; // e.g., place value, conjunctions
  final List<String> tags; // free-form labels for search/visibility
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOfflineAvailable;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    this.pypPhase,
    required this.ageGroup,
    required this.difficulty,
    required this.durationMinutes,
    required this.points,
    required this.learningObjectives,
    this.prerequisites = const [],
    this.thumbnailUrl,
    required this.questions,
    required this.createdBy,
    required this.published,
    this.publishState = PublishState.published,
    this.skills = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isOfflineAvailable = false,
  });

  int get estimatedDuration => durationMinutes;

  bool hasTag(String tag) {
    if (tag.trim().isEmpty) return false;
    final normalizedTarget = _normalizeTagValue(tag);
    return tags.any(
      (value) => _normalizeTagValue(value) == normalizedTarget,
    );
  }

  bool get hasAddEquationsTag => hasTag('addEquations');

  factory Activity.fromJson(Map<String, dynamic> json) {
    final subject = ActivitySubject.fromRaw(json['subject']);
    final ageGroupRaw = _asString(json['ageGroup'] ?? json['age_group']);
    final difficultyRaw = _asString(json['difficulty']);
    final pypRaw = _asString(json['pypPhase'] ?? json['pyp_phase']);
    final durationRaw = json['durationMinutes'] ?? json['duration'];
    final points = _asInt(json['points']);
    final questionsRaw = json['questions'];

    PYPPhase? phase;
    if (pypRaw != null) {
      final normalized =
          pypRaw.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
      try {
        phase = PYPPhase.values.firstWhere(
          (value) => value.name.replaceAll('_', '') == normalized,
        );
      } catch (_) {
        phase = null;
      }
    }

    final ageGroup = AgeGroup.values.firstWhere(
      (group) => group.name == (ageGroupRaw ?? '').toLowerCase(),
      orElse: () => AgeGroup.junior,
    );

    final difficulty = Difficulty.values.firstWhere(
      (value) => value.name == (difficultyRaw ?? '').toLowerCase(),
      orElse: () => Difficulty.medium,
    );

    final questions = questionsRaw is List
        ? questionsRaw
            .whereType<Map<String, dynamic>>()
            .map(ActivityQuestion.fromJson)
            .toList(growable: false)
        : const <ActivityQuestion>[];

    final publishState = PublishState.fromRaw(_asString(json['publishState']));
    // Back-compat: if publishState isn't set, infer from boolean published
    final publishedBool = json['published'] as bool? ?? true;

    return Activity(
      id: _asString(json['id'] ?? json['activityId']) ?? '',
      title: _asString(json['title']) ?? '',
      description: _asString(json['description']) ?? '',
      subject: subject,
      pypPhase: phase,
      ageGroup: ageGroup,
      difficulty: difficulty,
      durationMinutes: _parseDurationMinutes(durationRaw),
      points: points,
      learningObjectives: _stringList(json['learningObjectives']),
      prerequisites: _stringList(json['prerequisites']),
      thumbnailUrl: _asString(
        json['thumbnailUrl'] ?? json['thumbnail'] ?? json['coverImage'],
      ),
      questions: questions,
      createdBy: _asString(json['createdBy']) ?? 'unknown',
      published: publishState == PublishState.published || publishedBool,
      publishState: publishState,
      skills: _stringList(json['skills']),
      tags: _stringList(json['tags']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['createdAt']),
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject.name,
      'pypPhase': pypPhase?.name,
      'ageGroup': ageGroup.name,
      'difficulty': difficulty.name,
      'durationMinutes': durationMinutes,
      'estimatedDuration': durationMinutes,
      'points': points,
      'learningObjectives': learningObjectives,
      'prerequisites': prerequisites,
      'thumbnailUrl': thumbnailUrl,
      'questions': questions.map((question) => question.toJson()).toList(),
      'createdBy': createdBy,
      'published': published,
      'publishState': publishState.name,
      'skills': skills,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isOfflineAvailable': isOfflineAvailable,
    }..removeWhere((_, value) => value == null);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        subject,
        pypPhase,
        ageGroup,
        difficulty,
        durationMinutes,
        points,
        learningObjectives,
        prerequisites,
        thumbnailUrl,
        questions,
        createdBy,
        published,
        publishState,
        skills,
        tags,
        createdAt,
        updatedAt,
        isOfflineAvailable,
      ];
}

/// Publication state for teacher-authored content.
enum PublishState {
  draft,
  pendingReview,
  published,
  archived;

  static PublishState fromRaw(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'draft':
        return PublishState.draft;
      case 'pendingreview':
      case 'pending-review':
        return PublishState.pendingReview;
      case 'archived':
        return PublishState.archived;
      case 'published':
      default:
        return PublishState.published;
    }
  }
}

/// Progress document status helpers.
enum ActivityProgressStatus {
  notStarted,
  inProgress,
  completed;

  static ActivityProgressStatus fromRaw(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll('_', '-') ?? '';
    switch (normalized) {
      case 'in-progress':
      case 'inprogress':
      case 'in progress':
        return ActivityProgressStatus.inProgress;
      case 'completed':
      case 'complete':
        return ActivityProgressStatus.completed;
      case 'not-started':
      case 'notstarted':
      case 'not started':
      default:
        return ActivityProgressStatus.notStarted;
    }
  }

  String get rawValue {
    switch (this) {
      case ActivityProgressStatus.inProgress:
        return 'in-progress';
      case ActivityProgressStatus.completed:
        return 'completed';
      case ActivityProgressStatus.notStarted:
        return 'not-started';
    }
  }
}

/// Activity progress model aligned with Firestore schema.
class ActivityProgress extends Equatable {
  final String id;
  final String childId;
  final String activityId;
  final ActivityProgressStatus status;
  final double progressPercent;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final int score;
  final int totalPoints;
  final int pointsEarned;
  final int timeSpentSeconds;
  final int attemptNumber;
  final int bestScore;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final bool isCompleted;

  const ActivityProgress({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.status,
    required this.progressPercent,
    required this.currentQuestionIndex,
    required this.answers,
    required this.score,
    required this.totalPoints,
    required this.pointsEarned,
    required this.timeSpentSeconds,
    required this.attemptNumber,
    required this.bestScore,
    required this.startedAt,
    this.completedAt,
    required this.updatedAt,
    required this.isCompleted,
  });

  factory ActivityProgress.fromJson(Map<String, dynamic> json) {
    final status = ActivityProgressStatus.fromRaw(json['status'] as String?);
    final score = json['score'] as int? ?? 0;
    final totalPoints = json['totalPoints'] as int? ?? 0;
    final answersRaw = Map<String, dynamic>.from(json['answers'] as Map? ?? {});
    answersRaw.updateAll((key, value) {
      if (value is Map<String, dynamic>) {
        final normalized = Map<String, dynamic>.from(value);
        final answeredAt = _parseDate(
            normalized['clientAnsweredAt'] ?? normalized['answeredAt']);
        normalized['answeredAt'] = answeredAt.toIso8601String();
        normalized.remove('clientAnsweredAt');
        return normalized;
      }
      return value;
    });
    final progressPercent = (json['progressPercent'] as num?)?.toDouble() ??
        (totalPoints > 0 ? (score / totalPoints) * 100 : 0);
    final completedAtRaw = json['completedAt'];

    final updatedAtRaw = json['clientUpdatedAt'] ??
        json['updatedAt'] ??
        completedAtRaw ??
        json['startedAt'];

    return ActivityProgress(
      id: json['id'] as String,
      childId: json['childId'] as String,
      activityId: json['activityId'] as String,
      status: status,
      progressPercent: progressPercent,
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      answers: answersRaw,
      score: score,
      totalPoints: totalPoints,
      pointsEarned: json['pointsEarned'] as int? ?? score,
      timeSpentSeconds:
          json['timeSpentSeconds'] as int? ?? json['timeSpent'] as int? ?? 0,
      attemptNumber: json['attemptNumber'] as int? ?? 1,
      bestScore: json['bestScore'] as int? ?? score,
      startedAt: _parseDate(json['startedAt']),
      completedAt: completedAtRaw != null ? _parseDate(completedAtRaw) : null,
      updatedAt: _parseDate(updatedAtRaw),
      isCompleted: json['isCompleted'] as bool? ??
          status == ActivityProgressStatus.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'activityId': activityId,
      'status': status.rawValue,
      'progressPercent': progressPercent,
      'currentQuestionIndex': currentQuestionIndex,
      'answers': answers,
      'score': score,
      'totalPoints': totalPoints,
      'pointsEarned': pointsEarned,
      'timeSpentSeconds': timeSpentSeconds,
      'attemptNumber': attemptNumber,
      'bestScore': bestScore,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'clientUpdatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  Map<String, dynamic> _answersAsFirestorePayload() {
    final result = <String, dynamic>{};
    answers.forEach((questionId, value) {
      if (value is Map<String, dynamic>) {
        final answerMap = Map<String, dynamic>.from(value);
        final answeredAt = _parseDate(answerMap['answeredAt']);
        answerMap['answeredAt'] = Timestamp.fromDate(answeredAt);
        answerMap['clientAnsweredAt'] = Timestamp.fromDate(answeredAt);
        result[questionId] = answerMap..removeWhere((_, v) => v == null);
      } else {
        result[questionId] = value;
      }
    });
    return result;
  }

  Map<String, dynamic> toFirestore(
      {bool serverTimestampsForUpdatedAt = false}) {
    final map = <String, dynamic>{
      'childId': childId,
      'activityId': activityId,
      'status': status.rawValue,
      'progressPercent': progressPercent,
      'currentQuestionIndex': currentQuestionIndex,
      'answers': _answersAsFirestorePayload(),
      'score': score,
      'totalPoints': totalPoints,
      'pointsEarned': pointsEarned,
      'timeSpentSeconds': timeSpentSeconds,
      'attemptNumber': attemptNumber,
      'bestScore': bestScore,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'clientUpdatedAt': Timestamp.fromDate(updatedAt),
      'isCompleted': isCompleted,
    };
    map['updatedAt'] = serverTimestampsForUpdatedAt
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(updatedAt);
    map.removeWhere((_, value) => value == null);
    return map;
  }

  double get percentage => progressPercent;

  ActivityProgress copyWith({
    ActivityProgressStatus? status,
    double? progressPercent,
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    int? score,
    int? totalPoints,
    int? pointsEarned,
    int? timeSpentSeconds,
    int? attemptNumber,
    int? bestScore,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    return ActivityProgress(
      id: id,
      childId: childId,
      activityId: activityId,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      bestScore: bestScore ?? this.bestScore,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        activityId,
        status,
        progressPercent,
        currentQuestionIndex,
        answers,
        score,
        totalPoints,
        pointsEarned,
        timeSpentSeconds,
        attemptNumber,
        bestScore,
        startedAt,
        completedAt,
        updatedAt,
        isCompleted,
      ];
}
