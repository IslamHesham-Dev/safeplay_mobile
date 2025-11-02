import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/question_template.dart';

/// Simple service for loading templates without complex filtering
class SimpleTemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load all active templates from the database
  Future<List<QuestionTemplate>> getAllTemplates() async {
    debugPrint('SimpleTemplateService: Loading all templates...');

    final baseQuery = _firestore
        .collection('curriculumQuestionTemplates') // Use new collection only
        .where('isActive', isEqualTo: true);

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await baseQuery.orderBy('title').get();
    } on FirebaseException catch (error) {
      if (error.code == 'failed-precondition') {
        debugPrint(
            'SimpleTemplateService: Missing index for title/isActive, retrying without order...');
        snapshot = await baseQuery.get();
      } else if (error.code == 'permission-denied') {
        debugPrint(
            'SimpleTemplateService: Permission denied loading templates');
        rethrow;
      } else {
        debugPrint(
            'SimpleTemplateService: Firestore error loading templates: $error');
        rethrow;
      }
    }

    debugPrint(
        'SimpleTemplateService: Found ${snapshot.docs.length} templates in database');

    final templates = <QuestionTemplate>[];
    for (final doc in snapshot.docs) {
      try {
        templates.add(QuestionTemplate.fromJson({
          'id': doc.id,
          ...doc.data(),
        }));
      } catch (error) {
        debugPrint(
            'SimpleTemplateService: Error parsing template ${doc.id}: $error');
      }
    }

    templates.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    debugPrint(
        'SimpleTemplateService: Successfully loaded ${templates.length} templates');
    return templates;
  }

  /// Load templates by age group
  Future<List<QuestionTemplate>> getTemplatesByAgeGroup(String ageGroup) async {
    try {
      debugPrint(
          '🔍 SimpleTemplateService: Loading templates for age group: $ageGroup');

      final snapshot = await _firestore
          .collection('curriculumQuestionTemplates') // Use new collection only
          .where('isActive', isEqualTo: true)
          .where('ageGroups', arrayContains: ageGroup)
          .orderBy('title')
          .get();

      final templates = snapshot.docs
          .map((doc) => QuestionTemplate.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      debugPrint(
          '✅ SimpleTemplateService: Loaded ${templates.length} templates for $ageGroup');
      return templates;
    } catch (e) {
      debugPrint(
          '❌ SimpleTemplateService: Error loading templates for $ageGroup: $e');
      return [];
    }
  }

  /// Load templates by subject
  Future<List<QuestionTemplate>> getTemplatesBySubject(String subject) async {
    try {
      debugPrint(
          '🔍 SimpleTemplateService: Loading templates for subject: $subject');

      final snapshot = await _firestore
          .collection('curriculumQuestionTemplates') // Use new collection only
          .where('isActive', isEqualTo: true)
          .where('subjects', arrayContains: subject)
          .orderBy('title')
          .get();

      final templates = snapshot.docs
          .map((doc) => QuestionTemplate.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      debugPrint(
          '✅ SimpleTemplateService: Loaded ${templates.length} templates for $subject');
      return templates;
    } catch (e) {
      debugPrint(
          '❌ SimpleTemplateService: Error loading templates for $subject: $e');
      return [];
    }
  }

  /// Load a single template by ID
  Future<QuestionTemplate?> getTemplateById(String templateId) async {
    try {
      debugPrint('🔍 SimpleTemplateService: Loading template: $templateId');

      final doc = await _firestore
          .collection('curriculumQuestionTemplates') // Use new collection only
          .doc(templateId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ SimpleTemplateService: Template $templateId not found');
        return null;
      }

      final template = QuestionTemplate.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });

      debugPrint('✅ SimpleTemplateService: Loaded template $templateId');
      return template;
    } catch (e) {
      debugPrint(
          '❌ SimpleTemplateService: Error loading template $templateId: $e');
      return null;
    }
  }
}
