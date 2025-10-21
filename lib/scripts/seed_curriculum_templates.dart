import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/user_type.dart';
import '../models/question_template.dart';
import '../services/question_template_service.dart';

/// Script to seed curriculum-aligned question templates based on the provided reference data
class CurriculumTemplateSeeder {
  final QuestionTemplateService _templateService = QuestionTemplateService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed all curriculum templates
  Future<void> seedAllTemplates() async {
    try {
      print('🌱 Starting curriculum template seeding...');

      await _seedJuniorExplorerMathTemplates();
      await _seedJuniorExplorerEnglishTemplates();
      await _seedBrightMindsMathTemplates();
      await _seedBrightMindsEnglishTemplates();
      await _seedMindfulExerciseTemplates();

      print('✅ Curriculum template seeding completed successfully!');
    } catch (e) {
      print('❌ Error seeding curriculum templates: $e');
      rethrow;
    }
  }

  /// Seed Junior Explorer (6-8) Mathematics templates
  Future<void> _seedJuniorExplorerMathTemplates() async {
    print('📚 Seeding Junior Explorer Math templates...');

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
        'explanation':
            'Ordinal numbers tell us the position or order of things.',
        'hint': 'Think about the order: first, second, third...',
      },
      {
        'title': 'Addition Facts to 10',
        'type': QuestionType.multipleChoice,
        'prompt': 'What is 7 + 3?',
        'options': ['8', '9', '10', '11'],
        'correctAnswer': '10',
        'skills': ['basic-addition', 'number-facts'],
        'points': 40,
        'explanation': '7 + 3 = 10. You can count: 7, 8, 9, 10.',
        'hint': 'Count up from 7: 8, 9, 10.',
      },
      {
        'title': 'Skip Counting by 2s',
        'type': QuestionType.textInput,
        'prompt': 'Complete the sequence: 2, 4, 6, __, __',
        'correctAnswer': '8, 10',
        'skills': ['skip-counting', 'number-patterns'],
        'points': 60,
        'explanation':
            'Skip counting by 2s means counting every second number.',
        'hint': 'Add 2 to each number: 6 + 2 = 8, 8 + 2 = 10.',
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
        'explanation':
            'Halves are two equal parts. A circle divided through its center creates two equal halves.',
        'hint': 'Look for shapes divided into two equal parts.',
      },
      {
        'title': 'Number Sequence Patterns',
        'type': QuestionType.textInput,
        'prompt': 'What comes next in the pattern: 5, 10, 15, __?',
        'correctAnswer': '20',
        'skills': ['number-patterns', 'skip-counting'],
        'points': 55,
        'explanation': 'This pattern counts by 5s: 5, 10, 15, 20.',
        'hint': 'Count by 5s: 5, 10, 15, what comes next?',
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
        'explanation':
            'Sarah starts with 8 apples and gives away 3, so 8 - 3 = 5 apples left.',
        'hint': 'Start with 8, take away 3, what\'s left?',
      },
      {
        'title': 'Pictograph Interpretation',
        'type': QuestionType.multipleChoice,
        'prompt':
            'In the pictograph showing favorite subjects, which has the most votes?',
        'options': [
          'Math (4 pictures)',
          'Reading (3 pictures)',
          'Science (2 pictures)',
          'Art (5 pictures)'
        ],
        'correctAnswer': 'Art (5 pictures)',
        'skills': ['data-interpretation', 'graph-reading'],
        'points': 100,
        'explanation':
            'Art has 5 pictures, which is more than the other subjects.',
        'hint':
            'Count the pictures for each subject and find the highest number.',
      },
      {
        'title': 'Place Value Challenge',
        'type': QuestionType.textInput,
        'prompt': 'What is the value of 4 in the number 47?',
        'correctAnswer': '40',
        'skills': ['place-value', 'number-recognition'],
        'points': 90,
        'explanation':
            'In 47, the 4 is in the tens place, so it represents 40.',
        'hint': 'The 4 is in the tens place, so it means 4 tens or 40.',
      },
    ];

    for (final template in templates) {
      await _templateService.createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.junior],
        subjects: [ActivitySubject.math],
        skills: template['skills'] as List<String>,
        explanation: template['explanation'] as String?,
        hint: template['hint'] as String?,
        points: template['points'] as int,
      );
    }

    print('✅ Seeded ${templates.length} Junior Explorer Math templates');
  }

  /// Seed Junior Explorer (6-8) English Language Arts templates
  Future<void> _seedJuniorExplorerEnglishTemplates() async {
    print('📚 Seeding Junior Explorer English templates...');

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
        'explanation':
            'The character was nervous about starting at a new school.',
        'hint': 'Look for clues about how the character felt at the start.',
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
        'explanation':
            '\'But\' shows contrast between liking apples and not liking oranges.',
        'hint':
            'The sentence shows two different feelings, so we need a word that shows contrast.',
      },
      {
        'title': 'Rhyming Words',
        'type': QuestionType.matching,
        'prompt': 'Match the words that rhyme',
        'options': ['cat', 'dog', 'hat', 'log'],
        'correctAnswer': ['cat', 'hat', 'dog', 'log'],
        'skills': ['phonemic-awareness', 'rhyming'],
        'points': 60,
        'explanation': 'Cat rhymes with hat, and dog rhymes with log.',
        'hint': 'Listen for words that end with the same sound.',
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
        'explanation':
            'Subheadings help organize information in non-fiction texts.',
        'hint': 'Think about what each description is telling you about.',
      },
      {
        'title': 'Story Sequence',
        'type': QuestionType.sequencing,
        'prompt': 'Put these story events in the correct order',
        'options': [
          'The girl found the key',
          'The door opened',
          'She walked to the door',
          'She put the key in the lock'
        ],
        'correctAnswer': [
          'The girl found the key',
          'She walked to the door',
          'She put the key in the lock',
          'The door opened'
        ],
        'skills': ['story-sequence', 'reading-comprehension'],
        'points': 85,
        'explanation': 'Stories follow a logical sequence of events.',
        'hint': 'Think about what happens first, second, third, and last.',
      },
    ];

    for (final template in templates) {
      await _templateService.createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.junior],
        subjects: [ActivitySubject.reading],
        skills: template['skills'] as List<String>,
        explanation: template['explanation'] as String?,
        hint: template['hint'] as String?,
        points: template['points'] as int,
      );
    }

    print('✅ Seeded ${templates.length} Junior Explorer English templates');
  }

  /// Seed Bright Minds (9-12) Mathematics templates
  Future<void> _seedBrightMindsMathTemplates() async {
    print('📚 Seeding Bright Minds Math templates...');

    final templates = [
      // Level 1 (Easy) - Established procedures
      {
        'title': 'Rounding to Nearest 1000',
        'type': QuestionType.textInput,
        'prompt': 'Round 62,147 to the nearest 1000',
        'correctAnswer': '62,000',
        'skills': ['rounding', 'place-value'],
        'points': 70,
        'explanation':
            'Look at the hundreds digit (1). Since it\'s less than 5, round down to 62,000.',
        'hint':
            'Look at the hundreds digit to decide whether to round up or down.',
      },
      {
        'title': 'Improper to Mixed Fractions',
        'type': QuestionType.textInput,
        'prompt': 'Convert 7/2 to a mixed number',
        'correctAnswer': '3 1/2',
        'skills': ['fraction-conversion', 'mixed-numbers'],
        'points': 75,
        'explanation': '7 ÷ 2 = 3 remainder 1, so 7/2 = 3 1/2.',
        'hint':
            'Divide the numerator by the denominator to get the whole number and remainder.',
      },
      {
        'title': 'Compensation Subtraction',
        'type': QuestionType.textInput,
        'prompt': 'Use compensation to solve: 85 - 19',
        'correctAnswer': '66',
        'skills': ['mental-strategy', 'subtraction'],
        'points': 80,
        'explanation': '85 - 19 = 85 - 20 + 1 = 65 + 1 = 66',
        'hint': 'Round 19 to 20, subtract, then add back the difference.',
      },
      {
        'title': 'Area of Rectangle',
        'type': QuestionType.textInput,
        'prompt':
            'Find the area of a rectangle with length 8 cm and width 5 cm',
        'correctAnswer': '40',
        'skills': ['area-perimeter', 'multiplication'],
        'points': 85,
        'explanation': 'Area = length × width = 8 × 5 = 40 square centimeters.',
        'hint': 'Multiply the length by the width to find the area.',
      },

      // Level 2 (Hard) - Multi-step problems
      {
        'title': 'Division with Remainder',
        'type': QuestionType.textInput,
        'prompt':
            '125 marbles shared between 2 children. How many each and remainder?',
        'correctAnswer': '62 remainder 1',
        'skills': ['division-strategies', 'remainders'],
        'points': 150,
        'explanation':
            '125 ÷ 2 = 62 remainder 1. Each child gets 62 marbles with 1 left over.',
        'hint': 'Divide 125 by 2 and express the answer with remainder.',
      },
      {
        'title': 'Ratio Word Problem',
        'type': QuestionType.textInput,
        'prompt':
            'If the ratio of cats to dogs is 3:2 and there are 12 cats, how many dogs?',
        'correctAnswer': '8',
        'skills': ['ratio-problems', 'proportional-reasoning'],
        'points': 130,
        'explanation':
            'If 3 parts = 12 cats, then 1 part = 4. So 2 parts = 8 dogs.',
        'hint': 'Find the value of one part, then multiply by 2.',
      },
      {
        'title': 'Area of Combined Shapes',
        'type': QuestionType.textInput,
        'prompt':
            'Find the area of a rectangle (6×4) plus a triangle (base 4, height 3)',
        'correctAnswer': '30',
        'skills': ['area-perimeter', 'combined-shapes'],
        'points': 100,
        'explanation': 'Rectangle: 6×4=24, Triangle: (4×3)÷2=6, Total: 24+6=30',
        'hint':
            'Find the area of each shape separately, then add them together.',
      },
      {
        'title': 'Probability Scale',
        'type': QuestionType.multipleChoice,
        'prompt':
            'What is the probability of rolling a 3 on a fair 6-sided die?',
        'options': ['1/6', '1/3', '1/2', '3/6'],
        'correctAnswer': '1/6',
        'skills': ['probability', 'fractions'],
        'points': 110,
        'explanation':
            'There is 1 way to roll a 3 out of 6 possible outcomes, so the probability is 1/6.',
        'hint':
            'Count the favorable outcomes and divide by total possible outcomes.',
      },
    ];

    for (final template in templates) {
      await _templateService.createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.bright],
        subjects: [ActivitySubject.math],
        skills: template['skills'] as List<String>,
        explanation: template['explanation'] as String?,
        hint: template['hint'] as String?,
        points: template['points'] as int,
      );
    }

    print('✅ Seeded ${templates.length} Bright Minds Math templates');
  }

  /// Seed Bright Minds (9-12) English Language Arts templates
  Future<void> _seedBrightMindsEnglishTemplates() async {
    print('📚 Seeding Bright Minds English templates...');

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
        'explanation':
            'Facts can be proven true or false, while opinions express personal feelings.',
        'hint': 'Look for a statement that can be checked and verified.',
      },
      {
        'title': 'Prefix Meaning Match',
        'type': QuestionType.matching,
        'prompt': 'Match prefixes to their meanings',
        'options': ['under-', 'over-', 're-'],
        'correctAnswer': ['too little', 'too much', 'again'],
        'skills': ['vocabulary', 'prefixes'],
        'points': 60,
        'explanation':
            'Prefixes change the meaning of words: under- means too little, over- means too much, re- means again.',
        'hint': 'Think about words like underground, overflow, and replay.',
      },
      {
        'title': 'Sentence Simplification',
        'type': QuestionType.textInput,
        'prompt':
            'Simplify this sentence for a younger audience: "The magnificent creature exhibited extraordinary behavior."',
        'correctAnswer': 'The amazing animal showed very special behavior.',
        'skills': ['vocabulary', 'sentence-structure'],
        'points': 85,
        'explanation':
            'Replace complex words with simpler ones that younger children can understand.',
        'hint': 'Replace big words with smaller, easier words.',
      },

      // Level 2 (Hard)
      {
        'title': 'Passive to Active Voice',
        'type': QuestionType.textInput,
        'prompt': 'Change to active voice: "The book was read by Sarah"',
        'correctAnswer': 'Sarah read the book',
        'skills': ['grammar-analysis', 'voice'],
        'points': 70,
        'explanation':
            'In active voice, the subject performs the action. Sarah (subject) read (action) the book (object).',
        'hint': 'Make the person doing the action the subject of the sentence.',
      },
      {
        'title': 'Character Analysis',
        'type': QuestionType.textInput,
        'prompt':
            'How does the author show the character\'s personality? Provide evidence.',
        'correctAnswer': 'Through dialogue and actions',
        'skills': ['complex-analysis', 'character-study'],
        'points': 120,
        'explanation':
            'Authors reveal character through what they say, do, and how others react to them.',
        'hint': 'Look at what the character says and does in the story.',
      },
      {
        'title': 'Expert Evidence Analysis',
        'type': QuestionType.matching,
        'prompt':
            'Match the experts to their evidence about marine archaeology',
        'options': ['Marine Archaeologist', 'Diver', 'Historian', 'Scientist'],
        'correctAnswer': [
          'Shipwreck artifacts',
          'Underwater photos',
          'Historical records',
          'Carbon dating results'
        ],
        'skills': ['reading-comprehension', 'evidence-analysis'],
        'points': 130,
        'explanation':
            'Different experts provide different types of evidence based on their expertise.',
        'hint':
            'Think about what each type of expert would be able to provide as evidence.',
      },
    ];

    for (final template in templates) {
      await _templateService.createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [AgeGroup.bright],
        subjects: [ActivitySubject.reading],
        skills: template['skills'] as List<String>,
        explanation: template['explanation'] as String?,
        hint: template['hint'] as String?,
        points: template['points'] as int,
      );
    }

    print('✅ Seeded ${templates.length} Bright Minds English templates');
  }

  /// Seed Mindful Exercise templates for both age groups
  Future<void> _seedMindfulExerciseTemplates() async {
    print('📚 Seeding Mindful Exercise templates...');

    final templates = [
      // Junior Explorer Mindful Exercises
      {
        'title': 'Guided Nature Imagination',
        'type': QuestionType.textInput,
        'prompt': 'Listen to the nature sounds and describe what you imagine',
        'correctAnswer': 'Any thoughtful response about nature',
        'skills': ['mindfulness', 'imagination'],
        'points': 30,
        'explanation': 'Using imagination helps us relax and feel calm.',
        'hint': 'Think about peaceful places in nature.',
        'ageGroup': AgeGroup.junior,
      },
      {
        'title': 'Deep Breathing Follow-along',
        'type': QuestionType.multipleChoice,
        'prompt': 'How do you feel after the breathing exercise?',
        'options': ['Calm', 'Focused', 'Relaxed', 'All of the above'],
        'correctAnswer': 'All of the above',
        'skills': ['mindfulness', 'self-regulation'],
        'points': 40,
        'explanation':
            'Deep breathing helps us feel calm, focused, and relaxed.',
        'hint':
            'Think about how your body feels after taking slow, deep breaths.',
        'ageGroup': AgeGroup.junior,
      },

      // Bright Minds Mindful Exercises
      {
        'title': 'Learning Reflection',
        'type': QuestionType.textInput,
        'prompt': 'What did you learn today and how do you feel about it?',
        'correctAnswer': 'Any reflective response',
        'skills': ['metacognition', 'self-awareness'],
        'points': 30,
        'explanation':
            'Reflecting on learning helps us understand ourselves better.',
        'hint': 'Think about what you learned and how it made you feel.',
        'ageGroup': AgeGroup.bright,
      },
      {
        'title': 'Ethical Decision Scenario',
        'type': QuestionType.textInput,
        'prompt':
            'A friend asks to copy your homework. What would you do and why?',
        'correctAnswer': 'Any thoughtful ethical reasoning',
        'skills': ['ethical-reasoning', 'decision-making'],
        'points': 40,
        'explanation':
            'Making ethical decisions helps us become better people.',
        'hint': 'Think about what is right and fair for everyone involved.',
        'ageGroup': AgeGroup.bright,
      },
    ];

    for (final template in templates) {
      await _templateService.createTemplate(
        title: template['title'] as String,
        type: template['type'] as QuestionType,
        prompt: template['prompt'] as String,
        options: (template['options'] as List<String>?) ?? [],
        correctAnswer: template['correctAnswer'],
        ageGroups: [template['ageGroup'] as teacher.AgeGroup],
        subjects: [
          ActivitySubject.social
        ], // Using social studies for mindful exercises
        skills: template['skills'] as List<String>,
        explanation: template['explanation'] as String?,
        hint: template['hint'] as String?,
        points: template['points'] as int,
      );
    }

    print('✅ Seeded ${templates.length} Mindful Exercise templates');
  }
}

/// Main function to run the seeding script
Future<void> main() async {
  final seeder = CurriculumTemplateSeeder();
  await seeder.seedAllTemplates();
}
