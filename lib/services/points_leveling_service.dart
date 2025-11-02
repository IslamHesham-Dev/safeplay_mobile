import 'package:flutter/foundation.dart';
import '../models/user_type.dart';
import '../models/activity.dart';
import 'children_progress_service.dart';

/// Service for managing points, levels, and rewards system
/// Handles point calculation, level progression, and achievement unlocking
class PointsLevelingService {
  final ChildrenProgressService _progressService;

  PointsLevelingService({ChildrenProgressService? progressService})
      : _progressService = progressService ?? ChildrenProgressService();

  // Points thresholds for levels
  static const Map<AgeGroup, List<int>> levelThresholds = {
    AgeGroup.junior: [
      0, // Level 1
      50, // Level 2
      150, // Level 3
      300, // Level 4
      500, // Level 5
      750, // Level 6
      1050, // Level 7
      1400, // Level 8
      1800, // Level 9
      2250, // Level 10
    ],
    AgeGroup.bright: [
      0, // Level 1
      100, // Level 2
      250, // Level 3
      450, // Level 4
      700, // Level 5
      1000, // Level 6
      1350, // Level 7
      1750, // Level 8
      2200, // Level 9
      2700, // Level 10
    ],
  };

  // Points per question based on difficulty and age group
  static int getPointsPerQuestion({
    required AgeGroup ageGroup,
    required Difficulty difficulty,
    required bool isCorrect,
    required int timeSpentSeconds,
    int basePoints = 10,
  }) {
    // Base points by age group
    int points = ageGroup == AgeGroup.junior ? 15 : 20;

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

    // Time bonus (faster = more points)
    double timeMultiplier = 1.0;
    final optimalTime = ageGroup == AgeGroup.junior ? 30 : 20; // seconds
    if (timeSpentSeconds <= optimalTime && isCorrect) {
      // Bonus for quick correct answers
      timeMultiplier = 1.5;
    } else if (timeSpentSeconds > optimalTime * 3) {
      // Penalty for very slow answers
      timeMultiplier = 0.8;
    }

    // Accuracy multiplier
    double accuracyMultiplier =
        isCorrect ? 1.0 : 0.2; // 20% points for attempts

    // Calculate final points
    final finalPoints =
        (points * difficultyMultiplier * timeMultiplier * accuracyMultiplier)
            .round();

    return finalPoints.clamp(0, 100); // Cap at 100 points per question
  }

  /// Calculate points earned for a game session
  Future<int> calculateSessionPoints({
    required String childId,
    required int correctAnswers,
    required int totalQuestions,
    required int timeSpentSeconds,
    required Difficulty difficulty,
    required AgeGroup ageGroup,
  }) async {
    try {
      final avgTimePerQuestion =
          totalQuestions > 0 ? timeSpentSeconds / totalQuestions : 0;

      int totalPoints = 0;

      // Points for each correct answer
      for (int i = 0; i < correctAnswers; i++) {
        totalPoints += getPointsPerQuestion(
          ageGroup: ageGroup,
          difficulty: difficulty,
          isCorrect: true,
          timeSpentSeconds: avgTimePerQuestion.round(),
        );
      }

      // Bonus for completion
      if (correctAnswers == totalQuestions) {
        // Perfect score bonus
        final perfectBonus = ageGroup == AgeGroup.junior ? 50 : 75;
        totalPoints += perfectBonus;
      }

      // Bonus for time efficiency
      final optimalTime =
          totalQuestions * (ageGroup == AgeGroup.junior ? 30 : 20);
      if (timeSpentSeconds < optimalTime && correctAnswers == totalQuestions) {
        final speedBonus = ageGroup == AgeGroup.junior ? 25 : 35;
        totalPoints += speedBonus;
      }

      // Streak bonus (if child has been playing well)
      final streak = await _getCurrentStreak(childId);
      if (streak > 0) {
        final streakBonus = (streak * 5).clamp(0, 50); // Max 50 points
        totalPoints += streakBonus;
      }

      debugPrint(
          '🎯 Points calculated: $totalPoints (correct: $correctAnswers/$totalQuestions, time: ${timeSpentSeconds}s)');
      return totalPoints;
    } catch (e) {
      debugPrint('❌ Error calculating session points: $e');
      return 0;
    }
  }

  /// Get current level for a child based on total points
  int getLevel({
    required int totalPoints,
    required AgeGroup ageGroup,
  }) {
    final thresholds =
        levelThresholds[ageGroup] ?? levelThresholds[AgeGroup.junior]!;

    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (totalPoints >= thresholds[i]) {
        return i + 1; // Levels are 1-indexed
      }
    }

