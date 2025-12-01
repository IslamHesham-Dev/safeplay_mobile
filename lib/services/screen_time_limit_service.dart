import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/screen_time_limit_settings.dart';

class ScreenTimeLimitService {
  ScreenTimeLimitService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'screenTimeLimits';

  CollectionReference<Map<String, dynamic>> get _collectionRef =>
      _firestore.collection(_collection);

  Future<ScreenTimeLimitSettings> fetchSettings(String childId) async {
    if (childId.isEmpty) {
      return ScreenTimeLimitSettings.initial();
    }
    final docRef = _collectionRef.doc(childId);
    final snapshot = await docRef.get();
    ScreenTimeLimitSettings settings;
    if (!snapshot.exists || snapshot.data() == null) {
      settings = ScreenTimeLimitSettings.initial();
      await docRef.set(settings.toMap(), SetOptions(merge: true));
    } else {
      settings = ScreenTimeLimitSettings.fromMap(snapshot.data()!);
    }
    final normalized = settings.resetIfNeeded(DateTime.now());
    if (normalized != settings) {
      await docRef.set(normalized.toMap(), SetOptions(merge: true));
      return normalized;
    }
    return settings;
  }

  Future<ScreenTimeLimitSettings> updateLimit(
    String childId, {
    required bool isEnabled,
    required int dailyLimitMinutes,
  }) {
    return _runTransaction(childId, (settings) {
      var updated = settings.copyWith(
        isEnabled: isEnabled && dailyLimitMinutes > 0,
        dailyLimitMinutes: dailyLimitMinutes,
      );
      if (!updated.isEnabled) {
        updated = updated.copyWith(
          usedMinutesToday: 0,
          isLocked: false,
          lockedAt: null,
        );
      }
      return updated;
    });
  }

  Future<ScreenTimeLimitSettings> unlock(String childId) {
    return _runTransaction(childId, (settings) {
      return settings.copyWith(
        isLocked: false,
        lockedAt: null,
        usedMinutesToday: 0,
      );
    });
  }

  Future<ScreenTimeLimitSettings> recordUsage(
    String childId,
    int minutes,
  ) {
    if (minutes <= 0) {
      return fetchSettings(childId);
    }
    return _runTransaction(childId, (settings) {
      if (!settings.hasLimit) {
        return settings;
      }
      final newUsed = settings.usedMinutesToday + minutes;
      var updated = settings.copyWith(
        usedMinutesToday: newUsed,
      );
      if (updated.isLimitReached) {
        updated = updated.copyWith(
          isLocked: true,
          lockedAt: DateTime.now(),
        );
      }
      return updated;
    });
  }

  Future<ScreenTimeLimitSettings> _runTransaction(
    String childId,
    ScreenTimeLimitSettings Function(ScreenTimeLimitSettings current) update,
  ) {
    if (childId.isEmpty) {
      return Future.value(ScreenTimeLimitSettings.initial());
    }
    final docRef = _collectionRef.doc(childId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      ScreenTimeLimitSettings settings;
      if (!snapshot.exists || snapshot.data() == null) {
        settings = ScreenTimeLimitSettings.initial();
      } else {
        settings = ScreenTimeLimitSettings.fromMap(snapshot.data()!);
      }
      settings = settings.resetIfNeeded(DateTime.now());
      final updated = update(settings);
      transaction.set(docRef, updated.toMap(), SetOptions(merge: true));
      return updated;
    });
  }
}
