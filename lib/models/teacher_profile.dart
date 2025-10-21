import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'activity.dart' as activity;
import 'user_type.dart';

/// Teacher profile model with specialized fields for content creation and publishing
class TeacherProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? displayName;
  final String? profileImageUrl;
  final String? schoolName;
  final String? schoolId;
  final List<String> specializations; // e.g., ['math', 'reading', 'science']
  final List<AgeGroup>
      authorizedAgeGroups; // Which age groups they can publish to
  final List<activity.ActivitySubject>
      authorizedSubjects; // Which subjects they can create
  final TeacherRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> metadata;

  const TeacherProfile({
    required this.id,
    required this.name,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.schoolName,
    this.schoolId,
    this.specializations = const [],
    this.authorizedAgeGroups = const [AgeGroup.junior, AgeGroup.bright],
    this.authorizedSubjects = const [
      activity.ActivitySubject.math,
      activity.ActivitySubject.reading,
      activity.ActivitySubject.writing,
    ],
    this.role = TeacherRole.teacher,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.metadata = const {},
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      schoolName: json['schoolName'] as String?,
      schoolId: json['schoolId'] as String?,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      authorizedAgeGroups: (json['authorizedAgeGroups'] as List<dynamic>?)
              ?.map((e) => AgeGroup.values.firstWhere(
                    (group) => group.name == e.toString(),
                    orElse: () => AgeGroup.junior,
                  ))
              .toList() ??
          const [AgeGroup.junior, AgeGroup.bright],
      authorizedSubjects: (json['authorizedSubjects'] as List<dynamic>?)
              ?.map((e) => activity.ActivitySubject.values.firstWhere(
                    (subject) => subject.name == e.toString(),
                    orElse: () => activity.ActivitySubject.math,
                  ))
              .toList() ??
          const [
            activity.ActivitySubject.math,
            activity.ActivitySubject.reading
          ],
      role: TeacherRole.values.firstWhere(
        (r) => r.name == (json['role'] as String? ?? 'teacher'),
        orElse: () => TeacherRole.teacher,
      ),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp?)?.toDate(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'schoolName': schoolName,
      'schoolId': schoolId,
      'specializations': specializations,
      'authorizedAgeGroups': authorizedAgeGroups.map((e) => e.name).toList(),
      'authorizedSubjects': authorizedSubjects.map((e) => e.name).toList(),
      'role': role.name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'metadata': metadata,
    };
  }

  TeacherProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? schoolName,
    String? schoolId,
    List<String>? specializations,
    List<AgeGroup>? authorizedAgeGroups,
    List<activity.ActivitySubject>? authorizedSubjects,
    TeacherRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return TeacherProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      schoolName: schoolName ?? this.schoolName,
      schoolId: schoolId ?? this.schoolId,
      specializations: specializations ?? this.specializations,
      authorizedAgeGroups: authorizedAgeGroups ?? this.authorizedAgeGroups,
      authorizedSubjects: authorizedSubjects ?? this.authorizedSubjects,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        displayName,
        profileImageUrl,
        schoolName,
        schoolId,
        specializations,
        authorizedAgeGroups,
        authorizedSubjects,
        role,
        isActive,
        createdAt,
        updatedAt,
        lastLoginAt,
        metadata,
      ];
}

/// Teacher roles within the system
enum TeacherRole {
  teacher('Teacher'),
  leadTeacher('Lead Teacher'),
  curriculumCoordinator('Curriculum Coordinator'),
  admin('Administrator');

  const TeacherRole(this.displayName);
  final String displayName;
}
