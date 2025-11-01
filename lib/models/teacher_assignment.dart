import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Teacher assignment model for assigning lessons to children or groups
class TeacherAssignment extends Equatable {
  final String id;
  final String teacherId;
  final List<String>
      childGroupIds; // Groups of children (or individual children)
  final List<String> lessonIds; // Lessons to be completed
  final DateTime dueDate;
  final String? title;
  final String? description;
  final AssignmentStatus status;
  final Map<String, dynamic>
      instructions; // Additional instructions for the assignment
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // Teacher ID who created this assignment
  final Map<String, dynamic> metadata;

  const TeacherAssignment({
    required this.id,
    required this.teacherId,
    required this.childGroupIds,
    required this.lessonIds,
    required this.dueDate,
    this.title,
    this.description,
    this.status = AssignmentStatus.active,
    this.instructions = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.metadata = const {},
  });

  factory TeacherAssignment.fromJson(Map<String, dynamic> json) {
    return TeacherAssignment(
      id: json['id']?.toString() ?? '',
      teacherId: json['teacherId']?.toString() ?? '',
      childGroupIds:
          _parseStringList(json['childGroupIds'] ?? json['child_group_ids']),
      lessonIds: _parseStringList(json['lessonIds'] ?? json['lesson_ids']),
      dueDate:
          _parseDateTime(json['dueDate'] ?? json['due_date']) ?? DateTime.now(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      status: _parseAssignmentStatus(json['status']),
      instructions: _parseMap(json['instructions']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']) ??
          DateTime.now(),
      createdBy: json['createdBy'] ?? json['created_by']?.toString(),
      metadata: _parseMap(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'childGroupIds': childGroupIds,
      'lessonIds': lessonIds,
      'dueDate': Timestamp.fromDate(dueDate),
      'title': title,
      'description': description,
      'status': status.name,
      'instructions': instructions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  /// Check if the assignment is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status == AssignmentStatus.active;
  }

  /// Check if the assignment is due soon (within 24 hours)
  bool get isDueSoon {
    final now = DateTime.now();
    final timeUntilDue = dueDate.difference(now);
    return timeUntilDue.inHours <= 24 &&
        timeUntilDue.inHours > 0 &&
        status == AssignmentStatus.active;
  }

  /// Get days until due date
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Check if assignment is active
  bool get isActive => status == AssignmentStatus.active;

  /// Check if assignment is completed
  bool get isCompleted => status == AssignmentStatus.completed;

  /// Check if assignment is cancelled
  bool get isCancelled => status == AssignmentStatus.cancelled;

  /// Create a copy with updated fields
  TeacherAssignment copyWith({
    String? id,
    String? teacherId,
    List<String>? childGroupIds,
    List<String>? lessonIds,
    DateTime? dueDate,
    String? title,
    String? description,
    AssignmentStatus? status,
    Map<String, dynamic>? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return TeacherAssignment(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      childGroupIds: childGroupIds ?? this.childGroupIds,
      lessonIds: lessonIds ?? this.lessonIds,
      dueDate: dueDate ?? this.dueDate,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Mark assignment as completed
  TeacherAssignment markAsCompleted() {
    return copyWith(
      status: AssignmentStatus.completed,
      updatedAt: DateTime.now(),
    );
  }

  /// Cancel the assignment
  TeacherAssignment cancel() {
    return copyWith(
      status: AssignmentStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Add more children to the assignment
  TeacherAssignment addChildren(List<String> newChildGroupIds) {
    final updatedChildGroupIds = List<String>.from(childGroupIds);
    for (final childId in newChildGroupIds) {
      if (!updatedChildGroupIds.contains(childId)) {
        updatedChildGroupIds.add(childId);
      }
    }
    return copyWith(
      childGroupIds: updatedChildGroupIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove children from the assignment
  TeacherAssignment removeChildren(List<String> childGroupIdsToRemove) {
    final updatedChildGroupIds = List<String>.from(childGroupIds);
    updatedChildGroupIds
        .removeWhere((id) => childGroupIdsToRemove.contains(id));
    return copyWith(
      childGroupIds: updatedChildGroupIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Add more lessons to the assignment
  TeacherAssignment addLessons(List<String> newLessonIds) {
    final updatedLessonIds = List<String>.from(lessonIds);
    for (final lessonId in newLessonIds) {
      if (!updatedLessonIds.contains(lessonId)) {
        updatedLessonIds.add(lessonId);
      }
    }
    return copyWith(
      lessonIds: updatedLessonIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove lessons from the assignment
  TeacherAssignment removeLessons(List<String> lessonIdsToRemove) {
    final updatedLessonIds = List<String>.from(lessonIds);
    updatedLessonIds.removeWhere((id) => lessonIdsToRemove.contains(id));
    return copyWith(
      lessonIds: updatedLessonIds,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        childGroupIds,
        lessonIds,
        dueDate,
        title,
        description,
        status,
        instructions,
        createdAt,
        updatedAt,
        createdBy,
        metadata,
      ];

  // Helper methods for parsing JSON
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item?.toString())
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [value.toString()];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  static AssignmentStatus _parseAssignmentStatus(dynamic value) {
    if (value == null) return AssignmentStatus.active;
    final stringValue = value.toString().toLowerCase();
    for (final status in AssignmentStatus.values) {
      if (status.name.toLowerCase() == stringValue) {
        return status;
      }
    }
    return AssignmentStatus.active;
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}

/// Assignment status enum
enum AssignmentStatus {
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled'),
  expired('Expired');

  const AssignmentStatus(this.displayName);
  final String displayName;
}


