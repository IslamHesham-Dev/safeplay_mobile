import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity.dart';
import '../models/user_type.dart';
import 'offline_storage_service.dart';

/// Activity service for managing activities and learner progress.
class ActivityService {
  ActivityService({OfflineStorageService? offlineStorage})
      : _offlineStorage = offlineStorage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OfflineStorageService? _offlineStorage;

  // Collections
  static const String activitiesCollection = 'activities';
  static const String progressCollection = 'activityProgress';

  Future<List<Activity>> getActivitiesForAgeGroup(AgeGroup ageGroup) async {
    try {
      final collection = _firestore.collection(activitiesCollection);
      final baseQuery = collection
          .where('ageGroup', isEqualTo: ageGroup.name)
          .where('published', isEqualTo: true);

      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await baseQuery.orderBy('updatedAt', descending: true).get();
      } on FirebaseException catch (error) {
        if (error.code == 'failed-precondition') {
          snapshot =
              await baseQuery.orderBy('createdAt', descending: true).get();
        } else {
          rethrow;
        }
      }

      final activities = snapshot.docs
          .map((doc) => Activity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      await _offlineStorage?.upsertActivities(activities);
      return activities;
    } catch (e) {
      debugPrint('Error getting activities: $e');
      if (_offlineStorage != null) {
        final cached = await _offlineStorage!.getActivitiesByAgeGroup(ageGroup);
        if (cached.isNotEmpty) {
          return cached;
        }
      }
      return [];
    }
  }

  Future<List<Activity>> getActivitiesBySubject(
    AgeGroup ageGroup,
    ActivitySubject subject,
  ) async {
    try {
      final collection = _firestore.collection(activitiesCollection);
      final baseQuery = collection
          .where('ageGroup', isEqualTo: ageGroup.name)
          .where('subject', isEqualTo: subject.name)
          .where('published', isEqualTo: true);

      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await baseQuery.orderBy('updatedAt', descending: true).get();
      } on FirebaseException catch (error) {
        if (error.code == 'failed-precondition') {
          snapshot =
              await baseQuery.orderBy('createdAt', descending: true).get();
        } else {
          rethrow;
        }
      }

      final activities = snapshot.docs
          .map((doc) => Activity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      await _offlineStorage?.upsertActivities(activities);
      return activities;
    } catch (e) {
      debugPrint('Error getting activities by subject: $e');
      if (_offlineStorage != null) {
        final cached = await _offlineStorage!.getActivitiesByAgeGroup(ageGroup);
        return cached
            .where((activity) => activity.subject == subject)
            .toList(growable: false);
      }
      return [];
    }
  }

  Future<Activity?> getActivity(String activityId) async {
    try {
      final doc = await _firestore
          .collection(activitiesCollection)
          .doc(activityId)
          .get();
      if (!doc.exists) {
        return await _offlineStorage?.getActivity(activityId);
      }
      final activity = Activity.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
      await _offlineStorage?.upsertActivity(activity);
      return activity;
    } catch (e) {
      debugPrint('Error getting activity: $e');
      return await _offlineStorage?.getActivity(activityId);
    }
  }

  Future<ActivityProgress> startActivity(
      String childId, String activityId) async {
    final activity = await getActivity(activityId);
    if (activity == null) {
      throw Exception('Activity not found');
    }

    final totalPoints = _calculateTotalPoints(activity);
    final docId = '${childId}_$activityId';
    final docRef = _firestore.collection(progressCollection).doc(docId);
    final now = DateTime.now();

    final progress = ActivityProgress(
      id: docId,
      childId: childId,
      activityId: activityId,
      status: ActivityProgressStatus.inProgress,
      progressPercent: 0,
      currentQuestionIndex: 0,
      answers: const {},
      score: 0,
      totalPoints: totalPoints,
      pointsEarned: 0,
      timeSpentSeconds: 0,
      attemptNumber: 1,
      bestScore: 0,
      startedAt: now,
      updatedAt: now,
      completedAt: null,
      isCompleted: false,
    );

    try {
      await docRef.set(
        progress.toFirestore(serverTimestampsForUpdatedAt: true),
      );
      await _offlineStorage?.upsertProgress(progress, synced: true);
    } on FirebaseException catch (error) {
      debugPrint('Error starting activity online: $error');
      await _offlineStorage?.upsertProgress(progress, synced: false);
      await _queueProgressSync(progress, operation: 'upsert');
    } catch (error) {
      debugPrint('Unexpected error starting activity: $error');
      await _offlineStorage?.upsertProgress(progress, synced: false);
      await _queueProgressSync(progress, operation: 'upsert');
    }

    return progress;
  }