    return 1; // Default to level 1
  }

  /// Get points needed for next level
  int getPointsForNextLevel({
    required int currentLevel,
    required int totalPoints,
    required AgeGroup ageGroup,
  }) {
    final thresholds =
        levelThresholds[ageGroup] ?? levelThresholds[AgeGroup.junior]!;

    if (currentLevel >= thresholds.length) {
      return 0; // Max level reached
    }

    final nextLevelPoints = thresholds[currentLevel]; // Next level threshold
    return nextLevelPoints - totalPoints;
  }

  /// Get progress percentage to next level
  double getLevelProgress({
    required int currentLevel,
    required int totalPoints,
    required AgeGroup ageGroup,
  }) {
    final thresholds =
        levelThresholds[ageGroup] ?? levelThresholds[AgeGroup.junior]!;

    if (currentLevel >= thresholds.length) {
      return 1.0; // Max level reached
    }

    final currentLevelPoints =
        thresholds[currentLevel - 1]; // Current level threshold
    final nextLevelPoints = thresholds[currentLevel]; // Next level threshold
    final progressInLevel = totalPoints - currentLevelPoints;
    final pointsForLevel = nextLevelPoints - currentLevelPoints;

    if (pointsForLevel <= 0) return 1.0;

    return (progressInLevel / pointsForLevel).clamp(0.0, 1.0);
  }

  /// Update child progress with points and check for level up
  Future<LevelUpResult> updateChildProgress({
    required String childId,
    required int pointsEarned,
    required AgeGroup ageGroup,
  }) async {
    try {
      final progress = await _progressService.getChildProgress(childId);
      if (progress == null) {
        throw Exception('Could not retrieve child progress');
      }

      final oldTotalPoints = progress.earnedPoints;
      final oldLevel =
          getLevel(totalPoints: oldTotalPoints, ageGroup: ageGroup);

      final newTotalPoints = oldTotalPoints + pointsEarned;
      final newLevel =
          getLevel(totalPoints: newTotalPoints, ageGroup: ageGroup);

      final leveledUp = newLevel > oldLevel;
      final levelProgress = getLevelProgress(
        currentLevel: newLevel,
        totalPoints: newTotalPoints,
        ageGroup: ageGroup,
      );
      final pointsToNextLevel = getPointsForNextLevel(
        currentLevel: newLevel,
        totalPoints: newTotalPoints,
        ageGroup: ageGroup,
      );

      // Update progress
      final updatedProgress = progress.copyWith(
        earnedPoints: newTotalPoints,
        lastActiveDate: DateTime.now(),
      );

      await _progressService.updateChildProgress(updatedProgress);

      return LevelUpResult(
        leveledUp: leveledUp,
        newLevel: newLevel,
        oldLevel: oldLevel,
        totalPoints: newTotalPoints,
        pointsEarned: pointsEarned,
        levelProgress: levelProgress,
        pointsToNextLevel: pointsToNextLevel,
      );
    } catch (e) {
      debugPrint('❌ Error updating child progress: $e');
      rethrow;
    }
  }

  /// Get current streak (consecutive days with activity)
  Future<int> _getCurrentStreak(String childId) async {
    try {
      final progress = await _progressService.getChildProgress(childId);
      if (progress == null) return 0;

      // Simple streak calculation based on last active date
      // In a full implementation, you'd track daily activity
      final now = DateTime.now();
      final lastActive = progress.lastActiveDate;

      final daysSinceActive = now.difference(lastActive).inDays;

      // Streak continues if active within last day
      return daysSinceActive <= 1 ? 1 : 0;
    } catch (e) {
      debugPrint('❌ Error getting streak: $e');
      return 0;
    }
  }

  /// Get achievement suggestions based on progress
  List<AchievementSuggestion> getAchievementSuggestions({
    required int totalPoints,
    required int completedLessons,
    required AgeGroup ageGroup,
  }) {
    final suggestions = <AchievementSuggestion>[];

    // Point milestones
    final pointMilestones = ageGroup == AgeGroup.junior
        ? [100, 250, 500, 1000, 2000]
        : [200, 500, 1000, 2000, 3000];

    for (final milestone in pointMilestones) {
      if (totalPoints >= milestone && totalPoints < milestone * 1.1) {
        // Recently achieved
        suggestions.add(AchievementSuggestion(
          type: AchievementType.pointsMilestone,
          title: 'Points Master!',
          description: 'Reached $milestone points!',
          points: milestone,
        ));
      }
    }

    // Lesson completion milestones
    final lessonMilestones =
        ageGroup == AgeGroup.junior ? [5, 10, 25, 50] : [10, 25, 50, 100];

    for (final milestone in lessonMilestones) {
      if (completedLessons >= milestone && completedLessons < milestone + 5) {
        suggestions.add(AchievementSuggestion(
          type: AchievementType.lessonsCompleted,
          title: 'Learning Star!',
          description: 'Completed $milestone lessons!',
          points: milestone * 10,
        ));
      }
    }

    // Level milestones
    final currentLevel = getLevel(totalPoints: totalPoints, ageGroup: ageGroup);
    final levelMilestones = [3, 5, 7, 10];

    for (final milestone in levelMilestones) {
      if (currentLevel == milestone) {
        suggestions.add(AchievementSuggestion(
          type: AchievementType.levelUp,
          title: 'Level Up Champion!',
          description: 'Reached Level $milestone!',
          points: milestone * 50,
        ));
      }
    }

    return suggestions;
  }
}

/// Result of level up check
class LevelUpResult {
  final bool leveledUp;
  final int newLevel;
  final int oldLevel;
  final int totalPoints;
  final int pointsEarned;
  final double levelProgress; // 0.0 to 1.0
  final int pointsToNextLevel;

  const LevelUpResult({
    required this.leveledUp,
    required this.newLevel,
    required this.oldLevel,
    required this.totalPoints,
    required this.pointsEarned,
    required this.levelProgress,
    required this.pointsToNextLevel,
  });

  String get levelUpMessage {
    if (leveledUp) {
      return '🎉 Congratulations! You reached Level $newLevel!';
    }
    return 'Great job! Keep going!';
  }
}

/// Achievement suggestion
class AchievementSuggestion {
  final AchievementType type;
  final String title;
  final String description;
  final int points;

  const AchievementSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.points,
  });
}

/// Achievement types
enum AchievementType {
  pointsMilestone,
  lessonsCompleted,
  levelUp,
  perfectScore,
  streak,
  mastery,
}
