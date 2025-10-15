import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}

class Incident extends Equatable {
  final String id;
  final String childId;
  final String childName;
  final List<String> parentIds;
  final String type;
  final String severity;
  final String status;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? viewedAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;

  const Incident({
    required this.id,
    required this.childId,
    required this.childName,
    required this.parentIds,
    required this.type,
    required this.severity,
    required this.status,
    required this.title,
    required this.description,
    required this.metadata,
    required this.createdAt,
    this.viewedAt,
    this.acknowledgedAt,
    this.resolvedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      childId: json['childId'] as String? ?? '',
      childName: json['childName'] as String? ?? 'Learner',
      parentIds: (json['parentIds'] as List?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
      type: json['type'] as String? ?? 'system',
      severity: json['severity'] as String? ?? 'low',
      status: json['status'] as String? ?? 'new',
      title: json['title'] as String? ?? 'Incident',
      description: json['description'] as String? ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      viewedAt: _parseDate(json['viewedAt']),
      acknowledgedAt: _parseDate(json['acknowledgedAt']),
      resolvedAt: _parseDate(json['resolvedAt']),
    );
  }

  Incident copyWith({
    String? status,
    DateTime? viewedAt,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
  }) {
    return Incident(
      id: id,
      childId: childId,
      childName: childName,
      parentIds: parentIds,
      type: type,
      severity: severity,
      status: status ?? this.status,
      title: title,
      description: description,
      metadata: metadata,
      createdAt: createdAt,
      viewedAt: viewedAt ?? this.viewedAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  bool get isResolved => status == 'resolved';
  bool get isHighSeverity => severity == 'high' || severity == 'critical';

  @override
  List<Object?> get props => [
        id,
        childId,
        childName,
        parentIds,
        type,
        severity,
        status,
        title,
        description,
        metadata,
        createdAt,
        viewedAt,
        acknowledgedAt,
        resolvedAt,
      ];
}
