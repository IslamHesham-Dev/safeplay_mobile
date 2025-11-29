import 'package:cloud_firestore/cloud_firestore.dart';

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

/// Message sent from a Bright student to a teacher inbox.
class TeacherInboxMessage {
  final String id;
  final String teacherId;
  final String teacherName;
  final String? teacherAvatar;
  final String childId;
  final String childName;
  final String? childAvatar;
  final AgeGroup ageGroup;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedBroadcastId;
  final String? relatedGame;

  const TeacherInboxMessage({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.childId,
    required this.childName,
    required this.ageGroup,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.childAvatar,
    this.teacherAvatar,
    this.relatedBroadcastId,
    this.relatedGame,
  });

  factory TeacherInboxMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TeacherInboxMessage.fromJson(doc.id, data);
  }

  factory TeacherInboxMessage.fromJson(String id, Map<String, dynamic> data) {
    final ageGroup =
        AgeGroup.fromString(data['ageGroup']?.toString()) ?? AgeGroup.bright;

    return TeacherInboxMessage(
      id: id,
      teacherId: data['teacherId']?.toString() ?? '',
      teacherName: data['teacherName']?.toString() ?? 'Teacher',
      teacherAvatar: data['teacherAvatar']?.toString(),
      childId: data['childId']?.toString() ?? '',
      childName: data['childName']?.toString() ?? 'Student',
      childAvatar: data['childAvatar']?.toString(),
      ageGroup: ageGroup,
      body: data['message']?.toString() ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      isRead: data['read'] == true,
      relatedBroadcastId: data['relatedBroadcastId']?.toString(),
      relatedGame: data['relatedGame']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherAvatar': teacherAvatar,
      'childId': childId,
      'childName': childName,
      'childAvatar': childAvatar,
      'ageGroup': ageGroup.name,
      'message': body,
      'createdAt': createdAt,
      'read': isRead,
      'relatedBroadcastId': relatedBroadcastId,
      'relatedGame': relatedGame,
    };
  }
}
