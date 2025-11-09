import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/teacher_profile.dart' as teacher;
import '../models/activity.dart';
import '../models/question_template.dart';
import '../models/user_type.dart';

/// Service for managing teacher-specific operations including content creation and publishing
class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String teachersCollection = 'teachers';
  static const String activitiesCollection = 'activities';
  static const String templatesCollection =
      'curriculumQuestionTemplates'; // New collection for structured curriculum questions
  static const String oldTemplatesCollection =
      'questionTemplates'; // Old collection for backwards compatibility
  static const String publishingQueueCollection = 'publishingQueue';

  /// Get teacher profile by ID
  Future<teacher.TeacherProfile?> getTeacherProfile(String teacherId) async {
    try {
      final doc =
          await _firestore.collection(teachersCollection).doc(teacherId).get();

      if (!doc.exists) return null;

      return teacher.TeacherProfile.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting teacher profile: $e');
      return null;
    }
  }

  /// Create or update teacher profile
  Future<void> upsertTeacherProfile(teacher.TeacherProfile profile) async {
    try {
      await _firestore
          .collection(teachersCollection)
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error upserting teacher profile: $e');
      rethrow;
    }
  }

  /// Get question templates available to teacher based on their specializations
  Future<List<QuestionTemplate>> getQuestionTemplates({
    String? teacherId,
    List<ActivitySubject>? subjects,
    List<AgeGroup>? ageGroups,
  }) async {
    try {
      debugPrint('🔍 Loading question templates...');
      debugPrint('Teacher ID: $teacherId');
      debugPrint('Subjects filter: $subjects');
      debugPrint('Age groups filter: $ageGroups');

      // Build query - try with isActive first, fallback to all if field doesn't exist
      Query<Map<String, dynamic>> query =
          _firestore.collection(templatesCollection);

      // Only filter by isActive if we know templates have this field
      // For now, try to get all active templates, but if that fails, get all
      try {
        query = query.where('isActive', isEqualTo: true);
      } catch (e) {
        debugPrint('⚠️ isActive filter not available, getting all templates');
        // Continue without isActive filter
      }

      // Filter by subjects if provided
      if (subjects != null && subjects.isNotEmpty) {
        final subjectNames = subjects.map((s) => s.name).toList();
        debugPrint('🔍 Filtering by subjects: $subjectNames');
        try {
          query = query.where('subjects', arrayContainsAny: subjectNames);
        } catch (e) {
          debugPrint('⚠️ Subject filter error: $e');
          // Continue without subject filter
        }
      }

      // Filter by age groups if provided
      if (ageGroups != null && ageGroups.isNotEmpty) {
        final ageGroupNames = ageGroups.map((g) => g.name).toList();
        debugPrint('🔍 Filtering by age groups: $ageGroupNames');
        try {
          query = query.where('ageGroups', arrayContainsAny: ageGroupNames);
        } catch (e) {
          debugPrint('⚠️ Age group filter error: $e');
          // Continue without age group filter
        }
      }

      // Try to order by title, but if that fails, just get documents
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await query.orderBy('title').get();
      } catch (e) {
        debugPrint('⚠️ Cannot order by title, getting without order: $e');
        snapshot = await query.get();
      }

      debugPrint('📊 Found ${snapshot.docs.length} templates in database');

      // Parse templates and apply additional client-side filtering if needed
      final templates = <QuestionTemplate>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Client-side filtering for isActive if field exists
          if (data.containsKey('isActive') && data['isActive'] != true) {
            continue;
          }

          // Client-side filtering for subjects if provided
          if (subjects != null && subjects.isNotEmpty) {
            final subjectsList = data['subjects'] as List?;
            final templateSubjects = subjectsList != null
                ? subjectsList
                    .map((s) => s?.toString().toLowerCase())
                    .whereType<String>()
                    .toList()
                : <String>[];
            final filterSubjects =
                subjects.map((s) => s.name.toLowerCase()).toList();

            if (!templateSubjects.any((s) => filterSubjects.contains(s))) {
              debugPrint('⏭️ Skipping template ${doc.id} - subject mismatch');
              continue;
            }
          }

          // Client-side filtering for age groups if provided
          if (ageGroups != null && ageGroups.isNotEmpty) {
            final ageGroupsList = data['ageGroups'] as List?;
            final templateAgeGroups = ageGroupsList != null
                ? ageGroupsList
                    .map((g) => g?.toString().toLowerCase())
                    .whereType<String>()
                    .toList()
                : <String>[];
            final filterAgeGroups =
                ageGroups.map((g) => g.name.toLowerCase()).toList();

            if (!templateAgeGroups.any((g) => filterAgeGroups.contains(g))) {
              debugPrint('⏭️ Skipping template ${doc.id} - age group mismatch');
              continue;
            }
          }

          final template = QuestionTemplate.fromJson({
            'id': doc.id,
            ...data,
          });
          templates.add(template);
        } catch (e) {
          debugPrint('❌ Error parsing template ${doc.id}: $e');
          continue;
        }
      }

      debugPrint('✅ Successfully loaded ${templates.length} templates');
      return templates;
    } catch (e) {
      debugPrint('❌ Error getting question templates: $e');
      return [];
    }
  }

  /// Create activity from question templates
  Future<String> createActivityFromTemplates({
    required String teacherId,
    required String title,
    required String description,
    required ActivitySubject subject,
    required AgeGroup ageGroup,
    required Difficulty difficulty,
    required List<String> templateIds,
    required List<String> learningObjectives,
    List<String> skills = const [],
    List<String> tags = const [],
    int durationMinutes = 5,
    int points = 100,
  }) async {
    try {
      // Validate teacher permissions
      final teacher = await getTeacherProfile(teacherId);
      if (teacher == null) {
        throw Exception('Teacher profile not found');
      }

      if (!teacher.authorizedAgeGroups.contains(ageGroup)) {
        throw Exception(
            'Teacher not authorized for age group: ${ageGroup.name}');
      }

      if (!teacher.authorizedSubjects.contains(subject)) {
        throw Exception(
            'Teacher not authorized for subject: ${subject.displayName}');
      }

      // Get templates
      final templates = <QuestionTemplate>[];
      for (final templateId in templateIds) {
        final doc = await _firestore
            .collection(templatesCollection)
            .doc(templateId)
            .get();

        if (doc.exists) {
          templates.add(QuestionTemplate.fromJson({
            'id': doc.id,
            ...doc.data()!,
          }));
        }
      }

      if (templates.isEmpty) {
        throw Exception('No valid templates found');
      }

      // Create questions from templates
      final questions = <ActivityQuestion>[];
      for (int i = 0; i < templates.length; i++) {
        final template = templates[i];
        final question = template.instantiate(
          questionId: 'q_${i + 1}',
        );
        questions.add(question);
      }

      // Create activity
      final now = DateTime.now();
      final activity = Activity(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        subject: subject,
        ageGroup: ageGroup,
        difficulty: difficulty,
        durationMinutes: durationMinutes,
        points: points,
        learningObjectives: learningObjectives,
        questions: questions,
        createdBy: teacherId,
        published: false,
        publishState: PublishState.draft,
        skills: skills,
        tags: tags,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection(activitiesCollection)
          .add(activity.toJson());

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating activity from templates: $e');
      rethrow;
    }
  }

  /// Publish activity with comprehensive review checks
  Future<void> publishActivity({
    required String activityId,
    required String teacherId,
  }) async {
    try {
      // Get activity
      final activityDoc = await _firestore
          .collection(activitiesCollection)
          .doc(activityId)
          .get();

      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }

      final activityData = activityDoc.data()!;
      final activity = Activity.fromJson({
        'id': activityDoc.id,
        ...activityData,
      });

      // Check if this is an Add Equations game from gameConfig or metadata
      bool isAddEquationsGame = activity.hasAddEquationsTag;
      final gameConfig = activityData['gameConfig'] as Map<String, dynamic>?;
      if (gameConfig != null) {
        final gameType = gameConfig['gameType'] as String?;
        if (_isAddEquationsGameType(gameType)) {
          isAddEquationsGame = true;
        }
      }
      final gameMetadata =
          activityData['gameMetadata'] as Map<String, dynamic>?;
      if (gameMetadata != null) {
        final gameType = gameMetadata['gameType'] as String?;
        if (_isAddEquationsGameType(gameType)) {
          isAddEquationsGame = true;
        }
      }

      // Verify teacher ownership
      if (activity.createdBy != teacherId) {
        throw Exception('Only the creator can publish this activity');
      }

      // Perform comprehensive review checks
      final reviewResult = await _performPublishingReview(activity,
          isAddEquationsGame: isAddEquationsGame);
      if (!reviewResult.isValid) {
        throw Exception(
            'Activity failed review: ${reviewResult.reasons.join(', ')}');
      }

      // Update publish state
      await _firestore.collection(activitiesCollection).doc(activityId).update({
        'publishState': PublishState.published.name,
        'published': true,
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log publishing event
      await _firestore.collection(publishingQueueCollection).add({
        'activityId': activityId,
        'teacherId': teacherId,
        'action': 'published',
        'timestamp': FieldValue.serverTimestamp(),
        'reviewResult': reviewResult.toJson(),
      });
    } catch (e) {
      debugPrint('Error publishing activity: $e');
      rethrow;
    }
  }

  /// Comprehensive review checks for publishing
  Future<PublishingReviewResult> _performPublishingReview(
    Activity activity, {
    bool isAddEquationsGame = false,
  }) async {
    final reasons = <String>[];

    // Minimum/maximum questions check
    if (activity.questions.length < 3) {
      reasons.add('Activity must have at least 3 questions');
    }
    if (activity.questions.length > 20) {
      reasons.add('Activity cannot exceed 20 questions');
    }

    // Check if this is an Add Equations game (check tags if not already determined)
    // Add Equations game provides its own visual interface, so media is not required
    if (!isAddEquationsGame) {
      isAddEquationsGame = activity.hasAddEquationsTag;
    }

    // Media and accessibility checks
    for (int i = 0; i < activity.questions.length; i++) {
      final question = activity.questions[i];

      // Interactive questions need media
      // Exception: Add Equations game provides its own visual interface, so media is not required
      if ((question.type == QuestionType.dragDrop ||
              question.type == QuestionType.matching) &&
          !isAddEquationsGame && // Skip media requirement for Add Equations game
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
    }

    // Age-appropriate content checks
    if (activity.ageGroup == AgeGroup.junior) {
      // Junior Explorer specific checks
      if (activity.difficulty == Difficulty.hard &&
          activity.questions.length > 8) {
        reasons.add(
            'Junior Explorer activities with hard difficulty should have max 8 questions');
      }
    } else if (activity.ageGroup == AgeGroup.bright) {
      // Bright Minds specific checks
      if (activity.difficulty == Difficulty.easy &&
          activity.questions.length < 5) {
        reasons.add('Bright Minds activities should have at least 5 questions');
      }
    }

    // Skills and tags for discoverability
    if (activity.skills.isEmpty) {
      reasons.add('Activity must include at least one skill tag');
    }
    if (activity.tags.isEmpty) {
      reasons.add('Activity must include at least one general tag');
    }

    // Learning objectives check
    if (activity.learningObjectives.isEmpty) {
      reasons.add('Activity must include learning objectives');
    }

    // Duration appropriateness
    if (activity.durationMinutes < 1 || activity.durationMinutes > 30) {
      reasons.add('Activity duration should be between 1-30 minutes');
    }

    return PublishingReviewResult(
      isValid: reasons.isEmpty,
      reasons: reasons,
      checkedAt: DateTime.now(),
    );
  }

  /// Get teacher's activities (drafts and published)
  Future<List<Activity>> getTeacherActivities({
    required String teacherId,
    PublishState? publishState,
    ActivitySubject? subject,
    AgeGroup? ageGroup,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(activitiesCollection)
          .where('createdBy', isEqualTo: teacherId);

      if (publishState != null) {
        query = query.where('publishState', isEqualTo: publishState.name);
      }

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject.name);
      }

      if (ageGroup != null) {
        query = query.where('ageGroup', isEqualTo: ageGroup.name);
      }

      final snapshot = await query.orderBy('updatedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => Activity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting teacher activities: $e');
      return [];
    }
  }

  /// Get publishing statistics for teacher
  Future<TeacherPublishingStats> getPublishingStats(String teacherId) async {
    try {
      final activities = await getTeacherActivities(teacherId: teacherId);

      final stats = TeacherPublishingStats(
        totalActivities: activities.length,
        publishedActivities: activities
            .where((a) => a.publishState == PublishState.published)
            .length,
        draftActivities: activities
            .where((a) => a.publishState == PublishState.draft)
            .length,
        activitiesBySubject: <ActivitySubject, int>{},
        activitiesByAgeGroup: <AgeGroup, int>{},
      );

      // Count by subject
      for (final activity in activities) {
        stats.activitiesBySubject[activity.subject] =
            (stats.activitiesBySubject[activity.subject] ?? 0) + 1;
        stats.activitiesByAgeGroup[activity.ageGroup] =
            (stats.activitiesByAgeGroup[activity.ageGroup] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting publishing stats: $e');
      return TeacherPublishingStats(
        totalActivities: 0,
        publishedActivities: 0,
        draftActivities: 0,
        activitiesBySubject: {},
        activitiesByAgeGroup: {},
      );
    }
  }
}

/// Result of publishing review checks
class PublishingReviewResult {
  final bool isValid;
  final List<String> reasons;
  final DateTime checkedAt;

  const PublishingReviewResult({
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

/// Publishing statistics for a teacher
class TeacherPublishingStats {
  final int totalActivities;
  final int publishedActivities;
  final int draftActivities;
  final Map<ActivitySubject, int> activitiesBySubject;
  final Map<AgeGroup, int> activitiesByAgeGroup;

  const TeacherPublishingStats({
    required this.totalActivities,
    required this.publishedActivities,
    required this.draftActivities,
    required this.activitiesBySubject,
    required this.activitiesByAgeGroup,
  });

  double get publishRate =>
      totalActivities > 0 ? publishedActivities / totalActivities : 0.0;
}

String _normalizeGameTypeFlag(String? value) {
  if (value == null) return '';
  var normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  if (normalized.startsWith('gametype')) {
    normalized = normalized.substring('gametype'.length);
  }
  return normalized;
}

bool _isAddEquationsGameType(String? value) =>
    _normalizeGameTypeFlag(value) == 'addequations';
