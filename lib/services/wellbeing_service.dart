import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wellbeing_entry.dart';

class WellbeingService {
  WellbeingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'wellbeingReports';

  Future<void> submitEntry({
    required String childId,
    required String moodLabel,
    required String moodEmoji,
    required int moodScore,
    required int moodIndex,
    String? notes,
  }) async {
    final doc = _firestore
        .collection(_collection)
        .doc(childId)
        .collection('entries')
        .doc();

    await doc.set({
      'childId': childId,
      'moodLabel': moodLabel,
      'moodEmoji': moodEmoji,
      'moodScore': moodScore,
      'moodIndex': moodIndex,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<WellbeingEntry>> fetchEntries(
    String childId, {
    int limit = 40,
  }) async {
    final query = await _firestore
        .collection(_collection)
        .doc(childId)
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return query.docs.map(WellbeingEntry.fromSnapshot).toList(growable: false);
  }
}
