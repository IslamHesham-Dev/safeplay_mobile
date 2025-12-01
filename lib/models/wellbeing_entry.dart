import 'package:cloud_firestore/cloud_firestore.dart';

class WellbeingEntry {
  WellbeingEntry({
    required this.id,
    required this.childId,
    required this.moodLabel,
    required this.moodEmoji,
    required this.moodScore,
    required this.moodIndex,
    this.notes,
    required this.timestamp,
  });

  final String id;
  final String childId;
  final String moodLabel;
  final String moodEmoji;
  final int moodScore;
  final int moodIndex;
  final String? notes;
  final DateTime timestamp;

  factory WellbeingEntry.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    return WellbeingEntry(
      id: snapshot.id,
      childId: data['childId'] as String? ?? '',
      moodLabel: data['moodLabel'] as String? ?? 'Unknown',
      moodEmoji: data['moodEmoji'] as String? ?? '🙂',
      moodScore: (data['moodScore'] as num?)?.toInt() ?? 0,
      moodIndex: (data['moodIndex'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String?,
      timestamp: timestamp,
    );
  }
}
