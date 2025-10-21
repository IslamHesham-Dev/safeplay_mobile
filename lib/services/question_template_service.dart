import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/question_template.dart';
import '../models/activity.dart';
import '../models/user_type.dart';

/// Service for managing question templates with age-appropriate content
class QuestionTemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String templatesCollection = 'questionTemplates';
  static const String curriculumStandardsCollection = 'curriculumStandards';

  /// Get templates filtered by age group and subject
  Future<List<QuestionTemplate>> getTemplatesByAgeAndSubject({
    required AgeGroup ageGroup,
    required ActivitySubject subject,
    List<String>? skills,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(templatesCollection)
          .where('isActive', isEqualTo: true)
          .where('ageGroups', arrayContains: ageGroup.name)
          .where('subjects', arrayContains: subject.name);

      if (skills != null && skills.isNotEmpty) {
        query = query.where('skills', arrayContainsAny: skills);
      }

      final snapshot = await query.orderBy('title').get();

      return snapshot.docs
          .map((doc) => QuestionTemplate.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting templates by age and subject: $e');
      return [];
    }
  }

  /// Create a new question template
  Future<String> createTemplate({
    required String title,
    required QuestionType type,
    required String prompt,
    required List<String> options,
    required dynamic correctAnswer,
    required List<AgeGroup> ageGroups,
    required List<ActivitySubject> subjects,
    required List<String> skills,
    String? explanation,
    String? hint,
    ActivityQuestionMedia? media,
    int points = 10,
    String? createdBy,
  }) async {
    try {
      final templateData = {
        'title': title,
        'type': type.rawValue,
        'prompt': prompt,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'hint': hint,
        'media': media?.toJson(),
        'points': points,
        'skills': skills,
        'ageGroups': ageGroups.map((g) => g.name).toList(),
        'subjects': subjects.map((s) => s.name).toList(),
        'isActive': true,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await _firestore.collection(templatesCollection).add(templateData);

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating template: $e');
      rethrow;
    }
  }

  /// Get curriculum-aligned templates based on the provided reference data
  Future<List<QuestionTemplate>> getCurriculumAlignedTemplates({
    required AgeGroup ageGroup,
    required ActivitySubject subject,
    required Difficulty difficulty,
  }) async {
    try {
      // Get templates that match the criteria
      final templates = await getTemplatesByAgeAndSubject(
        ageGroup: ageGroup,
        subject: subject,
      );

      // Filter by difficulty and apply curriculum-specific logic
      final filteredTemplates = templates.where((template) {
        // Apply age-appropriate filtering based on the curriculum reference
        return _isTemplateAppropriateForDifficulty(
            template, difficulty, ageGroup);
      }).toList();

      return filteredTemplates;
    } catch (e) {
      debugPrint('Error getting curriculum-aligned templates: $e');
      return [];
    }
  }

  /// Check if template is appropriate for the given difficulty and age group
  bool _isTemplateAppropriateForDifficulty(
    QuestionTemplate template,
    Difficulty difficulty,
    AgeGroup ageGroup,
  ) {
    // Junior Explorer (6-8) specific logic
    if (ageGroup == AgeGroup.junior) {
      switch (difficulty) {
        case Difficulty.easy:
          // Level 1: Basic recognition and simple tasks
          return template.skills.any((skill) => [
                'number-recognition',
                'basic-addition',
                'simple-patterns',
                'basic-reading',
                'simple-grammar',
              ].contains(skill));

        case Difficulty.medium:
          // Level 2: More complex operations and structure
          return template.skills.any((skill) => [
                'skip-counting',
                'place-value',
                'fractions',
                'reading-comprehension',
                'sentence-structure',
              ].contains(skill));

        case Difficulty.hard:
          // Advanced for this age group
          return template.skills.any((skill) => [
                'problem-solving',
                'data-interpretation',
                'complex-reading',
                'advanced-grammar',
              ].contains(skill));
      }
    }

    // Bright Minds (9-12) specific logic
    else if (ageGroup == AgeGroup.bright) {
      switch (difficulty) {
        case Difficulty.easy:
          // Level 1: Established procedures
          return template.skills.any((skill) => [
                'rounding',
                'fraction-conversion',
                'basic-grammar',
                'reading-comprehension',
              ].contains(skill));

        case Difficulty.medium:
          // Level 2: Multi-step problems and complex strategies
          return template.skills.any((skill) => [
                'division-strategies',
                'ratio-problems',
                'area-perimeter',
                'complex-reading',
                'grammar-analysis',
              ].contains(skill));

        case Difficulty.hard:
          // Advanced concepts
          return template.skills.any((skill) => [
                'large-number-manipulation',
                'probability',
                'complex-analysis',
                'advanced-comprehension',
              ].contains(skill));
      }
    }

    return true; // Default to true if no specific logic applies
  }

  /// Seed curriculum-aligned templates based on the reference data
  Future<void> seedCurriculumTemplates() async {
    try {
      // Junior Explorer Mathematics Templates
      await _seedJuniorMathTemplates();

      // Junior Explorer English Templates
      await _seedJuniorEnglishTemplates();

      // Bright Minds Mathematics Templates
      await _seedBrightMathTemplates();

      // Bright Minds English Templates
      await _seedBrightEnglishTemplates();

      // Mindful Exercise Templates
      await _seedMindfulTemplates();
    } catch (e) {
      debugPrint('Error seeding curriculum templates: $e');
      rethrow;
    }
  }

  Future<void> _seedJuniorMathTemplates() async {
    final templates = [
      // Level 1 (Easy) - Basic recognition and simple tasks
      {
        'title': 'Ordinal Numbers Match',
        'type': QuestionType.matching,
        'prompt': 'Match the ordinal numbers with their words',
        'options': ['1st', '2nd', '3rd', '4th', '5th', '6th'],
        'correctAnswer': [
          'first',
          'second',
          'third',
          'fourth',
          'fifth',
          'sixth'
        ],
        'skills': ['number-recognition', 'ordinal-numbers'],
        'points': 50,
      },
      {
        'title': 'Addition Facts to 10',
        'type': QuestionType.multipleChoice,
        'prompt': 'What is 7 + 3?',
        'options': ['8', '9', '10', '11'],
        'correctAnswer': '10',
        'skills': ['basic-addition', 'number-facts'],
        'points': 40,
      },
      {
        'title': 'Skip Counting by 2s',
        'type': QuestionType.textInput,
        'prompt': 'Complete the sequence: 2, 4, 6, __, __',
        'correctAnswer': '8, 10',
        'skills': ['skip-counting', 'number-patterns'],
        'points': 60,
      },
      {
        'title': 'Shape Halving',
        'type': QuestionType.multipleChoice,
        'prompt': 'Which shape is correctly divided into halves?',
        'options': [
          'Circle with line through center',
          'Square with diagonal line',
          'Triangle with line through middle'
        ],
        'correctAnswer': 'Circle with line through center',
        'skills': ['fractions', 'shape-recognition'],
        'points': 70,
      },

      // Level 2 (Hard) - More complex operations
      {
        'title': 'Word Problem Number Sentence',
        'type': QuestionType.textInput,
        'prompt':
            'Sarah has 8 apples. She gives away 3. Write the number sentence.',
        'correctAnswer': '8 - 3 = 5',
        'skills': ['problem-solving', 'subtraction'],
        'points': 80,
      },
      {
        'title': 'Pictograph Interpretation',
        'type': QuestionType.multipleChoice,
        'prompt': 'In the pictograph, which subject is most popular?',
        'options': ['Math', 'Reading', 'Science', 'Art'],
        'correctAnswer': 'Math',
        'skills': ['data-interpretation', 'graph-reading'],
        'points': 100,
      },
    ];

    for (final template in templates) {
      await createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.junior],
        subjects: [ActivitySubject.math],
        skills: template['skills'] as List<String>,
        points: template['points'] as int,
      );
    }
  }

  Future<void> _seedJuniorEnglishTemplates() async {
    final templates = [
      // Level 1 (Easy)
      {
        'title': 'Character Feelings',
        'type': QuestionType.multipleChoice,
        'prompt': 'How did the character feel at the beginning of the story?',
        'options': ['Happy', 'Sad', 'Excited', 'Nervous'],
        'correctAnswer': 'Nervous',
        'skills': ['reading-comprehension', 'character-analysis'],
        'points': 80,
      },
      {
        'title': 'Conjunction Builder',
        'type': QuestionType.multipleChoice,
        'prompt':
            'Choose the correct conjunction: "I like apples ___ I don\'t like oranges."',
        'options': ['and', 'but', 'because'],
        'correctAnswer': 'but',
        'skills': ['simple-grammar', 'conjunctions'],
        'points': 50,
      },

      // Level 2 (Hard)
      {
        'title': 'Non-fiction Subheadings',
        'type': QuestionType.matching,
        'prompt': 'Match the paragraph descriptions to their subheadings',
        'options': ['Habitat', 'Diet', 'Behavior', 'Conservation'],
        'correctAnswer': [
          'Where they live',
          'What they eat',
          'How they act',
          'Protection efforts'
        ],
        'skills': ['reading-comprehension', 'text-structure'],
        'points': 70,
      },
    ];

    for (final template in templates) {
      await createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.junior],
        subjects: [ActivitySubject.reading],
        skills: template['skills'] as List<String>,
        points: template['points'] as int,
      );
    }
  }

  Future<void> _seedBrightMathTemplates() async {
    final templates = [
      // Level 1 (Easy)
      {
        'title': 'Rounding to Nearest 1000',
        'type': QuestionType.textInput,
        'prompt': 'Round 62,147 to the nearest 1000',
        'correctAnswer': '62,000',
        'skills': ['rounding', 'place-value'],
        'points': 70,
      },
      {
        'title': 'Improper to Mixed Fractions',
        'type': QuestionType.textInput,
        'prompt': 'Convert 7/2 to a mixed number',
        'correctAnswer': '3 1/2',
        'skills': ['fraction-conversion', 'mixed-numbers'],
        'points': 75,
      },
      {
        'title': 'Compensation Subtraction',
        'type': QuestionType.textInput,
        'prompt': 'Use compensation to solve: 85 - 19',
        'correctAnswer': '66',
        'skills': ['mental-strategy', 'subtraction'],
        'points': 80,
      },

      // Level 2 (Hard)
      {
        'title': 'Division with Remainder',
        'type': QuestionType.textInput,
        'prompt':
            '125 marbles shared between 2 children. How many each and remainder?',
        'correctAnswer': '62 remainder 1',
        'skills': ['division-strategies', 'remainders'],
        'points': 150,
      },
      {
        'title': 'Ratio Word Problem',
        'type': QuestionType.textInput,
        'prompt':
            'If the ratio of cats to dogs is 3:2 and there are 12 cats, how many dogs?',
        'correctAnswer': '8',
        'skills': ['ratio-problems', 'proportional-reasoning'],
        'points': 130,
      },
      {
        'title': 'Area of Combined Shapes',
        'type': QuestionType.textInput,
        'prompt':
            'Find the area of a rectangle (6x4) plus a triangle (base 4, height 3)',
        'correctAnswer': '30',
        'skills': ['area-perimeter', 'combined-shapes'],
        'points': 100,
      },
    ];

    for (final template in templates) {
      await createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.bright],
        subjects: [ActivitySubject.math],
        skills: template['skills'] as List<String>,
        points: template['points'] as int,
      );
    }
  }

  Future<void> _seedBrightEnglishTemplates() async {
    final templates = [
      // Level 1 (Easy)
      {
        'title': 'Facts vs Opinions',
        'type': QuestionType.multipleChoice,
        'prompt': 'Which statement is a fact?',
        'options': [
          'The Galápagos Islands are beautiful',
          'The Galápagos Islands are in the Pacific Ocean',
          'I love visiting islands'
        ],
        'correctAnswer': 'The Galápagos Islands are in the Pacific Ocean',
        'skills': ['reading-comprehension', 'fact-opinion'],
        'points': 90,
      },
      {
        'title': 'Prefix Meaning Match',
        'type': QuestionType.matching,
        'prompt': 'Match prefixes to their meanings',
        'options': ['under-', 'over-', 're-'],
        'correctAnswer': ['too little', 'too much', 'again'],
        'skills': ['vocabulary', 'prefixes'],
        'points': 60,
      },

      // Level 2 (Hard)
      {
        'title': 'Passive to Active Voice',
        'type': QuestionType.textInput,
        'prompt': 'Change to active voice: "The book was read by Sarah"',
        'correctAnswer': 'Sarah read the book',
        'skills': ['grammar-analysis', 'voice'],
        'points': 70,
      },
      {
        'title': 'Character Analysis',
        'type': QuestionType.textInput,
        'prompt':
            'How does the author show the character\'s personality? Provide evidence.',
        'correctAnswer': 'Through dialogue and actions',
        'skills': ['complex-analysis', 'character-study'],
        'points': 120,
      },
    ];

    for (final template in templates) {
      await createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.bright],
        subjects: [ActivitySubject.reading],
        skills: template['skills'] as List<String>,
        points: template['points'] as int,
      );
    }
  }

  Future<void> _seedMindfulTemplates() async {
    final templates = [
      // Junior Explorer Mindful Exercises
      {
        'title': 'Guided Nature Imagination',
        'type': QuestionType.textInput,
        'prompt': 'Listen to the nature sounds and describe what you imagine',
        'correctAnswer': 'Any thoughtful response about nature',
        'skills': ['mindfulness', 'imagination'],
        'points': 30,
      },
      {
        'title': 'Deep Breathing Follow-along',
        'type': QuestionType.multipleChoice,
        'prompt': 'How do you feel after the breathing exercise?',
        'options': ['Calm', 'Focused', 'Relaxed', 'All of the above'],
        'correctAnswer': 'All of the above',
        'skills': ['mindfulness', 'self-regulation'],
        'points': 40,
      },

      // Bright Minds Mindful Exercises
      {
        'title': 'Learning Reflection',
        'type': QuestionType.textInput,
        'prompt': 'What did you learn today and how do you feel about it?',
        'correctAnswer': 'Any reflective response',
        'skills': ['metacognition', 'self-awareness'],
        'points': 30,
      },
      {
        'title': 'Ethical Decision Scenario',
        'type': QuestionType.textInput,
        'prompt':
            'A friend asks to copy your homework. What would you do and why?',
        'correctAnswer': 'Any thoughtful ethical reasoning',
        'skills': ['ethical-reasoning', 'decision-making'],
        'points': 40,
      },
    ];

    for (final template in templates) {
      await createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: template['title'].toString().contains('Junior')
            ? [AgeGroup.junior]
            : [AgeGroup.bright],
        subjects: [
          ActivitySubject.social
        ], // Using social studies for mindful exercises
        skills: template['skills'] as List<String>,
        points: template['points'] as int,
      );
    }
  }
}
