import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/user_type.dart';

/// Service for managing content publishing with comprehensive safety and visibility rules
class PublishingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String activitiesCollection = 'activities';
  static const String publishingQueueCollection = 'publishingQueue';
  static const String contentModerationCollection = 'contentModeration';
  static const String visibilityRulesCollection = 'visibilityRules';

  /// Publish activity with comprehensive safety checks
  Future<PublishingResult> publishActivity({
    required String activityId,
    required String teacherId,
    required UserType actorRole,
  }) async {
    try {
      // Verify permissions
      if (actorRole != UserType.teacher && actorRole != UserType.admin) {
        return PublishingResult.failure(
            'Only teachers and admins can publish activities');
      }

      // Get activity
      final activityDoc = await _firestore
          .collection(activitiesCollection)
          .doc(activityId)
          .get();

      if (!activityDoc.exists) {
        return PublishingResult.failure('Activity not found');
      }

      final activity = Activity.fromJson({
        'id': activityDoc.id,
        ...activityDoc.data()!,
      });

      // Verify teacher ownership
      if (activity.createdBy != teacherId) {
        return PublishingResult.failure(
            'Only the creator can publish this activity');
      }

      // Perform comprehensive safety review
      final reviewResult = await _performSafetyReview(activity);
      if (!reviewResult.isValid) {
        return PublishingResult.failure(
            'Activity failed safety review: ${reviewResult.reasons.join(', ')}');
      }

      // Apply visibility rules
      final visibilityResult = await _applyVisibilityRules(activity);
      if (!visibilityResult.isValid) {
        return PublishingResult.failure(
            'Activity failed visibility rules: ${visibilityResult.reasons.join(', ')}');
      }

      // Update publish state
      await _firestore.collection(activitiesCollection).doc(activityId).update({
        'publishState': PublishState.published.name,
        'published': true,
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'visibilityRules': visibilityResult.appliedRules,
        'safetyReview': reviewResult.toJson(),
      });

      // Log publishing event
      await _logPublishingEvent(
        activityId: activityId,
        teacherId: teacherId,
        action: 'published',
        reviewResult: reviewResult,
        visibilityResult: visibilityResult,
      );

      return PublishingResult.success('Activity published successfully');
    } catch (e) {
      debugPrint('Error publishing activity: $e');
      return PublishingResult.failure('Failed to publish activity: $e');
    }
  }

  /// Comprehensive safety review for child-safe content
  Future<SafetyReviewResult> _performSafetyReview(Activity activity) async {
    final reasons = <String>[];

    // Content validation
    if (activity.title.trim().isEmpty) {
      reasons.add('Activity title is required');
    }
    if (activity.description.trim().isEmpty) {
      reasons.add('Activity description is required');
    }
    if (activity.learningObjectives.isEmpty) {
      reasons.add('Learning objectives are required');
    }

    // Question validation
    if (activity.questions.length < 3) {
      reasons.add('Activity must have at least 3 questions');
    }
    if (activity.questions.length > 20) {
      reasons.add('Activity cannot exceed 20 questions');
    }

    // Age-appropriate content checks
    for (int i = 0; i < activity.questions.length; i++) {
      final question = activity.questions[i];

      // Check for inappropriate content
      if (_containsInappropriateContent(question.question)) {
        reasons.add('Question ${i + 1}: Contains inappropriate content');
      }

      // Interactive questions need media
      if ((question.type == QuestionType.dragDrop ||
              question.type == QuestionType.matching) &&
          question.media.imageUrl == null &&
          question.media.audioUrl == null &&
          question.media.videoUrl == null) {
        reasons.add(
            'Question ${i + 1}: Interactive questions must include supporting media');
      }

      // Images need alt text for accessibility
      if (question.media.imageUrl != null &&
          (question.media.altText == null ||
              question.media.altText!.trim().isEmpty)) {
        reasons.add(
            'Question ${i + 1}: Images must include accessibility alt text');
      }

      // Check media content safety
      if (question.media.imageUrl != null) {
        final mediaSafety = await _checkMediaSafety(question.media.imageUrl!);
        if (!mediaSafety.isSafe) {
          reasons.add('Question ${i + 1}: Image content is not appropriate');
        }
      }
    }

    // Age-specific validation
    if (activity.ageGroup == AgeGroup.junior) {
      // Junior Explorer (6-8) specific checks
      if (activity.difficulty == Difficulty.hard &&
          activity.questions.length > 8) {
        reasons.add(
            'Junior Explorer activities with hard difficulty should have max 8 questions');
      }

      // Check for age-appropriate vocabulary
      for (int i = 0; i < activity.questions.length; i++) {
        if (_containsAdvancedVocabulary(activity.questions[i].question)) {
          reasons.add(
              'Question ${i + 1}: Contains vocabulary too advanced for Junior Explorer age group');
        }
      }
    } else if (activity.ageGroup == AgeGroup.bright) {
      // Bright Minds (9-12) specific checks
      if (activity.difficulty == Difficulty.easy &&
          activity.questions.length < 5) {
        reasons.add('Bright Minds activities should have at least 5 questions');
      }
    }

    // Skills and tags validation
    if (activity.skills.isEmpty) {
      reasons.add('Activity must include at least one skill tag');
    }
    if (activity.tags.isEmpty) {
      reasons.add('Activity must include at least one general tag');
    }

    // Duration appropriateness
    if (activity.durationMinutes < 1 || activity.durationMinutes > 30) {
      reasons.add('Activity duration should be between 1-30 minutes');
    }

    return SafetyReviewResult(
      isValid: reasons.isEmpty,
      reasons: reasons,
      checkedAt: DateTime.now(),
    );
  }

  /// Apply visibility rules based on age group and content
  Future<VisibilityResult> _applyVisibilityRules(Activity activity) async {
    final reasons = <String>[];
    final appliedRules = <String>[];

    // Get visibility rules for the age group
    final rulesDoc = await _firestore
        .collection(visibilityRulesCollection)
        .doc(activity.ageGroup.name)
        .get();

    if (rulesDoc.exists) {
      final rules = rulesDoc.data()!;

      // Apply subject-specific rules
      final subjectRules = rules['subjects'] as Map<String, dynamic>?;
      if (subjectRules != null &&
          subjectRules.containsKey(activity.subject.name)) {
        final subjectRule =
            subjectRules[activity.subject.name] as Map<String, dynamic>;
        appliedRules.add('subject_${activity.subject.name}');

        // Check minimum questions for subject
        final minQuestions = subjectRule['minQuestions'] as int?;
        if (minQuestions != null && activity.questions.length < minQuestions) {
          reasons.add(
              '${activity.subject.displayName} activities must have at least $minQuestions questions');
        }
      }

      // Apply difficulty-specific rules
      final difficultyRules = rules['difficulties'] as Map<String, dynamic>?;
      if (difficultyRules != null &&
          difficultyRules.containsKey(activity.difficulty.name)) {
        final difficultyRule =
            difficultyRules[activity.difficulty.name] as Map<String, dynamic>;
        appliedRules.add('difficulty_${activity.difficulty.name}');

        // Check duration limits
        final maxDuration = difficultyRule['maxDuration'] as int?;
        if (maxDuration != null && activity.durationMinutes > maxDuration) {
          reasons.add(
              '${activity.difficulty.name} activities cannot exceed $maxDuration minutes');
        }
      }

      // Apply content safety rules
      final safetyRules = rules['safety'] as Map<String, dynamic>?;
      if (safetyRules != null) {
        appliedRules.add('safety_rules');

        // Check for required accessibility features
        final requireAltText = safetyRules['requireAltText'] as bool? ?? true;
        if (requireAltText) {
          for (int i = 0; i < activity.questions.length; i++) {
            if (activity.questions[i].media.imageUrl != null &&
                (activity.questions[i].media.altText == null ||
                    activity.questions[i].media.altText!.trim().isEmpty)) {
              reasons.add(
                  'Question ${i + 1}: Alt text required for accessibility');
            }
          }
        }
      }
    }

    return VisibilityResult(
      isValid: reasons.isEmpty,
      reasons: reasons,
      appliedRules: appliedRules,
      checkedAt: DateTime.now(),
    );
  }

  /// Check for inappropriate content in text
  bool _containsInappropriateContent(String text) {
    // Simple keyword filtering - in production, this would use more sophisticated content moderation
    final inappropriateKeywords = [
      'violence', 'weapon', 'inappropriate', 'adult', 'mature',
      // Add more keywords as needed
    ];

    final lowerText = text.toLowerCase();
    return inappropriateKeywords.any((keyword) => lowerText.contains(keyword));
  }

  /// Check for advanced vocabulary not suitable for younger age groups
  bool _containsAdvancedVocabulary(String text) {
    // Advanced vocabulary that might be too complex for Junior Explorer (6-8)
    final advancedWords = [
      'sophisticated', 'complex', 'intricate', 'comprehensive', 'analytical',
      'theoretical', 'philosophical', 'metaphorical', 'abstract', 'conceptual',
      // Add more advanced words as needed
    ];

    final lowerText = text.toLowerCase();
    return advancedWords.any((word) => lowerText.contains(word));
  }

  /// Check media content safety (placeholder for actual content moderation)
  Future<MediaSafetyResult> _checkMediaSafety(String mediaUrl) async {
    // In production, this would integrate with content moderation APIs
    // For now, we'll do basic URL validation
    try {
      final uri = Uri.parse(mediaUrl);
      if (uri.scheme != 'https') {
        return MediaSafetyResult(isSafe: false, reason: 'Media must use HTTPS');
      }

      // Additional checks would go here
      return MediaSafetyResult(isSafe: true);
    } catch (e) {
      return MediaSafetyResult(isSafe: false, reason: 'Invalid media URL');
    }
  }

  /// Log publishing events for audit trail
  Future<void> _logPublishingEvent({
    required String activityId,
    required String teacherId,
    required String action,
    required SafetyReviewResult reviewResult,
    required VisibilityResult visibilityResult,
  }) async {
    await _firestore.collection(publishingQueueCollection).add({
      'activityId': activityId,
      'teacherId': teacherId,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
      'safetyReview': reviewResult.toJson(),
      'visibilityResult': visibilityResult.toJson(),
      'metadata': {
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewerId': teacherId,
      },
    });
  }

  /// Get publishing statistics for monitoring
  Future<PublishingStats> getPublishingStats({
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(publishingQueueCollection)
          .where('action', isEqualTo: 'published');

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();

      final totalPublished = snapshot.docs.length;
      final failedReviews = snapshot.docs
          .where((doc) => doc.data()['safetyReview']?['isValid'] == false)
          .length;
      final successfulPublishes = totalPublished - failedReviews;

      return PublishingStats(
        totalPublished: totalPublished,
        successfulPublishes: successfulPublishes,
        failedReviews: failedReviews,
        successRate:
            totalPublished > 0 ? successfulPublishes / totalPublished : 0.0,
      );
    } catch (e) {
      debugPrint('Error getting publishing stats: $e');
      return PublishingStats(
        totalPublished: 0,
        successfulPublishes: 0,
        failedReviews: 0,
        successRate: 0.0,
      );
    }
  }
}

