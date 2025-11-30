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
  static const String childInboxCollection = 'childInboxMessages'; // Teacher replies to children

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
    String? gameType,
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
      'gameType': gameType,
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

  /// Send a reply from a teacher to a child
  Future<void> sendTeacherReply({
    required String teacherId,
    required String teacherName,
    required String childId,
    required String childName,
    required AgeGroup ageGroup,
    required String message,
    String? teacherAvatar,
    String? childAvatar,
    String? relatedInboxMessageId,
  }) async {
    await _firestore.collection(childInboxCollection).add({
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherAvatar': teacherAvatar,
      'childId': childId,
      'childName': childName,
      'childAvatar': childAvatar,
      'ageGroup': ageGroup.name,
      'message': message,
      'relatedInboxMessageId': relatedInboxMessageId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Listen to teacher replies for a specific child
  Stream<List<TeacherInboxMessage>> listenToTeacherReplies({
    required String childId,
    int limit = 50,
  }) {
    return _firestore
        .collection(childInboxCollection)
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(TeacherInboxMessage.fromFirestore).toList(),
        );
  }

  /// Fetch messages around a specific timestamp for a conversation between child and teacher
  Future<List<Map<String, dynamic>>> fetchConversationContext({
    required String childId,
    required String teacherId,
    required DateTime aroundTimestamp,
    int messagesBefore = 3,
    int messagesAfter = 3,
  }) async {
    final startTime = aroundTimestamp.subtract(const Duration(hours: 24));
    final endTime = aroundTimestamp.add(const Duration(hours: 24));

    // Fetch child to teacher messages - use simple query without time filters to avoid index requirements
    // We'll filter by time in memory
    QuerySnapshot childToTeacherSnapshot;
    try {
      childToTeacherSnapshot = await _firestore
          .collection(teacherInboxCollection)
          .where('childId', isEqualTo: childId)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Get recent messages, filter by time in memory
          .get();
    } catch (_) {
      // If orderBy fails (missing index), fetch without orderBy and sort in memory
      childToTeacherSnapshot = await _firestore
          .collection(teacherInboxCollection)
          .where('childId', isEqualTo: childId)
          .where('teacherId', isEqualTo: teacherId)
          .limit(100)
          .get();
    }

    // Fetch teacher to child messages
    QuerySnapshot teacherToChildSnapshot;
    try {
      teacherToChildSnapshot = await _firestore
          .collection(childInboxCollection)
          .where('childId', isEqualTo: childId)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
    } catch (_) {
      // If orderBy fails (missing index), fetch without orderBy and sort in memory
      teacherToChildSnapshot = await _firestore
          .collection(childInboxCollection)
          .where('childId', isEqualTo: childId)
          .where('teacherId', isEqualTo: teacherId)
          .limit(100)
          .get();
    }

    final allMessages = <Map<String, dynamic>>[];

    // Process child to teacher messages
    for (final doc in childToTeacherSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      DateTime timestamp;
      if (createdAt is Timestamp) {
        timestamp = createdAt.toDate();
      } else if (createdAt is DateTime) {
        timestamp = createdAt;
      } else {
        continue; // Skip if no valid timestamp
      }

      // Filter by time range
      if (timestamp.isBefore(startTime) || timestamp.isAfter(endTime)) {
        continue;
      }

      allMessages.add({
        'id': doc.id,
        'sender': data['childName']?.toString() ?? 'Child',
        'message': data['message']?.toString() ?? '',
        'timestamp': timestamp,
        'isFromChild': true,
        'senderAvatar': data['childAvatar']?.toString(),
      });
    }

    // Process teacher to child messages
    for (final doc in teacherToChildSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      DateTime timestamp;
      if (createdAt is Timestamp) {
        timestamp = createdAt.toDate();
      } else if (createdAt is DateTime) {
        timestamp = createdAt;
      } else {
        continue; // Skip if no valid timestamp
      }

      // Filter by time range
      if (timestamp.isBefore(startTime) || timestamp.isAfter(endTime)) {
        continue;
      }

      allMessages.add({
        'id': doc.id,
        'sender': data['teacherName']?.toString() ?? 'Teacher',
        'message': data['message']?.toString() ?? '',
        'timestamp': timestamp,
        'isFromChild': false,
        'senderAvatar': data['teacherAvatar']?.toString(),
      });
    }

    // Sort by timestamp
    allMessages.sort((a, b) => (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));

    // Find the flagged message index (within 5 minutes of the alert timestamp)
    final flaggedIndex = allMessages.indexWhere((msg) {
      final msgTime = msg['timestamp'] as DateTime;
      return msgTime.difference(aroundTimestamp).abs().inMinutes < 5;
    });

    if (flaggedIndex == -1) {
      // If we can't find the exact message, return messages around the timestamp
      final filtered = allMessages.where((msg) {
        final msgTime = msg['timestamp'] as DateTime;
        return msgTime.isAfter(aroundTimestamp.subtract(const Duration(hours: 1))) &&
               msgTime.isBefore(aroundTimestamp.add(const Duration(hours: 1)));
      }).toList();
      return filtered;
    }

    // Get messages before and after the flagged message
    final startIndex = (flaggedIndex - messagesBefore).clamp(0, allMessages.length);
    final endIndex = (flaggedIndex + messagesAfter + 1).clamp(0, allMessages.length);
    
    return allMessages.sublist(startIndex, endIndex);
  }
}
