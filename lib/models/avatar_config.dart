import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Avatar configuration model for Junior children
class AvatarConfig extends Equatable {
  final String id;
  final String childId;
  final String outfit; // e.g., 'casual', 'formal', 'sporty', 'costume'
  final String hairStyle; // e.g., 'short', 'long', 'curly', 'spiky'
  final String expression; // e.g., 'happy', 'excited', 'focused', 'proud'
  final String skinTone; // e.g., 'light', 'medium', 'dark'
  final String eyeColor; // e.g., 'brown', 'blue', 'green', 'hazel'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const AvatarConfig({
    required this.id,
    required this.childId,
    required this.outfit,
    required this.hairStyle,
    required this.expression,
    required this.skinTone,
    required this.eyeColor,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory AvatarConfig.fromJson(Map<String, dynamic> json) {
    return AvatarConfig(
      id: json['id']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      outfit: json['outfit']?.toString() ?? 'casual',
      hairStyle: json['hairStyle']?.toString() ?? 'short',
      expression: json['expression']?.toString() ?? 'happy',
      skinTone: json['skinTone']?.toString() ?? 'light',
      eyeColor: json['eyeColor']?.toString() ?? 'brown',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']) ??
          DateTime.now(),
      metadata: _parseMap(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'outfit': outfit,
      'hairStyle': hairStyle,
      'expression': expression,
      'skinTone': skinTone,
      'eyeColor': eyeColor,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  AvatarConfig copyWith({
    String? id,
    String? childId,
    String? outfit,
    String? hairStyle,
    String? expression,
    String? skinTone,
    String? eyeColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AvatarConfig(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      outfit: outfit ?? this.outfit,
      hairStyle: hairStyle ?? this.hairStyle,
      expression: expression ?? this.expression,
      skinTone: skinTone ?? this.skinTone,
      eyeColor: eyeColor ?? this.eyeColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get available outfit options
  static List<String> getOutfitOptions() {
    return ['casual', 'formal', 'sporty', 'costume', 'adventure', 'party'];
  }

  /// Get available hair style options
  static List<String> getHairStyleOptions() {
    return ['short', 'long', 'curly', 'spiky', 'braids', 'ponytail'];
  }

  /// Get available expression options
  static List<String> getExpressionOptions() {
    return ['happy', 'excited', 'focused', 'proud', 'curious', 'determined'];
  }

  /// Get available skin tone options
  static List<String> getSkinToneOptions() {
    return ['light', 'medium', 'dark', 'tan'];
  }

  /// Get available eye color options
  static List<String> getEyeColorOptions() {
    return ['brown', 'blue', 'green', 'hazel', 'gray'];
  }

  /// Get avatar image path based on configuration
  String getAvatarImagePath() {
    return 'assets/images/avatars/junior/${skinTone}_${hairStyle}_${expression}_${outfit}.png';
  }

  /// Get outfit icon path
  String getOutfitIconPath() {
    return 'assets/images/avatars/outfits/${outfit}.png';
  }

  /// Get hair style icon path
  String getHairStyleIconPath() {
    return 'assets/images/avatars/hair/${hairStyle}.png';
  }

  /// Get expression icon path
  String getExpressionIconPath() {
    return 'assets/images/avatars/expressions/${expression}.png';
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        outfit,
        hairStyle,
        expression,
        skinTone,
        eyeColor,
        createdAt,
        updatedAt,
        metadata,
      ];

  // Helper methods for parsing JSON
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

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}


