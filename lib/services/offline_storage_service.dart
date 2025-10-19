import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/user_type.dart';

/// Simplified offline storage service using SharedPreferences for basic caching.
class OfflineStorageService {
  static const _keyActivities = 'safeplay_activities';
  static const _keyProgress = 'safeplay_progress';
  static const _syncStatusSynced = 'synced';
  static const _syncStatusPending = 'pending';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------------------------------------------------------------------------
  // Activity caching
  // ---------------------------------------------------------------------------

  Future<void> upsertActivities(List<Activity> activities) async {
    if (activities.isEmpty) return;
    final prefs = await this.prefs;
    final timestamp = DateTime.now().toIso8601String();
    
    // Get existing activities
    final existingJson = prefs.getString(_keyActivities) ?? '{}';
    final existing = jsonDecode(existingJson) as Map<String, dynamic>;
    
    // Update with new activities
    for (final activity in activities) {
      existing[activity.id] = {
        'activity': activity.toJson(),
        'updatedAt': timestamp,
      };
    }
    
    await prefs.setString(_keyActivities, jsonEncode(existing));
  }

  Future<void> upsertActivity(Activity activity) async {
    await upsertActivities([activity]);
  }

  Future<List<Activity>> getActivitiesByAgeGroup(AgeGroup ageGroup) async {
    final prefs = await this.prefs;
    final activitiesJson = prefs.getString(_keyActivities) ?? '{}';
    final activities = jsonDecode(activitiesJson) as Map<String, dynamic>;
    
    final result = <Activity>[];
    for (final entry in activities.values) {
      try {
        final data = entry as Map<String, dynamic>;
        final activityData = data['activity'] as Map<String, dynamic>;
        final activity = Activity.fromJson(activityData);
        if (activity.ageGroup == ageGroup) {
          result.add(activity);
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
    
    return result;
  }

  Future<Activity?> getActivity(String activityId) async {
    final prefs = await this.prefs;
    final activitiesJson = prefs.getString(_keyActivities) ?? '{}';
    final activities = jsonDecode(activitiesJson) as Map<String, dynamic>;
    
    final entry = activities[activityId];
    if (entry == null) return null;
    
    try {
      final data = entry as Map<String, dynamic>;
      final activityData = data['activity'] as Map<String, dynamic>;
      return Activity.fromJson(activityData);
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Progress caching
  // ---------------------------------------------------------------------------

  Future<void> upsertProgress(
    ActivityProgress progress, {
    required bool synced,
  }) async {
    final prefs = await this.prefs;
    final progressJson = prefs.getString(_keyProgress) ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
    
    progressMap[progress.id] = {
      'progress': progress.toJson(),
      'syncStatus': synced ? _syncStatusSynced : _syncStatusPending,
      'lastSyncedAt': synced ? DateTime.now().toIso8601String() : null,
    };
    
    await prefs.setString(_keyProgress, jsonEncode(progressMap));
  }

  Future<List<ActivityProgress>> getProgressForChild(String childId) async {
    final prefs = await this.prefs;
    final progressJson = prefs.getString(_keyProgress) ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
    
    final result = <ActivityProgress>[];
    for (final entry in progressMap.values) {
      try {
        final data = entry as Map<String, dynamic>;
        final progressData = data['progress'] as Map<String, dynamic>;
        final progress = ActivityProgress.fromJson(progressData);
        if (progress.childId == childId) {
          result.add(progress);
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
    
    return result;
  }

  Future<ActivityProgress?> getProgressById(String progressId) async {
    final prefs = await this.prefs;
    final progressJson = prefs.getString(_keyProgress) ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
    
    final entry = progressMap[progressId];
    if (entry == null) return null;
    
    try {
      final data = entry as Map<String, dynamic>;
      final progressData = data['progress'] as Map<String, dynamic>;
      return ActivityProgress.fromJson(progressData);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProgress(String progressId) async {
    final prefs = await this.prefs;
    final progressJson = prefs.getString(_keyProgress) ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
    
    progressMap.remove(progressId);
    await prefs.setString(_keyProgress, jsonEncode(progressMap));
  }

  // ---------------------------------------------------------------------------
  // Simplified sync queue (in-memory only)
  // ---------------------------------------------------------------------------

  final List<Map<String, dynamic>> _syncQueue = [];

  Future<void> queueSyncItem({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    _syncQueue.add({
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
      'attempts': 0,
      'error': null,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems({int limit = 50}) async {
    return _syncQueue.take(limit).toList();
  }

  Future<void> markSyncItemCompleted(int id) async {
    if (id < _syncQueue.length) {
      _syncQueue.removeAt(id);
    }
  }

  Future<void> markSyncItemFailed(int id, String error) async {
    if (id < _syncQueue.length) {
      _syncQueue[id]['attempts'] = (_syncQueue[id]['attempts'] ?? 0) + 1;
      _syncQueue[id]['lastAttempt'] = DateTime.now().toIso8601String();
      _syncQueue[id]['error'] = error;
    }
  }

  Future<void> clearQueuedItems({
    required String entityType,
    required String entityId,
  }) async {
    _syncQueue.removeWhere((item) =>
        item['entityType'] == entityType && item['entityId'] == entityId);
  }

  Future<void> clearCache() async {
    final prefs = await this.prefs;
    await prefs.remove(_keyActivities);
    await prefs.remove(_keyProgress);
    _syncQueue.clear();
  }

  Future<int> getCacheSize() async {
    final prefs = await this.prefs;
    final activitiesJson = prefs.getString(_keyActivities) ?? '{}';
    final progressJson = prefs.getString(_keyProgress) ?? '{}';
    
    final activities = jsonDecode(activitiesJson) as Map<String, dynamic>;
    final progress = jsonDecode(progressJson) as Map<String, dynamic>;
    
    return activities.length + progress.length + _syncQueue.length;
  }

  Future<void> close() async {
    // No-op for SharedPreferences
  }
}