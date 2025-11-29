import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/teacher_broadcast_message.dart';
import '../models/teacher_inbox_message.dart';
import '../models/user_type.dart';

/// Handles messaging flows between teachers and Junior/Bright students.
class MessagingService {
  MessagingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String teacherBroadcastsCollection = 'teacherBroadcasts';
  static const String teacherInboxCollection = 'teacherInboxMessages';

  Future<void> sendBroadcast({
    required String teacherId,
    required String teacherName,
    required AgeGroup audience,
    required String title,
    required String body,
    required String emoji,
    required String category,
    required Color color,
    String? teacherAvatar,
    String? quickMessageId,
    String? gameId,
    String? gameName,
    String? gameRoute,
    String? gameLocation,
    String? ctaLabel,
  }) async {
    await _firestore.collection(teacherBroadcastsCollection).add({
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherAvatar': teacherAvatar,
      'audience': audience.name,
      'title': title,
      'message': body,
      'emoji': emoji,
      'category': category,
      'colorValue': color.value,
      'quickMessageId': quickMessageId,
      'gameId': gameId,
      'gameName': gameName,
      'gameRoute': gameRoute,
      'gameLocation': gameLocation,
      'ctaLabel': ctaLabel,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendChildReply({
    required String teacherId,
    required String teacherName,
    required String childId,
    required String childName,
    required AgeGroup ageGroup,
    required String message,
    String? teacherAvatar,
    String? childAvatar,
    String? relatedBroadcastId,
    String? relatedGame,
  }) async {
    await _firestore.collection(teacherInboxCollection).add({
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherAvatar': teacherAvatar,
      'childId': childId,
      'childName': childName,
      'childAvatar': childAvatar,
      'ageGroup': ageGroup.name,
      'message': message,
      'relatedBroadcastId': relatedBroadcastId,
      'relatedGame': relatedGame,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TeacherBroadcastMessage>> listenToBroadcasts({
    required AgeGroup audience,
    int limit = 25,
  }) {
    return _firestore
        .collection(teacherBroadcastsCollection)
        .where('audience', isEqualTo: audience.name)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(TeacherBroadcastMessage.fromFirestore).toList());
  }

  Stream<List<TeacherBroadcastMessage>> listenToTeacherBroadcasts({
    required String teacherId,
    int limit = 10,
  }) {
    return _firestore
        .collection(teacherBroadcastsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(TeacherBroadcastMessage.fromFirestore).toList());
  }

  Stream<List<TeacherInboxMessage>> listenToTeacherInbox({
    required String teacherId,
    int limit = 30,
  }) {
    return _firestore
        .collection(teacherInboxCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(TeacherInboxMessage.fromFirestore).toList(),
        );
  }

  Stream<List<TeacherInboxMessage>> listenToChildReplies({
    required String childId,
    int limit = 50,
  }) {
    return _firestore
        .collection(teacherInboxCollection)
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(TeacherInboxMessage.fromFirestore).toList(),
        );
  }

  Future<void> markInboxMessageRead(String messageId) async {
    await _firestore
        .collection(teacherInboxCollection)
        .doc(messageId)
        .set({'read': true}, SetOptions(merge: true));
  }

  Future<List<TeacherInboxMessage>> fetchTeacherInboxOnce({
    required String teacherId,
    int limit = 30,
  }) async {
    final snapshot = await _firestore
        .collection(teacherInboxCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map(TeacherInboxMessage.fromFirestore)
        .toList(growable: false);
  }

  Future<List<TeacherBroadcastMessage>> fetchTeacherBroadcastsOnce({
    required String teacherId,
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection(teacherBroadcastsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map(TeacherBroadcastMessage.fromFirestore)
        .toList(growable: false);
  }

  Future<List<TeacherInboxMessage>> fetchChildRepliesOnce({
    required String childId,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection(teacherInboxCollection)
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map(TeacherInboxMessage.fromFirestore)
        .toList(growable: false);
  }
}
