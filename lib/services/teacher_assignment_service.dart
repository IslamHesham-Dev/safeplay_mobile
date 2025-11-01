import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/teacher_assignment.dart';
import '../models/user_type.dart';

/// Service for managing teacher assignments
class TeacherAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String teacherAssignmentsCollection = 'teacherAssignments';

  /// Create a new teacher assignment
  Future<String> createAssignment({
    required TeacherAssignment assignment,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can create assignments');
    }

    _validateAssignment(assignment);

    try {
      final docRef = _firestore.collection(teacherAssignmentsCollection).doc();
      final now = DateTime.now();

      final assignmentData = assignment.toJson()
        ..remove('id')
        ..['id'] = docRef.id
        ..['createdAt'] = Timestamp.fromDate(now)
        ..['updatedAt'] = Timestamp.fromDate(now);

      await docRef.set(assignmentData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating assignment: $e');
      rethrow;
    }
  }

  /// Get an assignment by ID
  Future<TeacherAssignment?> getAssignment(String assignmentId) async {
    try {
      final doc = await _firestore
          .collection(teacherAssignmentsCollection)
          .doc(assignmentId)
          .get();

      if (!doc.exists) return null;

      return TeacherAssignment.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting assignment $assignmentId: $e');
      return null;
    }
  }

  /// Get assignments for a specific teacher
  Future<List<TeacherAssignment>> getTeacherAssignments({
    required String teacherId,
    AssignmentStatus? status,
    bool? isOverdue,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(teacherAssignmentsCollection)
          .where('teacherId', isEqualTo: teacherId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final assignments = snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Filter by overdue status if requested
      if (isOverdue != null) {
        return assignments
            .where((assignment) => assignment.isOverdue == isOverdue)
            .toList();
      }

      return assignments;
    } catch (e) {
      debugPrint('Error getting teacher assignments for $teacherId: $e');
      return [];
    }
  }

  /// Get assignments for specific children/groups
  Future<List<TeacherAssignment>> getAssignmentsForChildren({
    required List<String> childGroupIds,
    AssignmentStatus? status,
    bool? isOverdue,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(teacherAssignmentsCollection)
          .where('childGroupIds', arrayContainsAny: childGroupIds);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final assignments = snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Filter by overdue status if requested
      if (isOverdue != null) {
        return assignments
            .where((assignment) => assignment.isOverdue == isOverdue)
            .toList();
      }

      return assignments;
    } catch (e) {
      debugPrint('Error getting assignments for children: $e');
      return [];
    }
  }

  /// Get all assignments (admin only)
  Future<List<TeacherAssignment>> getAllAssignments({
    AssignmentStatus? status,
    String? teacherId,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(teacherAssignmentsCollection);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting all assignments: $e');
      return [];
    }
  }

  /// Update an assignment
  Future<void> updateAssignment({
    required TeacherAssignment assignment,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can update assignments');
    }

    _validateAssignment(assignment);

    try {
      final assignmentData = assignment.toJson()
        ..['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection(teacherAssignmentsCollection)
          .doc(assignment.id)
          .set(assignmentData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating assignment ${assignment.id}: $e');
      rethrow;
    }
  }

  /// Mark assignment as completed
  Future<void> markAssignmentCompleted({
    required String assignmentId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can mark assignments as completed');
    }

    try {
      await _firestore
          .collection(teacherAssignmentsCollection)
          .doc(assignmentId)
          .update({
        'status': AssignmentStatus.completed.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error marking assignment $assignmentId as completed: $e');
      rethrow;
    }
  }

  /// Cancel an assignment
  Future<void> cancelAssignment({
    required String assignmentId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can cancel assignments');
    }

    try {
      await _firestore
          .collection(teacherAssignmentsCollection)
          .doc(assignmentId)
          .update({
        'status': AssignmentStatus.cancelled.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error cancelling assignment $assignmentId: $e');
      rethrow;
    }
  }

  /// Delete an assignment (admin only)
  Future<void> deleteAssignment({
    required String assignmentId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can delete assignments');
    }

    try {
      await _firestore
          .collection(teacherAssignmentsCollection)
          .doc(assignmentId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting assignment $assignmentId: $e');
      rethrow;
    }
  }

  /// Get assignments by lesson IDs
  Future<List<TeacherAssignment>> getAssignmentsByLessons(
      List<String> lessonIds) async {
    if (lessonIds.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection(teacherAssignmentsCollection)
          .where('lessonIds', arrayContainsAny: lessonIds)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting assignments by lessons: $e');
      return [];
    }
  }

  /// Get overdue assignments
  Future<List<TeacherAssignment>> getOverdueAssignments({
    String? teacherId,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(teacherAssignmentsCollection)
          .where('status', isEqualTo: AssignmentStatus.active.name);

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      query = query.orderBy('dueDate', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final assignments = snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Filter for overdue assignments
      final now = DateTime.now();
      return assignments
          .where((assignment) => assignment.dueDate.isBefore(now))
          .toList();
    } catch (e) {
      debugPrint('Error getting overdue assignments: $e');
      return [];
    }
  }

  /// Get assignments due soon (within 24 hours)
  Future<List<TeacherAssignment>> getAssignmentsDueSoon({
    String? teacherId,
    int? limit,
  }) async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(hours: 24));

      Query<Map<String, dynamic>> query = _firestore
          .collection(teacherAssignmentsCollection)
          .where('status', isEqualTo: AssignmentStatus.active.name)
          .where('dueDate', isGreaterThan: Timestamp.fromDate(now))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(tomorrow));

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      query = query.orderBy('dueDate', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting assignments due soon: $e');
      return [];
    }
  }

  /// Get assignment statistics
  Future<Map<String, dynamic>> getAssignmentStatistics({
    String? teacherId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(teacherAssignmentsCollection);

      if (teacherId != null) {
        query = query.where('teacherId', isEqualTo: teacherId);
      }

      final snapshot = await query.get();
      final assignments = snapshot.docs
          .map((doc) => TeacherAssignment.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      final totalAssignments = assignments.length;
      final activeAssignments = assignments.where((a) => a.isActive).length;
      final completedAssignments =
          assignments.where((a) => a.isCompleted).length;
      final cancelledAssignments =
          assignments.where((a) => a.isCancelled).length;
      final overdueAssignments = assignments.where((a) => a.isOverdue).length;
      final dueSoonAssignments = assignments.where((a) => a.isDueSoon).length;

      return {
        'totalAssignments': totalAssignments,
        'activeAssignments': activeAssignments,
        'completedAssignments': completedAssignments,
        'cancelledAssignments': cancelledAssignments,
        'overdueAssignments': overdueAssignments,
        'dueSoonAssignments': dueSoonAssignments,
      };
    } catch (e) {
      debugPrint('Error getting assignment statistics: $e');
      return {};
    }
  }

  /// Add children to an assignment
  Future<void> addChildrenToAssignment({
    required String assignmentId,
    required List<String> childGroupIds,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can modify assignments');
    }

    try {
      final assignment = await getAssignment(assignmentId);
      if (assignment == null) {
        throw Exception('Assignment not found');
      }

      final updatedAssignment = assignment.addChildren(childGroupIds);
      await updateAssignment(
          assignment: updatedAssignment, actorRole: actorRole);
    } catch (e) {
      debugPrint('Error adding children to assignment $assignmentId: $e');
      rethrow;
    }
  }

  /// Remove children from an assignment
  Future<void> removeChildrenFromAssignment({
    required String assignmentId,
    required List<String> childGroupIds,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can modify assignments');
    }

    try {
      final assignment = await getAssignment(assignmentId);
      if (assignment == null) {
        throw Exception('Assignment not found');
      }

      final updatedAssignment = assignment.removeChildren(childGroupIds);
      await updateAssignment(
          assignment: updatedAssignment, actorRole: actorRole);
    } catch (e) {
      debugPrint('Error removing children from assignment $assignmentId: $e');
      rethrow;
    }
  }

  /// Add lessons to an assignment
  Future<void> addLessonsToAssignment({
    required String assignmentId,
    required List<String> lessonIds,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can modify assignments');
    }

    try {
      final assignment = await getAssignment(assignmentId);
      if (assignment == null) {
        throw Exception('Assignment not found');
      }

      final updatedAssignment = assignment.addLessons(lessonIds);
      await updateAssignment(
          assignment: updatedAssignment, actorRole: actorRole);
    } catch (e) {
      debugPrint('Error adding lessons to assignment $assignmentId: $e');
      rethrow;
    }
  }

  /// Remove lessons from an assignment
  Future<void> removeLessonsFromAssignment({
    required String assignmentId,
    required List<String> lessonIds,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.teacher && actorRole != UserType.admin) {
      throw Exception('Only teachers/admins can modify assignments');
    }

    try {
      final assignment = await getAssignment(assignmentId);
      if (assignment == null) {
        throw Exception('Assignment not found');
      }

      final updatedAssignment = assignment.removeLessons(lessonIds);
      await updateAssignment(
          assignment: updatedAssignment, actorRole: actorRole);
    } catch (e) {
      debugPrint('Error removing lessons from assignment $assignmentId: $e');
      rethrow;
    }
  }

  /// Validate assignment data
  void _validateAssignment(TeacherAssignment assignment) {
    if (assignment.teacherId.trim().isEmpty) {
      throw Exception('Teacher ID cannot be empty');
    }

    if (assignment.childGroupIds.isEmpty) {
      throw Exception('Assignment must have at least one child group');
    }

    if (assignment.lessonIds.isEmpty) {
      throw Exception('Assignment must have at least one lesson');
    }

    if (assignment.dueDate.isBefore(DateTime.now())) {
      throw Exception('Due date cannot be in the past');
    }
  }
}


