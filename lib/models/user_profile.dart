import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'user_type.dart';

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

List<String> _stringList(dynamic value) {
  if (value == null) return const [];
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

/// User profile model
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String? email;
  final UserType userType;
  final AgeGroup? ageGroup;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    required this.userType,
    this.ageGroup,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      print('[UserProfile]: Parsing JSON: $json');

      final name =
          (json['name'] ?? json['displayName'] ?? json['fullName'] ?? '')
              .toString();
      final role = (json['role'] ?? json['userType'])?.toString();
      final userType = role != null
          ? UserType.values.firstWhere(
              (value) => value.name == role,
              orElse: () =>
                  UserType.parent, // Default to parent instead of guest
            )
          : UserType.parent; // Default to parent instead of guest
      final ageGroupValue = json['ageGroup'] ?? json['age_group'];
      AgeGroup? ageGroup;
      if (ageGroupValue is String) {
        final normalized = ageGroupValue.toLowerCase();
        ageGroup = AgeGroup.values.firstWhere(
          (value) => value.name == normalized,
          orElse: () => AgeGroup.junior,
        );
      }

      // Safe casting for metadata
      Map<String, dynamic>? metadata;
      try {
        final metadataValue = json['metadata'];
        if (metadataValue is Map<String, dynamic>) {
          metadata = metadataValue;
        } else if (metadataValue != null) {
          print(
              '[UserProfile]: Warning - metadata is not a Map, got: ${metadataValue.runtimeType}');
          metadata = null;
        }
      } catch (e) {
        print('[UserProfile]: Error parsing metadata: $e');
        metadata = null;
      }

      final profile = UserProfile(
        id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
        name: name,
        email: json['email']?.toString(),
        userType: userType,
        ageGroup: ageGroup,
        avatarUrl: json['avatarUrl']?.toString(),
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        lastLoginAt: _parseDate(json['lastLoginAt']),
        metadata: metadata,
      );

      print(
          '[UserProfile]: Created profile: ${profile.name} (${profile.userType})');
      return profile;
    } catch (e, stackTrace) {
      print('[UserProfile]: Error parsing UserProfile: $e');
      print('[UserProfile]: Stack trace: $stackTrace');
      print('[UserProfile]: JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType.name,
      'ageGroup': ageGroup?.name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    UserType? userType,
    AgeGroup? ageGroup,
    String? avatarUrl,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      ageGroup: ageGroup ?? this.ageGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        userType,
        ageGroup,
        avatarUrl,
        createdAt,
        lastLoginAt,
        metadata,
      ];
}

class ChildStats extends Equatable {
  final int level;
  final int totalPoints;
  final int totalActivitiesCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityAt;

  const ChildStats({
    this.level = 1,
    this.totalPoints = 0,
    this.totalActivitiesCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityAt,
  });

  factory ChildStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChildStats();
    return ChildStats(
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ??
          (json['xp'] as num?)?.toInt() ??
          0,
      totalActivitiesCompleted:
          (json['totalActivitiesCompleted'] as num?)?.toInt() ??
              (json['activitiesCompleted'] as num?)?.toInt() ??
              0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ??
          (json['streak'] as num?)?.toInt() ??
          0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ??
          (json['longest'] as num?)?.toInt() ??
          0,
      lastActivityAt: _parseDate(json['lastActivityAt']),
    );
  }

  ChildStats copyWith({
    int? level,
    int? totalPoints,
    int? totalActivitiesCompleted,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityAt,
  }) {
    return ChildStats(
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
      totalActivitiesCompleted:
          totalActivitiesCompleted ?? this.totalActivitiesCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'totalPoints': totalPoints,
      'totalActivitiesCompleted': totalActivitiesCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
    }..removeWhere((_, value) => value == null);
  }

  @override
  List<Object?> get props => [
        level,
        totalPoints,
        totalActivitiesCompleted,
        currentStreak,
        longestStreak,
        lastActivityAt,
      ];
}

/// Child profile with additional information
class ChildProfile extends UserProfile {
  final List<String> parentIds;
  final List<String> teacherIds;
  final List<String> counselorIds;
  final int? grade;
  final int? age;
  final ChildStats stats;
  final List<String> achievements;
  final List<String> favoriteSubjects;
  final List<String> learningModes;
  final DateTime updatedAt;
  final Map<String, dynamic>? authData;
  final String? gender; // 'male' or 'female'

