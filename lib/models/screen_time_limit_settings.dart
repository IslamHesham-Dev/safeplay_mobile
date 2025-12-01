import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenTimeLimitSettings {
  const ScreenTimeLimitSettings({
    required this.isEnabled,
    required this.dailyLimitMinutes,
    required this.usedMinutesToday,
    required this.isLocked,
    required this.lastResetDate,
    this.lockedAt,
  });

  final bool isEnabled;
  final int dailyLimitMinutes;
  final int usedMinutesToday;
  final bool isLocked;
  final DateTime? lockedAt;
  final DateTime? lastResetDate;

  factory ScreenTimeLimitSettings.initial({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    return ScreenTimeLimitSettings(
      isEnabled: false,
      dailyLimitMinutes: 120,
      usedMinutesToday: 0,
      isLocked: false,
      lockedAt: null,
      lastResetDate: today,
    );
  }

  ScreenTimeLimitSettings copyWith({
    bool? isEnabled,
    int? dailyLimitMinutes,
    int? usedMinutesToday,
    bool? isLocked,
    DateTime? lockedAt,
    DateTime? lastResetDate,
  }) {
    return ScreenTimeLimitSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      usedMinutesToday: usedMinutesToday ?? this.usedMinutesToday,
      isLocked: isLocked ?? this.isLocked,
      lockedAt: lockedAt ?? this.lockedAt,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  bool get hasLimit => isEnabled && dailyLimitMinutes > 0;

  bool get isLimitReached => hasLimit && usedMinutesToday >= dailyLimitMinutes;

  bool get shouldLock => hasLimit && isLocked;

  int get remainingMinutes {
    if (!hasLimit) return dailyLimitMinutes;
    return max(0, dailyLimitMinutes - usedMinutesToday);
  }

  ScreenTimeLimitSettings resetIfNeeded(DateTime now) {
    final today = _dateOnly(now);
    if (lastResetDate == null || !_isSameDay(lastResetDate!, today)) {
      return copyWith(
        usedMinutesToday: 0,
        isLocked: false,
        lockedAt: null,
        lastResetDate: today,
      );
    }
    return this;
  }

  factory ScreenTimeLimitSettings.fromMap(Map<String, dynamic> data) {
    final used = (data['usedMinutesToday'] as num?)?.toInt() ?? 0;
    final dailyLimit = (data['dailyLimitMinutes'] as num?)?.toInt() ?? 120;
    final lastReset = data['lastResetDate'];
    final lockedAtValue = data['lockedAt'];
    return ScreenTimeLimitSettings(
      isEnabled: data['isEnabled'] as bool? ?? false,
      dailyLimitMinutes: dailyLimit,
      usedMinutesToday: used,
      isLocked: data['isLocked'] as bool? ?? false,
      lockedAt: lockedAtValue is Timestamp
          ? lockedAtValue.toDate()
          : (lockedAtValue is DateTime ? lockedAtValue : null),
      lastResetDate: lastReset is Timestamp
          ? lastReset.toDate()
          : (lastReset is DateTime ? lastReset : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'dailyLimitMinutes': dailyLimitMinutes,
      'usedMinutesToday': usedMinutesToday,
      'isLocked': isLocked,
      'lockedAt': lockedAt != null ? Timestamp.fromDate(lockedAt!) : null,
      'lastResetDate':
          lastResetDate != null ? Timestamp.fromDate(lastResetDate!) : null,
    }..removeWhere((_, value) => value == null);
  }

  static DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
