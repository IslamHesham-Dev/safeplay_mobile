import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ScreenTimeSettings extends Equatable {
  final int? dailyMinutes;
  final int? weeklyMinutes;
  final List<String> allowedDays;
  final String? startHour;
  final String? endHour;

  const ScreenTimeSettings({
    this.dailyMinutes,
    this.weeklyMinutes,
    required this.allowedDays,
    this.startHour,
    this.endHour,
  });

  factory ScreenTimeSettings.fromJson(Map<String, dynamic> json) {
    final allowedHours = json['allowedHours'] as Map<String, dynamic>?;
    return ScreenTimeSettings(
      dailyMinutes: (json['dailyMinutes'] as num?)?.toInt(),
      weeklyMinutes: (json['weeklyMinutes'] as num?)?.toInt(),
      allowedDays: (json['allowedDays'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      startHour: allowedHours != null ? allowedHours['start'] as String? : null,
      endHour: allowedHours != null ? allowedHours['end'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyMinutes': dailyMinutes,
      'weeklyMinutes': weeklyMinutes,
      'allowedDays': allowedDays,
      'allowedHours': startHour != null && endHour != null
          ? {'start': startHour, 'end': endHour}
          : null,
    }..removeWhere((_, value) => value == null);
  }

  @override
  List<Object?> get props =>
      [dailyMinutes, weeklyMinutes, allowedDays, startHour, endHour];
}

class ContentSettings extends Equatable {
  final List<String> allowedSubjects;
  final String maxDifficulty;
  final bool requireApproval;

  const ContentSettings({
    required this.allowedSubjects,
    required this.maxDifficulty,
    required this.requireApproval,
  });

  factory ContentSettings.fromJson(Map<String, dynamic> json) {
    return ContentSettings(
      allowedSubjects: (json['allowedSubjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      maxDifficulty: json['maxDifficulty'] as String? ?? 'medium',
      requireApproval: json['requireApproval'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowedSubjects': allowedSubjects,
      'maxDifficulty': maxDifficulty,
      'requireApproval': requireApproval,
    };
  }

  @override
  List<Object?> get props => [allowedSubjects, maxDifficulty, requireApproval];
}

class NotificationPreferences extends Equatable {
  final bool onCompletion;
  final bool onMilestone;
  final bool onStreak;
  final bool dailySummary;
  final bool weeklySummary;

  const NotificationPreferences({
    required this.onCompletion,
    required this.onMilestone,
    required this.onStreak,
    required this.dailySummary,
    required this.weeklySummary,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      onCompletion: json['onCompletion'] as bool? ?? true,
      onMilestone: json['onMilestone'] as bool? ?? true,
      onStreak: json['onStreak'] as bool? ?? true,
      dailySummary: json['dailySummary'] as bool? ?? false,
      weeklySummary: json['weeklySummary'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onCompletion': onCompletion,
      'onMilestone': onMilestone,
      'onStreak': onStreak,
      'dailySummary': dailySummary,
      'weeklySummary': weeklySummary,
    };
  }

  @override
  List<Object?> get props =>
      [onCompletion, onMilestone, onStreak, dailySummary, weeklySummary];
}

class ParentalSettings extends Equatable {
  final String id;
  final String parentId;
  final String childId;
  final ScreenTimeSettings screenTime;
  final ContentSettings content;
  final NotificationPreferences notifications;
  final DateTime updatedAt;

  const ParentalSettings({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.screenTime,
    required this.content,
    required this.notifications,
    required this.updatedAt,
  });

  factory ParentalSettings.fromJson(Map<String, dynamic> json) {
    DateTime parse(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return ParentalSettings(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      childId: json['childId'] as String,
      screenTime: ScreenTimeSettings.fromJson(
          json['screenTime'] as Map<String, dynamic>),
      content:
          ContentSettings.fromJson(json['content'] as Map<String, dynamic>),
      notifications: NotificationPreferences.fromJson(
          json['notifications'] as Map<String, dynamic>),
      updatedAt: parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'childId': childId,
      'screenTime': screenTime.toJson(),
      'content': content.toJson(),
      'notifications': notifications.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [id, parentId, childId, screenTime, content, notifications, updatedAt];
}
