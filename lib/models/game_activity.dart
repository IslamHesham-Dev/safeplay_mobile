import 'package:equatable/equatable.dart';
import 'activity.dart';
import 'user_type.dart';

/// Game types available for different age groups
enum GameType {
  // Junior Explorer Games (6-8 years)
  numberGridRace,
  koalaCounterAdventure,
  ordinalDragOrder,
  patternBuilder,

  // Bright Minds Games (9-12 years)
  fractionNavigator,
  inverseOperationChain,
  dataVisualization,
  cartesianGrid,

  // Universal Games
  memoryMatch,
  wordBuilder,
  storySequencer;

  String get displayName {
    switch (this) {
      case GameType.numberGridRace:
        return 'Number Grid Race';
      case GameType.koalaCounterAdventure:
        return 'Koala Counter\'s Adventure';
      case GameType.ordinalDragOrder:
        return 'Ordinal Order Challenge';
      case GameType.patternBuilder:
        return 'Pattern Builder';
      case GameType.fractionNavigator:
        return 'Fraction Navigator';
      case GameType.inverseOperationChain:
        return 'Inverse Operation Chain';
      case GameType.dataVisualization:
        return 'Data Visualization Lab';
      case GameType.cartesianGrid:
        return 'Cartesian Grid Explorer';
      case GameType.memoryMatch:
        return 'Memory Match';
      case GameType.wordBuilder:
        return 'Word Builder';
      case GameType.storySequencer:
        return 'Story Sequencer';
    }
  }

  String get description {
    switch (this) {
      case GameType.numberGridRace:
        return 'Fill in missing numbers on a 10x10 grid with counting patterns';
      case GameType.koalaCounterAdventure:
        return 'Use number lines and visual strategies for addition and subtraction';
      case GameType.ordinalDragOrder:
        return 'Practice ordinal numbers and positional language';
      case GameType.patternBuilder:
        return 'Complete visual and number patterns';
      case GameType.fractionNavigator:
        return 'Order and convert fractions, decimals, and percentages';
      case GameType.inverseOperationChain:
        return 'Solve equations using inverse operations and fact families';
      case GameType.dataVisualization:
        return 'Collect data and create graphs and charts';
      case GameType.cartesianGrid:
        return 'Plot coordinates and follow directional paths';
      case GameType.memoryMatch:
        return 'Match related concepts or images';
      case GameType.wordBuilder:
        return 'Build words from letters or syllables';
      case GameType.storySequencer:
        return 'Arrange story events in correct order';
    }
  }

  List<AgeGroup> get supportedAgeGroups {
    switch (this) {
      case GameType.numberGridRace:
      case GameType.koalaCounterAdventure:
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
        return [AgeGroup.junior];
      case GameType.fractionNavigator:
      case GameType.inverseOperationChain:
      case GameType.dataVisualization:
      case GameType.cartesianGrid:
        return [AgeGroup.bright];
      case GameType.memoryMatch:
      case GameType.wordBuilder:
      case GameType.storySequencer:
        return [AgeGroup.junior, AgeGroup.bright];
    }
  }

  List<ActivitySubject> get supportedSubjects {
    switch (this) {
      case GameType.numberGridRace:
      case GameType.koalaCounterAdventure:
      case GameType.fractionNavigator:
      case GameType.inverseOperationChain:
      case GameType.dataVisualization:
      case GameType.cartesianGrid:
        return [ActivitySubject.math];
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
        return [ActivitySubject.math, ActivitySubject.reading];
      case GameType.memoryMatch:
      case GameType.wordBuilder:
      case GameType.storySequencer:
        return [ActivitySubject.reading, ActivitySubject.writing];
    }
  }
}

/// Game configuration for a specific activity
class GameConfig extends Equatable {
  final GameType gameType;
  final Map<String, dynamic> settings;
  final List<String> questionTemplateIds;
  final int timeLimitSeconds;
  final int maxAttempts;
  final bool allowHints;
  final bool showProgress;
  final Map<String, dynamic> accessibilityOptions;

