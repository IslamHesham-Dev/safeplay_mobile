import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AuthLogEntry extends Equatable {
  final String id;
  final String userId;
  final String action;
  final String userAgent;
  final DateTime timestamp;

  const AuthLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    required this.userAgent,
    required this.timestamp,
  });

  factory AuthLogEntry.fromJson(Map<String, dynamic> json) {
    DateTime parse(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return AuthLogEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      userAgent: json['userAgent'] as String? ?? 'unknown',
      timestamp: parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'action': action,
      'userAgent': userAgent,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, action, userAgent, timestamp];
}
