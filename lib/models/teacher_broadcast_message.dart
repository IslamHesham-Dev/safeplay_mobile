import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import 'user_type.dart';

DateTime _parseTimestamp(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

Color _colorFromData(dynamic value, AgeGroup ageGroup) {
  if (value is int) {
    return Color(value);
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return Color(parsed);
    }
  }
  return ageGroup == AgeGroup.junior
      ? SafePlayColors.juniorPurple
      : SafePlayColors.brightIndigo;
}

/// Broadcast message sent by a teacher to Junior/Bright students.
class TeacherBroadcastMessage {
  final String id;
  final String teacherId;
  final String teacherName;
  final String? teacherAvatar;
  final AgeGroup audience;
  final String title;
  final String message;
  final String emoji;
  final String category;
  final Color color;
  final String? quickMessageId;
  final String? gameId;
  final String? gameName;
  final String? gameRoute;
  final String? gameLocation;
  final String? ctaLabel;
  final DateTime createdAt;

  const TeacherBroadcastMessage({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.audience,
    required this.title,
    required this.message,
    required this.emoji,
    required this.category,
    required this.color,
    required this.createdAt,
    this.teacherAvatar,
    this.quickMessageId,
    this.gameId,
    this.gameName,
    this.gameRoute,
    this.gameLocation,
    this.ctaLabel,
  });

  factory TeacherBroadcastMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return TeacherBroadcastMessage.fromJson(doc.id, data);
  }

  factory TeacherBroadcastMessage.fromJson(
    String id,
    Map<String, dynamic> data,
  ) {
    final audience =
        AgeGroup.fromString(data['audience']?.toString()) ?? AgeGroup.bright;
    return TeacherBroadcastMessage(
      id: id,
      teacherId: data['teacherId']?.toString() ?? '',
      teacherName: data['teacherName']?.toString() ?? 'Teacher',
      teacherAvatar: data['teacherAvatar']?.toString(),
      audience: audience,
      title: data['title']?.toString() ?? 'Teacher Update',
      message: data['message']?.toString() ?? '',
      emoji: data['emoji']?.toString() ?? '✉️',
      category: data['category']?.toString() ?? 'Announcement',
      color: _colorFromData(data['colorValue'], audience),
      quickMessageId: data['quickMessageId']?.toString(),
      gameId: data['gameId']?.toString(),
      gameName: data['gameName']?.toString(),
      gameRoute: data['gameRoute']?.toString(),
      gameLocation: data['gameLocation']?.toString(),
      ctaLabel: data['ctaLabel']?.toString(),
      createdAt: _parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherAvatar': teacherAvatar,
      'audience': audience.name,
      'title': title,
      'message': message,
      'emoji': emoji,
      'category': category,
      'colorValue': color.value,
      'quickMessageId': quickMessageId,
      'gameId': gameId,
      'gameName': gameName,
      'gameRoute': gameRoute,
      'gameLocation': gameLocation,
      'ctaLabel': ctaLabel,
      'createdAt': createdAt,
    };
  }
}
