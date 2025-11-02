import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/question_template.dart';
import '../models/user_type.dart';

/// Service for loading break activities
class BreakActivitiesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'breakActivities';

  /// Load break activities for a specific age group
  Future<List<QuestionTemplate>> getBreakActivities({
    AgeGroup? ageGroup,
    bool activeOnly = true,
  }) async {
    try {
      debugPrint('🔍 Loading break activities...');
      debugPrint('Age group: $ageGroup');
      debugPrint('Active only: $activeOnly');

      Query<Map<String, dynamic>> query = _firestore.collection(collectionName);

      // Filter by isActive if needed
      if (activeOnly) {
        try {
          query = query.where('isActive', isEqualTo: true);
        } catch (e) {
          debugPrint('⚠️ isActive filter not available');
        }
      }

      // Filter by age group if provided
      if (ageGroup != null) {
        try {
          query = query.where('ageGroups', arrayContains: ageGroup.name);
        } catch (e) {
          debugPrint('⚠️ Age group filter error: $e');
        }
      }

      // Try to order by title
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await query.orderBy('title').get();
      } catch (e) {
        debugPrint('⚠️ Cannot order by title: $e');
        snapshot = await query.get();
      }

      debugPrint('📊 Found ${snapshot.docs.length} break activities');

      // Parse break activities as QuestionTemplate objects
      final activities = <QuestionTemplate>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Client-side filtering for isActive
          if (activeOnly &&
              data.containsKey('isActive') &&
              data['isActive'] != true) {
            continue;
          }

          // Client-side filtering for age group
          if (ageGroup != null) {
            final ageGroupsList = data['ageGroups'] as List?;
            final templateAgeGroups = ageGroupsList != null
                ? ageGroupsList
                    .map((g) => g?.toString().toLowerCase())
                    .whereType<String>()
                    .toList()
                : <String>[];

            if (!templateAgeGroups.contains(ageGroup.name.toLowerCase())) {
              continue;
            }
          }

          // Convert break activity data to QuestionTemplate format
          final template = QuestionTemplate.fromJson({
            'id': doc.id,
            ...data,
            // Ensure it has required fields
            'type': data['type'] ?? 'interactive',
            'prompt': data['prompt'] ?? data['title'] ?? '',
            'points': data['points'] ?? 15,
            'subjects': data['subjects'] ?? ['wellbeing'],
            'ageGroups': data['ageGroups'] ?? [],
            'skills': data['skills'] ?? [],
            'isBreakActivity': true, // Mark as break activity
          });

          activities.add(template);
        } catch (e) {
          debugPrint('❌ Error parsing break activity ${doc.id}: $e');
          continue;
        }
      }

      debugPrint('✅ Successfully loaded ${activities.length} break activities');
      return activities;
    } catch (e) {
      debugPrint('❌ Error loading break activities: $e');
      return [];
    }
  }

  /// Load all break activities (no filters)
  Future<List<QuestionTemplate>> getAllBreakActivities() async {
    return getBreakActivities(activeOnly: true);
  }
}
