import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/user_profile.dart';
import '../models/user_type.dart';
import '../services/activity_service.dart';

/// Activity state management that bridges activity catalog and progress data.
class ActivityProvider extends ChangeNotifier {
  ActivityProvider(this._activityService);

  final ActivityService _activityService;

  List<Activity> _activities = [];
  final Map<String, ActivityProgress> _progressByActivity = {};
  Activity? _currentActivity;
  ActivityProgress? _currentProgress;
  bool _isLoading = false;
  String? _error;

  List<Activity> get activities => _activities;
  Map<String, ActivityProgress> get progressByActivity =>
      Map.unmodifiable(_progressByActivity);
  Activity? get currentActivity => _currentActivity;
  ActivityProgress? get currentProgress => _currentProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load activities for a given age group. Optionally hydrate with a child's progress.
  Future<void> loadActivities(
    AgeGroup ageGroup, {
    String? childId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _activities = await _activityService.getActivitiesForAgeGroup(ageGroup);

      if (childId != null) {
        final progressList = await _activityService.getChildProgress(childId);
        _progressByActivity
          ..clear()
          ..addEntries(
            progressList
                .map((progress) => MapEntry(progress.activityId, progress)),
          );
      } else {
        _progressByActivity.clear();
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Convenience helper to load activities and progress for a specific child.
  Future<void> loadActivitiesForChild(ChildProfile child) async {
    if (child.ageGroup != null) {
      await loadActivities(child.ageGroup!, childId: child.id);
    }
  }

  /// Load activities filtered by subject (used by exploration screens).
  Future<void> loadActivitiesBySubject(
    AgeGroup ageGroup,
    ActivitySubject subject, {
    String? childId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _activities =
          await _activityService.getActivitiesBySubject(ageGroup, subject);

      if (childId != null) {
        final progressList = await _activityService.getChildProgress(childId);
        _progressByActivity
          ..clear()
          ..addEntries(
            progressList
                .map((progress) => MapEntry(progress.activityId, progress)),
          );
      } else {
        _progressByActivity.clear();
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load a specific activity, and optionally the child's progress for it.
  Future<void> loadActivity(String activityId, {String? childId}) async {
    _setLoading(true);
    _clearError();

    try {
      _currentActivity = await _activityService.getActivity(activityId);

      if (childId != null) {
        final progress =
            await _activityService.getActivityProgress(childId, activityId);
        if (progress != null) {
          _currentProgress = progress;
          _progressByActivity[activityId] = progress;
        }
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Begin an activity session for the supplied child.
  Future<ActivityProgress?> startActivity(
      String childId, String activityId) async {
    _setLoading(true);
    _clearError();

    try {
      final progress =
          await _activityService.startActivity(childId, activityId);
      _currentProgress = progress;
      _progressByActivity[activityId] = progress;
      notifyListeners();
      return progress;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Submit an answer for the current activity. Returns whether the answer was correct.
  Future<bool> submitAnswer(String questionId, dynamic answer) async {
    if (_currentProgress == null) return false;

    try {
      _clearError();
      final updated = await _activityService.submitAnswer(
        progressId: _currentProgress!.id,
        questionId: questionId,
        answer: answer,
      );

      if (updated != null) {
        _currentProgress = updated;
        _progressByActivity[updated.activityId] = updated;
        notifyListeners();

        final answerEntry = updated.answers[questionId];
        if (answerEntry is Map && answerEntry['isCorrect'] is bool) {
          return answerEntry['isCorrect'] as bool;
        }
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Mark the activity complete and refresh local state.
  Future<void> completeActivity({int? pointsEarned}) async {
    final progress = _currentProgress;
    if (progress == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updated = await _activityService.completeActivity(progress.id,
          pointsEarned: pointsEarned);
      if (updated != null) {
        _currentProgress = updated;
        _progressByActivity[updated.activityId] = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Retrieve progress list for dashboards.
  Future<List<ActivityProgress>> getChildProgress(String childId) async {
    _setLoading(true);
    _clearError();

    try {
      final progress = await _activityService.getChildProgress(childId);
      return progress;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all cached activities and progress.
  void clearActivities() {
    _activities = [];
    _progressByActivity.clear();
    _currentActivity = null;
    _currentProgress = null;
    notifyListeners();
  }

  /// Clear current selections.
  void clearCurrentActivity() {
    _currentActivity = null;
    _currentProgress = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