/// Result of publishing operation
class PublishingResult {
  final bool isSuccess;
  final String message;

  const PublishingResult._(this.isSuccess, this.message);

  factory PublishingResult.success(String message) =>
      PublishingResult._(true, message);
  factory PublishingResult.failure(String message) =>
      PublishingResult._(false, message);
}

/// Result of safety review
class SafetyReviewResult {
  final bool isValid;
  final List<String> reasons;
  final DateTime checkedAt;

  const SafetyReviewResult({
    required this.isValid,
    required this.reasons,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'reasons': reasons,
      'checkedAt': checkedAt.toIso8601String(),
    };
  }
}

/// Result of visibility rules application
class VisibilityResult {
  final bool isValid;
  final List<String> reasons;
  final List<String> appliedRules;
  final DateTime checkedAt;

  const VisibilityResult({
    required this.isValid,
    required this.reasons,
    required this.appliedRules,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'reasons': reasons,
      'appliedRules': appliedRules,
      'checkedAt': checkedAt.toIso8601String(),
    };
  }
}

/// Result of media safety check
class MediaSafetyResult {
  final bool isSafe;
  final String? reason;

  const MediaSafetyResult({
    required this.isSafe,
    this.reason,
  });
}

/// Publishing statistics
class PublishingStats {
  final int totalPublished;
  final int successfulPublishes;
  final int failedReviews;
  final double successRate;

  const PublishingStats({
    required this.totalPublished,
    required this.successfulPublishes,
    required this.failedReviews,
    required this.successRate,
  });
}