  Future<ActivityProgress?> submitAnswer({
    required String progressId,
    required String questionId,
    required dynamic answer,
  }) async {
    ActivityProgress? progress;
    final docRef = _firestore.collection(progressCollection).doc(progressId);

    try {
      ActivityProgress? remoteProgress;
      try {
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          remoteProgress = ActivityProgress.fromJson({
            'id': snapshot.id,
            ...snapshot.data()!,
          });
        }
      } catch (error) {
        debugPrint('Unable to load remote progress: $error');
      }

      progress =
          remoteProgress ?? await _offlineStorage?.getProgressById(progressId);
      if (progress == null) {
        return null;
      }

      final activity = await getActivity(progress.activityId);
      if (activity == null) {
        return progress;
      }

      final question = activity.questions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => throw StateError('Question not found'),
      );

      final isCorrect = _checkAnswer(question, answer);
      final updatedAnswers = Map<String, dynamic>.from(progress.answers);
      updatedAnswers[questionId] = {
        'answer': answer,
        'isCorrect': isCorrect,
        'pointsEarned': isCorrect ? question.points : 0,
        'answeredAt': DateTime.now().toIso8601String(),
      };

      final totalPoints = progress.totalPoints != 0
          ? progress.totalPoints
          : _calculateTotalPoints(activity);

      final earnedPoints = updatedAnswers.values.fold<int>(
        0,
        (acc, entry) =>
            acc +
            (entry is Map<String, dynamic>
                ? (entry['pointsEarned'] as int? ?? 0)
                : 0),
      );

      final progressPercent = totalPoints > 0
          ? (earnedPoints / totalPoints) * 100
          : progress.progressPercent;

      final updated = progress.copyWith(
        status: ActivityProgressStatus.inProgress,
        progressPercent: progressPercent,
        currentQuestionIndex: (progress.currentQuestionIndex + 1)
            .clamp(0, activity.questions.length - 1),
        answers: updatedAnswers,
        score: earnedPoints,
        pointsEarned: earnedPoints,
        updatedAt: DateTime.now(),
      );

      try {
        final payload = updated.toFirestore(serverTimestampsForUpdatedAt: true);
        await docRef.set(payload, SetOptions(merge: true));
        await _offlineStorage?.upsertProgress(updated, synced: true);
      } on FirebaseException catch (error) {
        debugPrint('Error submitting answer online: $error');
        await _offlineStorage?.upsertProgress(updated, synced: false);
        await _queueProgressSync(updated, operation: 'update');
      } catch (error) {
        debugPrint('Unexpected error submitting answer: $error');
        await _offlineStorage?.upsertProgress(updated, synced: false);
        await _queueProgressSync(updated, operation: 'update');
      }

