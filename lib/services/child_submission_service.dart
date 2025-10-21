import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/child_submission.dart';
import '../models/activity.dart';
import '../models/user_type.dart';

/// Service for managing child submissions and progress tracking
class ChildSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String submissionsCollection = 'childSubmissions';
  static const String analyticsCollection = 'childAnalytics';

  /// Submit a child's activity completion
  Future<String> submitActivity({
    required String childId,
    required String activityId,
    required String teacherId,
    required List<QuestionSubmission> questionSubmissions,
    required DateTime startedAt,
    DateTime? completedAt,
    Duration? timeSpent,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      // Calculate scores
      final totalScore =
          questionSubmissions.fold(0, (sum, q) => sum + q.pointsEarned);
      final maxPossibleScore =
          questionSubmissions.fold(0, (sum, q) => sum + q.maxPoints);
      final completionPercentage =
          maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0.0;

      final submission = ChildSubmission(
        id: '', // Will be set by Firestore
        childId: childId,
        activityId: activityId,
        teacherId: teacherId,
        questionSubmissions: questionSubmissions,
        totalScore: totalScore,
        maxPossibleScore: maxPossibleScore,
        completionPercentage: completionPercentage,
        startedAt: startedAt,
        completedAt: completedAt ?? DateTime.now(),
        timeSpent: timeSpent,
        status: completedAt != null
            ? SubmissionStatus.completed
            : SubmissionStatus.inProgress,
        metadata: metadata,
      );

      final docRef = await _firestore
          .collection(submissionsCollection)
          .add(submission.toJson());

      // Update child analytics
      await _updateChildAnalytics(childId, teacherId, submission);

      debugPrint('✅ Child submission saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error submitting child activity: $e');
      rethrow;
    }
  }

  /// Get all submissions for a specific child
  Future<List<ChildSubmission>> getChildSubmissions({
    required String childId,
    String? teacherId,
    AgeGroup? ageGroup,
    ActivitySubject? subject,
    SubmissionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(submissionsCollection)
          .where('childId', isEqualTo: childId);

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (fromDate != null) {
        query = query.where('startedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }

      if (toDate != null) {
        query = query.where('startedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }

      final snapshot = await query.orderBy('startedAt', descending: true).get();

      List<ChildSubmission> submissions = snapshot.docs
          .map((doc) => ChildSubmission.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      // Filter by age group and subject if needed (requires activity data)
      if (ageGroup != null || subject != null) {
        submissions =
            await _filterSubmissionsByActivity(submissions, ageGroup, subject);
      }

      return submissions;
    } catch (e) {
      debugPrint('❌ Error getting child submissions: $e');
      return [];
    }
  }

  /// Get submissions for a specific activity
  Future<List<ChildSubmission>> getActivitySubmissions({
    required String activityId,
    String? teacherId,
    SubmissionStatus? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(submissionsCollection)
          .where('activityId', isEqualTo: activityId);

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final snapshot =
          await query.orderBy('completedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => ChildSubmission.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting activity submissions: $e');
      return [];
    }
  }

  /// Get child progress analytics
  Future<ChildProgressAnalytics?> getChildAnalytics({
    required String childId,
    required String teacherId,
  }) async {
    try {
      final doc = await _firestore
          .collection(analyticsCollection)
          .doc('${childId}_$teacherId')
          .get();

      if (!doc.exists) {
        // Generate analytics if they don't exist
        return await _generateChildAnalytics(childId, teacherId);
      }

      return ChildProgressAnalytics.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('❌ Error getting child analytics: $e');
      return null;
    }
  }

  /// Generate comprehensive analytics for a child
  Future<ChildProgressAnalytics> _generateChildAnalytics(
    String childId,
    String teacherId,
  ) async {
    try {
      // Get all completed submissions for this child
      final submissions = await getChildSubmissions(
        childId: childId,
        teacherId: teacherId,
        status: SubmissionStatus.completed,
      );

      if (submissions.isEmpty) {
        return ChildProgressAnalytics(
          childId: childId,
          teacherId: teacherId,
          activitiesByAgeGroup: {},
          activitiesBySubject: {},
          activitiesByDifficulty: {},
          totalActivitiesCompleted: 0,
          totalScoreEarned: 0,
          averageCompletionPercentage: 0.0,
          totalTimeSpent: Duration.zero,
          strengths: [],
          areasForImprovement: [],
          lastActivityDate: DateTime.now(),
          analyticsGeneratedAt: DateTime.now(),
        );
      }

      // Calculate analytics
      final activitiesByAgeGroup = <AgeGroup, int>{};
      final activitiesBySubject = <ActivitySubject, int>{};
      final activitiesByDifficulty = <Difficulty, int>{};
      int totalScoreEarned = 0;
      double totalCompletionPercentage = 0.0;
      Duration totalTimeSpent = Duration.zero;
      DateTime lastActivityDate = submissions.first.startedAt;

      final skillPerformance = <String, List<double>>{};

      for (final submission in submissions) {
        totalScoreEarned += submission.totalScore;
        totalCompletionPercentage += submission.completionPercentage;

        if (submission.timeSpent != null) {
          totalTimeSpent += submission.timeSpent!;
        }

        if (submission.startedAt.isAfter(lastActivityDate)) {
          lastActivityDate = submission.startedAt;
        }

        // Get activity details for categorization
        final activityDoc = await _firestore
            .collection('activities')
            .doc(submission.activityId)
            .get();

        if (activityDoc.exists) {
          final activityData = activityDoc.data()!;
          final ageGroup = AgeGroup.values.firstWhere(
            (e) => e.name == activityData['ageGroup'],
            orElse: () => AgeGroup.junior,
          );
          final subject = ActivitySubject.values.firstWhere(
            (e) => e.name == activityData['subject'],
            orElse: () => ActivitySubject.math,
          );
          final difficulty = Difficulty.values.firstWhere(
            (e) => e.name == activityData['difficulty'],
            orElse: () => Difficulty.easy,
          );

          activitiesByAgeGroup[ageGroup] =
              (activitiesByAgeGroup[ageGroup] ?? 0) + 1;
          activitiesBySubject[subject] =
              (activitiesBySubject[subject] ?? 0) + 1;
          activitiesByDifficulty[difficulty] =
              (activitiesByDifficulty[difficulty] ?? 0) + 1;

          // Track skill performance
          for (final question in submission.questionSubmissions) {
            // Extract skills from question metadata or activity
            final skills = question.metadata['skills'] as List<String>? ?? [];
            for (final skill in skills) {
              skillPerformance.putIfAbsent(skill, () => []);
              skillPerformance[skill]!.add(question.isCorrect ? 1.0 : 0.0);
            }
          }
        }
      }

      // Calculate strengths and areas for improvement
      final strengths = <String>[];
      final areasForImprovement = <String>[];

      for (final entry in skillPerformance.entries) {
        final skill = entry.key;
        final performances = entry.value;
        final averagePerformance =
            performances.reduce((a, b) => a + b) / performances.length;

        if (averagePerformance >= 0.8) {
          strengths.add(skill);
        } else if (averagePerformance < 0.6) {
          areasForImprovement.add(skill);
        }
      }

      final analytics = ChildProgressAnalytics(
        childId: childId,
        teacherId: teacherId,
        activitiesByAgeGroup: activitiesByAgeGroup,
        activitiesBySubject: activitiesBySubject,
        activitiesByDifficulty: activitiesByDifficulty,
        totalActivitiesCompleted: submissions.length,
        totalScoreEarned: totalScoreEarned,
        averageCompletionPercentage:
            totalCompletionPercentage / submissions.length,
        totalTimeSpent: totalTimeSpent,
        strengths: strengths,
        areasForImprovement: areasForImprovement,
        lastActivityDate: lastActivityDate,
        analyticsGeneratedAt: DateTime.now(),
      );

      // Save analytics to database
      await _firestore
          .collection(analyticsCollection)
          .doc('${childId}_$teacherId')
          .set(analytics.toJson());

      return analytics;
    } catch (e) {
      debugPrint('❌ Error generating child analytics: $e');
      rethrow;
    }
  }

  /// Update child analytics when a new submission is made
  Future<void> _updateChildAnalytics(
    String childId,
    String teacherId,
    ChildSubmission submission,
  ) async {
    try {
      // Invalidate existing analytics to trigger regeneration
      await _firestore
          .collection(analyticsCollection)
          .doc('${childId}_$teacherId')
          .delete();

      // Analytics will be regenerated on next request
      debugPrint('📊 Child analytics invalidated for regeneration');
    } catch (e) {
      debugPrint('❌ Error updating child analytics: $e');
    }
  }

  /// Filter submissions by activity properties
  Future<List<ChildSubmission>> _filterSubmissionsByActivity(
    List<ChildSubmission> submissions,
    AgeGroup? ageGroup,
    ActivitySubject? subject,
  ) async {
    final filteredSubmissions = <ChildSubmission>[];

    for (final submission in submissions) {
      try {
        final activityDoc = await _firestore
            .collection('activities')
            .doc(submission.activityId)
            .get();

        if (activityDoc.exists) {
          final activityData = activityDoc.data()!;
          final activityAgeGroup = AgeGroup.values.firstWhere(
            (e) => e.name == activityData['ageGroup'],
            orElse: () => AgeGroup.junior,
          );
          final activitySubject = ActivitySubject.values.firstWhere(
            (e) => e.name == activityData['subject'],
            orElse: () => ActivitySubject.math,
          );

          bool matchesFilter = true;
          if (ageGroup != null && activityAgeGroup != ageGroup) {
            matchesFilter = false;
          }
          if (subject != null && activitySubject != subject) {
            matchesFilter = false;
          }

          if (matchesFilter) {
            filteredSubmissions.add(submission);
          }
        }
      } catch (e) {
        debugPrint('Error filtering submission ${submission.id}: $e');
      }
    }

    return filteredSubmissions;
  }

  /// Get teacher's analytics for all their children
  Future<Map<String, ChildProgressAnalytics>> getTeacherAnalytics(
      String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection(analyticsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final analytics = <String, ChildProgressAnalytics>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final childId = data['childId'] as String;
        analytics[childId] = ChildProgressAnalytics.fromJson(data);
      }

      return analytics;
    } catch (e) {
      debugPrint('❌ Error getting teacher analytics: $e');
      return {};
    }
  }
}
