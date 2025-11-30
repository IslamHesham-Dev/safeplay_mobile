import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitySessionEntry {
  const ActivitySessionEntry({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.title,
    required this.subject,
    required this.durationMinutes,
    required this.playedAt,
  });

  final String id;
  final String childId;
  final String activityId;
  final String title;
  final String subject;
  final int? durationMinutes;
  final DateTime playedAt;

  factory ActivitySessionEntry.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return ActivitySessionEntry(
      id: snapshot.id,
      childId: data['childId']?.toString() ?? '',
      activityId: data['activityId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Learning activity',
      subject: data['subject']?.toString() ?? 'general',
      durationMinutes: _parseInt(data['durationMinutes']),
      playedAt: _parseTimestamp(data['playedAt']) ?? DateTime.now(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}
