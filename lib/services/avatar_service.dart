import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/avatar_config.dart';
import '../models/user_type.dart';

/// Service for managing avatar configurations
class AvatarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String avatarConfigsCollection = 'avatarConfigs';

  /// Get avatar configuration for a child
  Future<AvatarConfig?> getAvatarConfig(String childId) async {
    try {
      final doc = await _firestore
          .collection(avatarConfigsCollection)
          .doc(childId)
          .get();

      if (!doc.exists) {
        // Create default avatar config if it doesn't exist
        return await _createDefaultAvatarConfig(childId);
      }

      return AvatarConfig.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting avatar config for $childId: $e');
      return null;
    }
  }

  /// Create default avatar configuration for a new child
  Future<AvatarConfig> _createDefaultAvatarConfig(String childId) async {
    try {
      final now = DateTime.now();
      final defaultConfig = AvatarConfig(
        id: childId,
        childId: childId,
        outfit: 'casual',
        hairStyle: 'short',
        expression: 'happy',
        skinTone: 'light',
        eyeColor: 'brown',
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(avatarConfigsCollection)
          .doc(childId)
          .set(defaultConfig.toJson());

      return defaultConfig;
    } catch (e) {
      debugPrint('Error creating default avatar config for $childId: $e');
      rethrow;
    }
  }

  /// Save avatar configuration
  Future<void> saveAvatarConfig(AvatarConfig config) async {
    try {
      final configData = config.toJson()
        ..['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection(avatarConfigsCollection)
          .doc(config.childId)
          .set(configData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving avatar config for ${config.childId}: $e');
      rethrow;
    }
  }

  /// Update specific avatar attributes
  Future<void> updateAvatarAttribute({
    required String childId,
    required String attribute,
    required String value,
  }) async {
    try {
      await _firestore.collection(avatarConfigsCollection).doc(childId).update({
        attribute: value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating avatar attribute $attribute for $childId: $e');
      rethrow;
    }
  }

  /// Get all avatar configurations (admin only)
  Future<List<AvatarConfig>> getAllAvatarConfigs({
    required UserType actorRole,
    int? limit,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can get all avatar configurations');
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(avatarConfigsCollection)
          .orderBy('updatedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AvatarConfig.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting all avatar configs: $e');
      return [];
    }
  }

  /// Delete avatar configuration (admin only)
  Future<void> deleteAvatarConfig({
    required String childId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can delete avatar configurations');
    }

    try {
      await _firestore
          .collection(avatarConfigsCollection)
          .doc(childId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting avatar config for $childId: $e');
      rethrow;
    }
  }

  /// Get avatar statistics
  Future<Map<String, dynamic>> getAvatarStatistics() async {
    try {
      final snapshot =
          await _firestore.collection(avatarConfigsCollection).get();
      final configs = snapshot.docs
          .map((doc) => AvatarConfig.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      if (configs.isEmpty) {
        return {
          'totalAvatars': 0,
          'outfitDistribution': {},
          'hairStyleDistribution': {},
          'expressionDistribution': {},
        };
      }

      // Calculate outfit distribution
      final outfitDistribution = <String, int>{};
      for (final config in configs) {
        outfitDistribution[config.outfit] =
            (outfitDistribution[config.outfit] ?? 0) + 1;
      }

      // Calculate hair style distribution
      final hairStyleDistribution = <String, int>{};
      for (final config in configs) {
        hairStyleDistribution[config.hairStyle] =
            (hairStyleDistribution[config.hairStyle] ?? 0) + 1;
      }

      // Calculate expression distribution
      final expressionDistribution = <String, int>{};
      for (final config in configs) {
        expressionDistribution[config.expression] =
            (expressionDistribution[config.expression] ?? 0) + 1;
      }

      return {
        'totalAvatars': configs.length,
        'outfitDistribution': outfitDistribution,
        'hairStyleDistribution': hairStyleDistribution,
        'expressionDistribution': expressionDistribution,
      };
    } catch (e) {
      debugPrint('Error getting avatar statistics: $e');
      return {};
    }
  }

  /// Reset avatar to default (admin only)
  Future<void> resetAvatarToDefault({
    required String childId,
    required UserType actorRole,
  }) async {
    if (actorRole != UserType.admin) {
      throw Exception('Only admins can reset avatars to default');
    }

    try {
      final defaultConfig = await _createDefaultAvatarConfig(childId);
      await saveAvatarConfig(defaultConfig);
    } catch (e) {
      debugPrint('Error resetting avatar to default for $childId: $e');
      rethrow;
    }
  }
}