  const ChildProfile({
    required super.id,
    required super.name,
    required super.userType,
    required super.ageGroup,
    super.email,
    super.avatarUrl,
    required super.createdAt,
    super.lastLoginAt,
    super.metadata,
    required this.parentIds,
    this.teacherIds = const [],
    this.counselorIds = const [],
    this.grade,
    this.age,
    this.stats = const ChildStats(),
    this.achievements = const [],
    this.favoriteSubjects = const [],
    this.learningModes = const [],
    required this.updatedAt,
    this.authData,
    this.gender,
  });

  String get parentId => parentIds.isNotEmpty ? parentIds.first : '';
  int get xp => stats.totalPoints;
  int get level => stats.level;
  int get streakDays => stats.currentStreak;
  int get totalActivitiesCompleted => stats.totalActivitiesCompleted;
  DateTime? get lastActivityAt => stats.lastActivityAt;
  // Age is now stored directly in the age field

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final ageGroupValue = json['ageGroup'] ?? json['age_group'];
    AgeGroup ageGroup = AgeGroup.junior;
    if (ageGroupValue is String) {
      final normalized = ageGroupValue.toLowerCase();
      ageGroup = AgeGroup.values.firstWhere(
        (value) => value.name == normalized,
        orElse: () => AgeGroup.junior,
      );
    }

    final createdAt = _parseDate(json['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDate(json['updatedAt']) ?? createdAt;
    final preferences = json['preferences'] as Map<String, dynamic>? ?? {};

    final userTypeValue = json['userType']?.toString();
    final inferredUserType = userTypeValue != null
        ? UserType.values.firstWhere(
            (value) => value.name == userTypeValue,
            orElse: () => (ageGroup == AgeGroup.junior
                ? UserType.juniorChild
                : UserType.brightChild),
          )
        : (ageGroup == AgeGroup.junior
            ? UserType.juniorChild
            : UserType.brightChild);

    return ChildProfile(
      id: json['id']?.toString() ?? '',
      name: (json['fullName'] ?? json['name'] ?? '').toString(),
      userType: inferredUserType,
      ageGroup: ageGroup,
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      createdAt: createdAt,
      lastLoginAt: _parseDate(json['lastLoginAt']),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      parentIds: _stringList(json['parentIds'] ?? json['parentId']),
      teacherIds: _stringList(json['teacherIds']),
      counselorIds: _stringList(json['counselorIds']),
      grade: (json['grade'] as num?)?.toInt(),
      age: (json['age'] as num?)?.toInt(),
      stats: ChildStats.fromJson(json['stats'] as Map<String, dynamic>?),
      achievements: _stringList(json['achievements']),
      favoriteSubjects:
          _stringList(preferences['favoriteSubjects']).map((e) => e).toList(),
      learningModes: _stringList(preferences['learningModes']),
      updatedAt: updatedAt,
      authData: json['authData'] is Map<String, dynamic>
          ? json['authData'] as Map<String, dynamic>
          : null,
      gender: json['gender']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'fullName': name,
      'parentIds': parentIds,
      'teacherIds': teacherIds,
      'counselorIds': counselorIds,
      'grade': grade,
      'age': age,
      'stats': stats.toJson(),
      'achievements': achievements,
      'preferences': {
        'favoriteSubjects': favoriteSubjects,
        'learningModes': learningModes,
      },
      'updatedAt': updatedAt.toIso8601String(),
      'authData': authData,
      'gender': gender,
    });
    return json;
  }

  @override
  ChildProfile copyWith({
    String? name,
    String? email,
    UserType? userType,
    AgeGroup? ageGroup,
    String? avatarUrl,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
    List<String>? parentIds,
    List<String>? teacherIds,
    List<String>? counselorIds,
    int? grade,
    int? age,
    ChildStats? stats,
    List<String>? achievements,
    List<String>? favoriteSubjects,
    List<String>? learningModes,
    DateTime? updatedAt,
    Map<String, dynamic>? authData,
    String? gender,
  }) {
    return ChildProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      ageGroup: ageGroup ?? this.ageGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
      parentIds: parentIds ?? this.parentIds,
      teacherIds: teacherIds ?? this.teacherIds,
      counselorIds: counselorIds ?? this.counselorIds,
      grade: grade ?? this.grade,
      age: age ?? this.age,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      favoriteSubjects: favoriteSubjects ?? this.favoriteSubjects,
      learningModes: learningModes ?? this.learningModes,
      updatedAt: updatedAt ?? this.updatedAt,
      authData: authData ?? this.authData,
      gender: gender ?? this.gender,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        parentIds,
        teacherIds,
        counselorIds,
        grade,
        age,
        stats,
        achievements,
        favoriteSubjects,
        learningModes,
        updatedAt,
        authData,
        gender,
      ];
}
