import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/user_type.dart';

/// Utility class for publishing constraints and validation messages
class PublishingConstraintsUtils {
  /// Get all publishing constraints in a friendly format
  static List<ConstraintInfo> getAllConstraints() {
    return [
      // General constraints
      ConstraintInfo(
        category: 'General Requirements',
        constraints: [
          'Activity must have a title and description',
          'At least 3 questions required (maximum 20)',
          'At least one learning objective is required',
          'At least one skill tag is required',
        ],
        icon: Icons.info_outline,
        color: Colors.blue,
      ),

      // Game limit constraints
      ConstraintInfo(
        category: 'Game Limits',
        constraints: [
          'Maximum 10 games per activity',
          'Each game can contain multiple questions',
          'Activity duration is calculated based on number of games',
        ],
        icon: Icons.games,
        color: Colors.orange,
      ),

      // Age group constraints
      ConstraintInfo(
        category: 'Junior Explorer (6-8)',
        constraints: [
          'Hard difficulty: Maximum 8 questions',
          'Age-appropriate vocabulary required',
          'Simplified explanations needed',
        ],
        icon: Icons.child_care,
        color: Colors.orange,
      ),

      ConstraintInfo(
        category: 'Bright Minds (9-12)',
        constraints: [
          'Easy difficulty: Minimum 5 questions',
          'More complex concepts allowed',
        ],
        icon: Icons.school,
        color: Colors.purple,
      ),

      // Content constraints
      ConstraintInfo(
        category: 'Content Safety',
        constraints: [
          'No inappropriate content',
          'Images must have alt text for accessibility',
          'Interactive questions need supporting media',
        ],
        icon: Icons.shield,
        color: Colors.green,
      ),
    ];
  }

  /// Get constraints specific to age group and difficulty
  static List<String> getSpecificConstraints({
    required AgeGroup ageGroup,
    required Difficulty difficulty,
  }) {
    final constraints = <String>[];

    if (ageGroup == AgeGroup.junior) {
      if (difficulty == Difficulty.hard) {
        constraints.add('Junior Explorer hard activities: Maximum 8 questions');
      }
    } else if (ageGroup == AgeGroup.bright) {
      if (difficulty == Difficulty.easy) {
        constraints.add('Bright Minds easy activities: Minimum 5 questions');
      }
    }

    // Game limit constraints
    constraints.add('Maximum 10 games per activity');

    return constraints;
  }

  /// Format validation error messages in a friendly way
  static String formatValidationError(String rawError) {
    // Remove "Activity failed" prefix and make more user-friendly
    String error = rawError.replaceAll('Activity failed safety review: ', '');
    error = error.replaceAll('Activity failed visibility rules: ', '');

    // Format duration errors
    if (error.contains('duration') || error.contains('minutes')) {
      if (error.contains('should be between 1-30')) {
        return 'Duration must be between 1 and 30 minutes (excluding game play time)';
      }
      if (error.contains('cannot exceed')) {
        return error.replaceAll(' activities cannot exceed', ': Maximum');
      }
    }

    // Format question count errors
    if (error.contains('must have at least')) {
      return error.replaceAll('activities ', '');
    }
    if (error.contains('cannot exceed')) {
      return error.replaceAll('activities ', '');
    }

    // Format difficulty-specific errors
    if (error.contains('easy') ||
        error.contains('medium') ||
        error.contains('hard')) {
      // Already formatted, just capitalize first letter
      return error.substring(0, 1).toUpperCase() + error.substring(1);
    }

    return error.substring(0, 1).toUpperCase() + error.substring(1);
  }
}

class ConstraintInfo {
  final String category;
  final List<String> constraints;
  final IconData icon;
  final Color color;

  const ConstraintInfo({
    required this.category,
    required this.constraints,
    required this.icon,
    required this.color,
  });
}
