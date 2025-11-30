import 'package:cloud_firestore/cloud_firestore.dart';

class BrowserActivityEntry {
  const BrowserActivityEntry({
    required this.id,
    required this.childId,
    required this.activityType,
    required this.category,
    required this.summary,
    required this.tags,
    required this.timestamp,
    this.metadata,
  });

  final String id;
  final String childId;
  final String activityType;
  final String category;
  final String summary;
  final List<String> tags;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  factory BrowserActivityEntry.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return BrowserActivityEntry(
      id: snapshot.id,
      childId: data['childId']?.toString() ?? '',
      activityType: data['activityType']?.toString() ?? 'unknown',
      category: data['category']?.toString() ?? 'General',
      summary: data['summary']?.toString() ?? 'Activity recorded',
      tags: (data['tags'] as List?)
              ?.map((tag) => tag?.toString())
              .whereType<String>()
              .toList() ??
          const [],
      timestamp: _parseTimestamp(data['timestamp']) ?? DateTime.now(),
      metadata: data['metadata'] is Map<String, dynamic>
          ? data['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'activityType': activityType,
      'category': category,
      'summary': summary,
      'tags': tags,
      'timestamp': Timestamp.fromDate(timestamp),
      if (metadata != null) 'metadata': metadata,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
