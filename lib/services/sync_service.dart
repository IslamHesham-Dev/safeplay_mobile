import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'activity_service.dart';
import 'offline_storage_service.dart';
import '../models/user_type.dart';

/// Background sync service for offline data
class SyncService {
  final OfflineStorageService _offlineStorage;
  final ActivityService _activityService;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  SyncService(this._offlineStorage, this._activityService);

  /// Initialize sync service
  Future<void> initialize() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        unawaited(syncData());
      }
    });

    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(syncData()),
    );

    await syncData();
  }

  /// Sync offline data to Firebase
  Future<void> syncData() async {
    if (_isSyncing) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('No internet connection, skipping sync');
      return;
    }

    _isSyncing = true;

    try {
      final pendingItems = await _offlineStorage.getPendingSyncItems();

      for (final item in pendingItems) {
        final mapped = item.cast<String, dynamic>();
        final rawId = mapped['id'];
        final itemId =
            rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

        try {
          await _syncItem(mapped);
          await _offlineStorage.markSyncItemCompleted(itemId);
        } catch (error) {
          debugPrint('Sync item failed: $error');
          await _offlineStorage.markSyncItemFailed(
            itemId,
            error.toString(),
          );
        }
      }

      _lastSyncTime = DateTime.now();
      debugPrint('Sync completed: ${pendingItems.length} items synced');
    } catch (error) {
      debugPrint('Sync error: $error');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncItem(Map<String, dynamic> item) async {
    final entityType = item['entityType'] as String? ?? '';
    final data = item['data'] as Map<String, dynamic>? ?? const {};

    switch (entityType) {
      case 'activity_progress':
        await _activityService.applyOfflineProgress(data);
        break;
      default:
        debugPrint('Unknown entity type queued for sync: $entityType');
    }
  }

  /// Download activities for offline use
  Future<void> downloadActivitiesForOffline(String ageGroup) async {
    try {
      final group = AgeGroup.values.firstWhere(
        (value) => value.name == ageGroup,
        orElse: () => AgeGroup.junior,
      );

      final activities = await _activityService.getActivitiesForAgeGroup(group);
      await _offlineStorage.upsertActivities(activities);
      debugPrint('Downloaded ${activities.length} activities for offline use');
    } catch (error) {
      debugPrint('Error downloading activities: $error');
    }
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    final pendingItems = await _offlineStorage.getPendingSyncItems();
    final connectivityResult = await _connectivity.checkConnectivity();

    return SyncStatus(
      pendingItemsCount: pendingItems.length,
      isOnline: connectivityResult != ConnectivityResult.none,
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Force sync
  Future<void> forceSync() async {
    await syncData();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}

/// Sync status model
class SyncStatus {
  final int pendingItemsCount;
  final bool isOnline;
  final bool isSyncing;
  final DateTime lastSyncTime;

  SyncStatus({
    required this.pendingItemsCount,
    required this.isOnline,
    required this.isSyncing,
    required this.lastSyncTime,
  });

  bool get hasUnsyncedData => pendingItemsCount > 0;
  bool get canSync => isOnline && !isSyncing;
}
