import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for enhanced app accessibility
class AccessibilityUtils {
  /// Announce to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if screen reader is active
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Get recommended font scale
  static double getAccessibleFontScale(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Clamp between 0.8 and 2.0 for readability
    return textScaleFactor.clamp(0.8, 2.0);
  }

  /// Check if high contrast is needed
  static bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get accessible touch target size
  static double getMinimumTouchTarget(BuildContext context, AgeGroup ageGroup) {
    if (ageGroup == AgeGroup.junior) {
      return 48.0; // Larger for younger children
    }
    return 44.0; // Standard for older children
  }

  /// Create semantic label for activity
  static String getActivitySemanticLabel(Activity activity) {
    return '${activity.title}, ${activity.subject}, '
        '${activity.estimatedDuration} minutes, '
        '${activity.points} points';
  }

  /// Create semantic label for progress
  static String getProgressSemanticLabel(int current, int total) {
    final percentage = ((current / total) * 100).round();
    return 'Progress: $current of $total, $percentage percent complete';
  }

  /// Create semantic label for streak
  static String getStreakSemanticLabel(int days) {
    return '$days day streak. Keep learning every day to maintain your streak!';
  }

  /// Create semantic label for level
  static String getLevelSemanticLabel(
      int level, int currentXP, int nextLevelXP) {
    final remaining = nextLevelXP - currentXP;
    return 'Level $level. $currentXP XP earned. $remaining XP needed for next level.';
  }

  /// Check if animations should be reduced
  static bool shouldReduceAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get accessible text style
  static TextStyle getAccessibleTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final scaleFactor = getAccessibleFontScale(context);
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scaleFactor,
      fontWeight:
          isHighContrastMode(context) ? FontWeight.w600 : baseStyle.fontWeight,
    );
  }

  /// Wrap widget with semantic label
  static Widget addSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool isButton = false,
    bool isHeader = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      header: isHeader,
      onTap: onTap,
      child: child,
    );
  }

  /// Create focus node for keyboard navigation
  static FocusNode createManagedFocusNode() {
    return FocusNode();
  }

  /// Auto-focus for accessibility
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }
}

/// Accessibility announcements for specific events
class AccessibilityAnnouncements {
  static void announceActivityStart(BuildContext context, String activityName) {
    AccessibilityUtils.announce(
      context,
      'Starting activity: $activityName',
    );
  }

  static void announceCorrectAnswer(BuildContext context) {
    AccessibilityUtils.announce(context, 'Correct answer! Well done!');
  }

  static void announceIncorrectAnswer(BuildContext context) {
    AccessibilityUtils.announce(context, 'Incorrect answer. Try again!');
  }

  static void announceActivityComplete(
    BuildContext context,
    int score,
    int totalPoints,
  ) {
    final percentage = ((score / totalPoints) * 100).round();
    AccessibilityUtils.announce(
      context,
      'Activity completed! You scored $score out of $totalPoints. $percentage percent.',
    );
  }

  static void announceAchievementUnlocked(
    BuildContext context,
    String achievementName,
  ) {
    AccessibilityUtils.announce(
      context,
      'Achievement unlocked: $achievementName!',
    );
  }

  static void announceLevelUp(BuildContext context, int newLevel) {
    AccessibilityUtils.announce(
      context,
      'Level up! You are now level $newLevel!',
    );
  }
}

/// Age group enum (if not already defined)
enum AgeGroup {
  junior,
  bright;

  static AgeGroup? fromAge(int age) {
    if (age >= 6 && age <= 8) return AgeGroup.junior;
    if (age >= 9 && age <= 12) return AgeGroup.bright;
    return null;
  }
}

/// Activity placeholder (if not already defined)
class Activity {
  final String title;
  final String subject;
  final int estimatedDuration;
  final int points;

  Activity({
    required this.title,
    required this.subject,
    required this.estimatedDuration,
    required this.points,
  });
}