  const GameConfig({
    required this.gameType,
    required this.settings,
    required this.questionTemplateIds,
    this.timeLimitSeconds = 300, // 5 minutes default
    this.maxAttempts = 3,
    this.allowHints = true,
    this.showProgress = true,
    this.accessibilityOptions = const {},
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      gameType: GameType.values.firstWhere(
        (e) => e.name == json['gameType'],
        orElse: () => GameType.memoryMatch,
      ),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      questionTemplateIds: List<String>.from(json['questionTemplateIds'] ?? []),
      timeLimitSeconds: json['timeLimitSeconds'] ?? 300,
      maxAttempts: json['maxAttempts'] ?? 3,
      allowHints: json['allowHints'] ?? true,
      showProgress: json['showProgress'] ?? true,
      accessibilityOptions:
          Map<String, dynamic>.from(json['accessibilityOptions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.name,
      'settings': settings,
      'questionTemplateIds': questionTemplateIds,
      'timeLimitSeconds': timeLimitSeconds,
      'maxAttempts': maxAttempts,
      'allowHints': allowHints,
      'showProgress': showProgress,
      'accessibilityOptions': accessibilityOptions,
    };
  }

  @override
  List<Object?> get props => [
        gameType,
        settings,
        questionTemplateIds,
        timeLimitSeconds,
        maxAttempts,
        allowHints,
        showProgress,
        accessibilityOptions,
      ];
}

/// Game activity that extends the base Activity with game-specific features
class GameActivity extends Activity {
  final GameConfig gameConfig;
  final List<GameLevel> levels;
  final Map<String, dynamic> gameMetadata;
  final bool isMultiplayer;
  final int maxPlayers;

  const GameActivity({
    required super.id,
    required super.title,
    required super.description,
    required super.subject,
    super.pypPhase,
    required super.ageGroup,
    required super.difficulty,
    required super.durationMinutes,
    required super.points,
    required super.learningObjectives,
    super.prerequisites = const [],
    super.thumbnailUrl,
    required super.questions,
    required super.createdBy,
    required super.published,
    super.publishState = PublishState.published,
    super.skills = const [],
    super.tags = const [],
    required super.createdAt,
    required super.updatedAt,
    super.isOfflineAvailable = false,
    required this.gameConfig,
    this.levels = const [],
    this.gameMetadata = const {},
    this.isMultiplayer = false,
    this.maxPlayers = 1,
  });

  factory GameActivity.fromActivity(
    Activity activity, {
    required GameConfig gameConfig,
    List<GameLevel> levels = const [],
    Map<String, dynamic> gameMetadata = const {},
    bool isMultiplayer = false,
    int maxPlayers = 1,
  }) {
    return GameActivity(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      subject: activity.subject,
      pypPhase: activity.pypPhase,
      ageGroup: activity.ageGroup,
      difficulty: activity.difficulty,
      durationMinutes: activity.durationMinutes,
      points: activity.points,
      learningObjectives: activity.learningObjectives,
      prerequisites: activity.prerequisites,
      thumbnailUrl: activity.thumbnailUrl,
      questions: activity.questions,
      createdBy: activity.createdBy,
      published: activity.published,
      publishState: activity.publishState,
      skills: activity.skills,
      tags: activity.tags,
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
      isOfflineAvailable: activity.isOfflineAvailable,
      gameConfig: gameConfig,
      levels: levels,
      gameMetadata: gameMetadata,
      isMultiplayer: isMultiplayer,
      maxPlayers: maxPlayers,
    );
  }

  factory GameActivity.fromJson(Map<String, dynamic> json) {
    final baseActivity = Activity.fromJson(json);
    return GameActivity.fromActivity(
      baseActivity,
      gameConfig: GameConfig.fromJson(json['gameConfig'] ?? {}),
      levels: (json['levels'] as List?)
              ?.map((e) => GameLevel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gameMetadata: Map<String, dynamic>.from(json['gameMetadata'] ?? {}),
      isMultiplayer: json['isMultiplayer'] ?? false,
      maxPlayers: json['maxPlayers'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'gameConfig': gameConfig.toJson(),
      'levels': levels.map((e) => e.toJson()).toList(),
      'gameMetadata': gameMetadata,
      'isMultiplayer': isMultiplayer,
      'maxPlayers': maxPlayers,
    });
    return json;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        gameConfig,
        levels,
        gameMetadata,
        isMultiplayer,
        maxPlayers,
      ];
}

/// Game level configuration
class GameLevel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int levelNumber;
  final int pointsRequired;
  final List<String> questionTemplateIds;
  final Map<String, dynamic> levelSettings;
  final bool isUnlocked;

  const GameLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.levelNumber,
    required this.pointsRequired,
    required this.questionTemplateIds,
    this.levelSettings = const {},
    this.isUnlocked = false,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    return GameLevel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      levelNumber: json['levelNumber'] ?? 1,
      pointsRequired: json['pointsRequired'] ?? 0,
      questionTemplateIds: List<String>.from(json['questionTemplateIds'] ?? []),
      levelSettings: Map<String, dynamic>.from(json['levelSettings'] ?? {}),
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'levelNumber': levelNumber,
      'pointsRequired': pointsRequired,
      'questionTemplateIds': questionTemplateIds,
      'levelSettings': levelSettings,
      'isUnlocked': isUnlocked,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        levelNumber,
        pointsRequired,
        questionTemplateIds,
        levelSettings,
        isUnlocked,
      ];
}

/// Child's game session progress
class GameSessionProgress extends Equatable {
  final String id;
  final String childId;
  final String gameActivityId;
  final String sessionId;
  final GameType gameType;
  final Map<String, dynamic> gameState;
  final List<GameResponse> responses;
  final int currentLevel;
  final int pointsEarned;
  final int timeSpentSeconds;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const GameSessionProgress({
    required this.id,
    required this.childId,
    required this.gameActivityId,
    required this.sessionId,
    required this.gameType,
    this.gameState = const {},
    this.responses = const [],
    this.currentLevel = 1,
    this.pointsEarned = 0,
    this.timeSpentSeconds = 0,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
    this.metadata = const {},
  });