      return updated;
    } catch (error) {
      debugPrint('Error submitting answer: $error');
      return progress;
    }
  }

  Future<ActivityProgress?> completeActivity(
    String progressId, {
    int? pointsEarned,
  }) async {
    ActivityProgress? progress;
    final docRef = _firestore.collection(progressCollection).doc(progressId);

    try {
      try {
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          progress = ActivityProgress.fromJson({
            'id': snapshot.id,
            ...snapshot.data()!,
          });
        }
      } catch (error) {
        debugPrint('Unable to load remote progress for completion: $error');
      }

      progress ??= await _offlineStorage?.getProgressById(progressId);
      if (progress == null) {
        return null;
      }

      final totalPoints = progress.totalPoints;
      final earnedPoints = pointsEarned ?? progress.pointsEarned;
      final now = DateTime.now();

      final updated = progress.copyWith(
        status: ActivityProgressStatus.completed,
        progressPercent: 100,
        pointsEarned: earnedPoints,
        score: totalPoints != 0 ? totalPoints : earnedPoints,
        completedAt: now,
        updatedAt: now,
        isCompleted: true,
      );

      try {
        final payload = updated.toFirestore(serverTimestampsForUpdatedAt: true);
        await docRef.set(payload, SetOptions(merge: true));
        await _offlineStorage?.upsertProgress(updated, synced: true);
      } on FirebaseException catch (error) {
        debugPrint('Error completing activity online: $error');
        await _offlineStorage?.upsertProgress(updated, synced: false);
        await _queueProgressSync(updated, operation: 'complete');
      } catch (error) {
        debugPrint('Unexpected error completing activity: $error');
        await _offlineStorage?.upsertProgress(updated, synced: false);
        await _queueProgressSync(updated, operation: 'complete');
      }

      return updated;
    } catch (error) {
      debugPrint('Error completing activity: $error');
      return progress;
    }
  }

  Future<ActivityProgress?> getActivityProgress(
      String childId, String activityId) async {
    try {
      final snapshot = await _firestore
          .collection(progressCollection)
          .where('childId', isEqualTo: childId)
          .where('activityId', isEqualTo: activityId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return await _offlineStorage?.getProgressById('${childId}_$activityId');
      }

      final doc = snapshot.docs.first;
      final progress = ActivityProgress.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
      await _offlineStorage?.upsertProgress(progress, synced: true);
      return progress;
    } catch (e) {
      debugPrint('Error getting activity progress: $e');
      return await _offlineStorage?.getProgressById('${childId}_$activityId');
    }
  }

  Future<List<ActivityProgress>> getChildProgress(String childId) async {
    try {
      final snapshot = await _firestore
          .collection(progressCollection)
          .where('childId', isEqualTo: childId)
          .orderBy('updatedAt', descending: true)
          .get();

      final progressList = snapshot.docs
          .map((doc) => ActivityProgress.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      if (progressList.isNotEmpty) {
        for (final progress in progressList) {
          await _offlineStorage?.upsertProgress(progress, synced: true);
        }
      }

      return progressList;
    } catch (e) {
      debugPrint('Error getting child progress: $e');
      if (_offlineStorage != null) {
        return _offlineStorage!.getProgressForChild(childId);
      }
      return [];
    }
  }

  bool _checkAnswer(ActivityQuestion question, dynamic answer) {
    final correct = _normalizeValue(question.correctAnswer);
    final provided = _normalizeAnswer(question, answer);

    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        if (correct is List) {
          if (provided is List) {
            return _listEquals(correct, provided);
          }
          return correct.contains(provided);
        }
        return provided == correct;
      case QuestionType.textInput:
        if (provided is String && correct is String) {
          return provided == correct;
        }
        return provided == correct;
      case QuestionType.dragDrop:
      case QuestionType.matching:
      case QuestionType.sequencing:
        if (correct is List && provided is List) {
          return _listEquals(correct, provided);
        }
        return false;
    }
  }

  Future<void> applyOfflineProgress(Map<String, dynamic> payload) async {
    final progressJson = payload['progress'];
    if (progressJson is! Map<String, dynamic>) {
      return;
    }
    final progress = ActivityProgress.fromJson(progressJson);
    final docRef = _firestore.collection(progressCollection).doc(progress.id);

    ActivityProgress? mergedResult;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      Map<String, dynamic> remoteData = {};
      DateTime? remoteUpdatedAt;
      if (snapshot.exists) {
        remoteData = snapshot.data() ?? {};
        remoteUpdatedAt = _extractDate(
            remoteData['clientUpdatedAt'] ?? remoteData['updatedAt']);
      }

      if (remoteUpdatedAt != null &&
          !progress.updatedAt.isAfter(remoteUpdatedAt)) {
        mergedResult = ActivityProgress.fromJson({
          'id': snapshot.id,
          ...remoteData,
        });
        return;
      }

      final mergedAnswers = <String, dynamic>{};
      if (remoteData['answers'] is Map) {
        Map<String, dynamic>.from(remoteData['answers'] as Map)
            .forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final normalized = Map<String, dynamic>.from(value);
            final answeredAt = _extractDate(
              normalized['clientAnsweredAt'] ?? normalized['answeredAt'],
            );
            if (answeredAt != null) {
              normalized['answeredAt'] = answeredAt.toIso8601String();
            }
            normalized.remove('clientAnsweredAt');
            mergedAnswers[key] = normalized;
          } else {
            mergedAnswers[key] = value;
          }
        });
      }

      progress.answers.forEach((questionId, value) {
        if (value is Map<String, dynamic>) {
          final localAnswer = Map<String, dynamic>.from(value);
          final localAnsweredAt =
              _extractDate(localAnswer['answeredAt']) ?? progress.updatedAt;
          final existing = mergedAnswers[questionId];
          DateTime? existingAnsweredAt;
          if (existing is Map<String, dynamic>) {
            existingAnsweredAt = _extractDate(existing['answeredAt']);
          }
          if (existingAnsweredAt == null ||
              localAnsweredAt.isAfter(existingAnsweredAt)) {
            mergedAnswers[questionId] = {
              ...localAnswer,
              'answeredAt': localAnsweredAt.toIso8601String(),
            };
          }
        } else {
          mergedAnswers[questionId] = value;
        }
      });

      int recalculatedPoints = 0;
      mergedAnswers.forEach((_, answerValue) {
        if (answerValue is Map<String, dynamic>) {
          recalculatedPoints += answerValue['pointsEarned'] as int? ?? 0;
        }
      });

      final mergedProgress = progress.copyWith(
        answers: mergedAnswers,
        score: recalculatedPoints,
        pointsEarned: recalculatedPoints,
        progressPercent: progress.totalPoints > 0
            ? (recalculatedPoints / progress.totalPoints) * 100
            : progress.progressPercent,
      );

      final payloadMap =
          mergedProgress.toFirestore(serverTimestampsForUpdatedAt: true);
      transaction.set(docRef, payloadMap, SetOptions(merge: true));
      mergedResult = mergedProgress;
    });

    if (mergedResult != null) {
      await _offlineStorage?.upsertProgress(mergedResult!, synced: true);
    }
  }

  Future<void> _queueProgressSync(
    ActivityProgress progress, {
    required String operation,
  }) async {
    if (_offlineStorage == null) return;

    await _offlineStorage!.clearQueuedItems(
      entityType: 'activity_progress',
      entityId: progress.id,
    );

    await _offlineStorage!.queueSyncItem(
      entityType: 'activity_progress',
      entityId: progress.id,
      operation: operation,
      data: {
        'progress': progress.toJson(),
        'childId': progress.childId,
        'activityId': progress.activityId,
      },
    );
  }

  DateTime? _extractDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  dynamic _normalizeValue(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map(_normalizeValue).toList();
    }
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    if (value is num) {
      return value;
    }
    return value.toString().trim().toLowerCase();
  }

  dynamic _normalizeAnswer(ActivityQuestion question, dynamic answer) {
    if (answer == null) return null;
    if (answer is List) {
      return answer.map((item) => _normalizeAnswer(question, item)).toList();
    }
    if (answer is int && question.options.isNotEmpty) {
      final safeIndex = answer < 0
          ? 0
          : (answer >= question.options.length
              ? question.options.length - 1
              : answer);
      return question.options[safeIndex].trim().toLowerCase();
    }
    if (answer is bool) {
      return answer ? 'true' : 'false';
    }
    if (answer is num) {
      return answer;
    }
    return answer.toString().trim().toLowerCase();
  }

  bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left is List && right is List) {
        if (!_listEquals(left, right)) return false;
      } else if (left != right) {
        return false;
      }
    }
    return true;
  }

  int _calculateTotalPoints(Activity activity) {
    return activity.questions
        .fold<int>(0, (total, question) => total + question.points);
  }
}

