import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  final String id;
  final String userId;
  final String audience;
  final String title;
  final String message;
  final String? imageUrl;
  final String? actionUrl;
  final String type;
  final bool read;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.audience,
    required this.title,
    required this.message,
    this.imageUrl,
    this.actionUrl,
    required this.type,
    required this.read,
    required this.createdAt,
    this.expiresAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime parse(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return NotificationItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      audience: json['audience'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      type: json['type'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'audience': audience,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  NotificationItem copyWith({
    bool? read,
  }) {
    return NotificationItem(
      id: id,
      userId: userId,
      audience: audience,
      title: title,
      message: message,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        audience,
        title,
        message,
        imageUrl,
        actionUrl,
        type,
        read,
        createdAt,
        expiresAt,
      ];
}