  factory GameSessionProgress.fromJson(Map<String, dynamic> json) {
    return GameSessionProgress(
      id: json['id'] ?? '',
      childId: json['childId'] ?? '',
      gameActivityId: json['gameActivityId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      gameType: GameType.values.firstWhere(
        (e) => e.name == json['gameType'],
        orElse: () => GameType.memoryMatch,
      ),
      gameState: Map<String, dynamic>.from(json['gameState'] ?? {}),
      responses: (json['responses'] as List?)
              ?.map((e) => GameResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentLevel: json['currentLevel'] ?? 1,
      pointsEarned: json['pointsEarned'] ?? 0,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      startedAt:
          DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'gameActivityId': gameActivityId,
      'sessionId': sessionId,
      'gameType': gameType.name,
      'gameState': gameState,
      'responses': responses.map((e) => e.toJson()).toList(),
      'currentLevel': currentLevel,
      'pointsEarned': pointsEarned,
      'timeSpentSeconds': timeSpentSeconds,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        gameActivityId,
        sessionId,
        gameType,
        gameState,
        responses,
        currentLevel,
        pointsEarned,
        timeSpentSeconds,
        startedAt,
        completedAt,
        isCompleted,
        metadata,
      ];
}

/// Individual game response from child
class GameResponse extends Equatable {
  final String id;
  final String questionId;
  final String questionTemplateId;
  final dynamic userAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final int pointsEarned;
  final int timeSpentSeconds;
  final DateTime answeredAt;
  final Map<String, dynamic> responseMetadata;

  const GameResponse({
    required this.id,
    required this.questionId,
    required this.questionTemplateId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    required this.timeSpentSeconds,
    required this.answeredAt,
    this.responseMetadata = const {},
  });

  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      id: json['id'] ?? '',
      questionId: json['questionId'] ?? '',
      questionTemplateId: json['questionTemplateId'] ?? '',
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'] ?? false,
      pointsEarned: json['pointsEarned'] ?? 0,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      answeredAt: DateTime.parse(
          json['answeredAt'] ?? DateTime.now().toIso8601String()),
      responseMetadata:
          Map<String, dynamic>.from(json['responseMetadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'questionTemplateId': questionTemplateId,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'timeSpentSeconds': timeSpentSeconds,
      'answeredAt': answeredAt.toIso8601String(),
      'responseMetadata': responseMetadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        questionId,
        questionTemplateId,
        userAnswer,
        correctAnswer,
        isCorrect,
        pointsEarned,
        timeSpentSeconds,
        answeredAt,
        responseMetadata,
      ];
}





