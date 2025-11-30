import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_session_entry.dart';

class ActivitySessionService {
  ActivitySessionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'activitySessions';

  Future<void> logSession({
    required String childId,
    String? activityId,
    required String title,
    required String subject,
    int? durationMinutes,
  }) async {
    final sessionRef = _firestore
        .collection(_collection)
        .doc(childId)
        .collection('sessions')
        .doc();

    await sessionRef.set({
      'childId': childId,
      'activityId': activityId,
      'title': title,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'playedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ActivitySessionEntry>> fetchSessions(
    String childId, {
    int limit = 40,
  }) async {
    final query = await _firestore
        .collection(_collection)
        .doc(childId)
        .collection('sessions')
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map(ActivitySessionEntry.fromSnapshot)
        .toList(growable: false);
  }
}
