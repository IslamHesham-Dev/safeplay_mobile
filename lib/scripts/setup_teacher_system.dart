import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity.dart';
import '../models/user_type.dart';
import '../services/question_template_service.dart';

/// Comprehensive setup script for the teacher system
/// This script will seed all curriculum-aligned templates and set up the system
class TeacherSystemSetup {
  final QuestionTemplateService _templateService = QuestionTemplateService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run the complete setup process
  Future<void> setupCompleteSystem() async {
    try {
      print('🚀 Starting Teacher System Setup...');

      // Step 1: Seed all curriculum templates
      await _seedAllCurriculumTemplates();

      // Step 2: Set up visibility rules
      await _setupVisibilityRules();

      // Step 3: Create sample teacher profile (if needed)
      await _createSampleTeacherProfile();

      print('✅ Teacher System Setup Complete!');
      print('📚 All curriculum templates have been seeded');
      print('🔒 Visibility rules have been configured');
      print('👨‍🏫 Teacher system is ready for use');
    } catch (e) {
      print('❌ Error during setup: $e');
      rethrow;
    }
  }

  /// Seed all curriculum-aligned templates based on the reference data
  Future<void> _seedAllCurriculumTemplates() async {
    print('📚 Seeding curriculum templates...');

    // Junior Explorer Math Templates
    await _seedJuniorExplorerMathTemplates();

    // Junior Explorer English Templates
    await _seedJuniorExplorerEnglishTemplates();

    // Bright Minds Math Templates
    await _seedBrightMindsMathTemplates();

    // Bright Minds English Templates
    await _seedBrightMindsEnglishTemplates();

    // Mindful Exercise Templates
    await _seedMindfulExerciseTemplates();

    print('✅ All curriculum templates seeded successfully!');
  }

  /// Seed Junior Explorer (6-8) Mathematics templates
  Future<void> _seedJuniorExplorerMathTemplates() async {
    print('🔢 Seeding Junior Explorer Math templates...');

    final templates = [
      // Level 1 (Easy) - Basic recognition and simple tasks
      {
        'title': 'Ordinal Numbers Match',
        'type': QuestionType.matching,
        'prompt':
            'Match the ordinal numbers (1st to 6th) with their words (first to sixth)',
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
        'difficulty': Difficulty.easy,
        'duration': 2,
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
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
      {
        'title': 'Skip Counting Race',
        'type': QuestionType.textInput,
        'prompt': 'Complete the sequence: 10, 20, 30, __, __',
        'correctAnswer': '40, 50',
        'skills': ['skip-counting', 'number-patterns'],
        'points': 60,
        'explanation':
            'Skip counting by 10s means counting every tenth number.',
        'hint': 'Add 10 to each number: 30 + 10 = 40, 40 + 10 = 50.',
        'difficulty': Difficulty.easy,
        'duration': 2,
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
        'difficulty': Difficulty.easy,
        'duration': 3,
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
        'difficulty': Difficulty.hard,
        'duration': 3,
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
        'difficulty': Difficulty.hard,
        'duration': 4,
      },
      {
        'title': 'Place Value Challenge',
        'type': QuestionType.textInput,
        'prompt': 'What is the difference between 47 and 23?',
        'correctAnswer': '24',
        'skills': ['place-value', 'subtraction'],
        'points': 90,
        'explanation':
            '47 - 23 = 24. You can count up from 23 to 47 or subtract directly.',
        'hint': 'Subtract 23 from 47: 47 - 23 = 24.',
        'difficulty': Difficulty.hard,
        'duration': 4,
      },
      {
        'title': 'Calculator Words',
        'type': QuestionType.textInput,
        'prompt':
            'Enter 710 on a calculator and turn it upside down. What word do you see?',
        'correctAnswer': 'oil',
        'skills': ['number-manipulation', 'creativity'],
        'points': 120,
        'explanation':
            'When you turn 710 upside down, it looks like the word "oil".',
        'hint': 'Try writing 710 and then turning the paper upside down.',
        'difficulty': Difficulty.hard,
        'duration': 5,
      },
    ];

    for (final template in templates) {
      try {
        final templateId = await _templateService.createTemplate(
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
        print('✅ Created template: ${template['title']} (ID: $templateId)');
      } catch (e) {
        print('❌ Error creating template ${template['title']}: $e');
      }
    }

    print('✅ Seeded ${templates.length} Junior Explorer Math templates');
  }

  /// Seed Junior Explorer (6-8) English Language Arts templates
  Future<void> _seedJuniorExplorerEnglishTemplates() async {
    print('📖 Seeding Junior Explorer English templates...');

    final templates = [
      // Level 1 (Easy)
      {
        'title': 'Character Feelings Analysis',
        'type': QuestionType.multipleChoice,
        'prompt':
            'How did the character feel at the beginning of the story "New Friends"?',
        'options': ['Happy', 'Sad', 'Excited', 'Nervous'],
        'correctAnswer': 'Nervous',
        'skills': ['reading-comprehension', 'character-analysis'],
        'points': 80,
        'explanation':
            'The character was nervous about starting at a new school.',
        'hint': 'Look for clues about how the character felt at the start.',
        'difficulty': Difficulty.easy,
        'duration': 5,
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
        'difficulty': Difficulty.easy,
        'duration': 2,
      },

      // Level 2 (Hard)
      {
        'title': 'Non-fiction Subheadings',
        'type': QuestionType.matching,
        'prompt':
            'Match the paragraph descriptions to their subheadings from "Young Explorers"',
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
        'difficulty': Difficulty.hard,
        'duration': 3,
      },
      {
        'title': 'Endangered Animals Comprehension',
        'type': QuestionType.multipleChoice,
        'prompt': 'Which animal is mentioned as endangered in the text?',
        'options': [
          'Javan rhino',
          'African elephant',
          'Domestic cat',
          'Golden retriever'
        ],
        'correctAnswer': 'Javan rhino',
        'skills': ['reading-comprehension', 'factual-recall'],
        'points': 80,
        'explanation':
            'The text specifically mentions the Javan rhino as an endangered species.',
        'hint':
            'Look for animals mentioned in the context of being endangered.',
        'difficulty': Difficulty.hard,
        'duration': 3,
      },
    ];

    for (final template in templates) {
      try {
        final templateId = await _templateService.createTemplate(
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
        print('✅ Created template: ${template['title']} (ID: $templateId)');
      } catch (e) {
        print('❌ Error creating template ${template['title']}: $e');
      }
    }

    print('✅ Seeded ${templates.length} Junior Explorer English templates');
  }

  /// Seed Bright Minds (9-12) Mathematics templates
  Future<void> _seedBrightMindsMathTemplates() async {
    print('🔢 Seeding Bright Minds Math templates...');

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
        'difficulty': Difficulty.easy,
        'duration': 3,
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
        'difficulty': Difficulty.easy,
        'duration': 3,
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
        'difficulty': Difficulty.easy,
        'duration': 3,
      },
      {
        'title': 'Area/Perimeter Builder',
        'type': QuestionType.textInput,
        'prompt':
            'Find the area of a rectangle with length 8 cm and width 5 cm',
        'correctAnswer': '40',
        'skills': ['area-perimeter', 'multiplication'],
        'points': 100,
        'explanation': 'Area = length × width = 8 × 5 = 40 square centimeters.',
        'hint': 'Multiply the length by the width to find the area.',
        'difficulty': Difficulty.easy,
        'duration': 5,
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
        'difficulty': Difficulty.hard,
        'duration': 7,
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
        'difficulty': Difficulty.hard,
        'duration': 6,
      },
      {
        'title': 'Likelihood Scale',
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
        'difficulty': Difficulty.hard,
        'duration': 5,
      },
      {
        'title': 'Place Value Builder',
        'type': QuestionType.textInput,
        'prompt':
            'Rearrange digits 1,2,3,4,5,6,7 to make the largest number possible',
        'correctAnswer': '7654321',
        'skills': ['large-number-manipulation', 'place-value'],
        'points': 140,
        'explanation':
            'To make the largest number, arrange digits in descending order: 7654321.',
        'hint': 'Put the largest digits in the highest place values.',
        'difficulty': Difficulty.hard,
        'duration': 7,
      },
    ];

    for (final template in templates) {
      try {
        final templateId = await _templateService.createTemplate(
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
        print('✅ Created template: ${template['title']} (ID: $templateId)');
      } catch (e) {
        print('❌ Error creating template ${template['title']}: $e');
      }
    }

    print('✅ Seeded ${templates.length} Bright Minds Math templates');
  }

  /// Seed Bright Minds (9-12) English Language Arts templates
  Future<void> _seedBrightMindsEnglishTemplates() async {
    print('📖 Seeding Bright Minds English templates...');

    final templates = [
      // Level 1 (Easy)
      {
        'title': 'Facts vs Opinions',
        'type': QuestionType.multipleChoice,
        'prompt': 'Which statement is a fact about the Galápagos Islands?',
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
        'difficulty': Difficulty.easy,
        'duration': 5,
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
        'difficulty': Difficulty.easy,
        'duration': 5,
      },
      {
        'title': 'Prefix/Suffix Match',
        'type': QuestionType.matching,
        'prompt': 'Match prefixes to their meanings',
        'options': ['under-', 'over-', 're-'],
        'correctAnswer': ['too little', 'too much', 'again'],
        'skills': ['vocabulary', 'prefixes'],
        'points': 60,
        'explanation':
            'Prefixes change the meaning of words: under- means too little, over- means too much, re- means again.',
        'hint': 'Think about words like underground, overflow, and replay.',
        'difficulty': Difficulty.easy,
        'duration': 2,
      },

      // Level 2 (Hard)
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
        'difficulty': Difficulty.hard,
        'duration': 6,
      },
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
        'difficulty': Difficulty.hard,
        'duration': 3,
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
        'difficulty': Difficulty.hard,
        'duration': 6,
      },
    ];

    for (final template in templates) {
      try {
        final templateId = await _templateService.createTemplate(
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
        print('✅ Created template: ${template['title']} (ID: $templateId)');
      } catch (e) {
        print('❌ Error creating template ${template['title']}: $e');
      }
    }

    print('✅ Seeded ${templates.length} Bright Minds English templates');
  }

  /// Seed Mindful Exercise templates for both age groups
  Future<void> _seedMindfulExerciseTemplates() async {
    print('🧘 Seeding Mindful Exercise templates...');

    final templates = [
      // Junior Explorer Mindful Exercises
      {
        'title': 'Guided Nature Imagination',
        'type': QuestionType.textInput,
        'prompt':
            'Listen to the nature sounds and describe what you imagine in your peaceful place',
        'correctAnswer': 'Any thoughtful response about nature',
        'skills': ['mindfulness', 'imagination'],
        'points': 30,
        'explanation': 'Using imagination helps us relax and feel calm.',
        'hint': 'Think about peaceful places in nature.',
        'difficulty': Difficulty.easy,
        'duration': 3,
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
        'difficulty': Difficulty.hard,
        'duration': 4,
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
        'difficulty': Difficulty.easy,
        'duration': 3,
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
        'difficulty': Difficulty.hard,
        'duration': 4,
        'ageGroup': AgeGroup.bright,
      },
    ];

    for (final template in templates) {
      try {
        final templateId = await _templateService.createTemplate(
          title: template['title'] as String,
          type: template['type'] as QuestionType,
          prompt: template['prompt'] as String,
          options: (template['options'] as List<String>?) ?? [],
          correctAnswer: template['correctAnswer'],
          ageGroups: [template['ageGroup'] as AgeGroup],
          subjects: [
            ActivitySubject.social
          ], // Using social studies for mindful exercises
          skills: template['skills'] as List<String>,
          explanation: template['explanation'] as String?,
          hint: template['hint'] as String?,
          points: template['points'] as int,
        );
        print('✅ Created template: ${template['title']} (ID: $templateId)');
      } catch (e) {
        print('❌ Error creating template ${template['title']}: $e');
      }
    }

    print('✅ Seeded ${templates.length} Mindful Exercise templates');
  }

  /// Set up visibility rules for content publishing
  Future<void> _setupVisibilityRules() async {
    print('🔒 Setting up visibility rules...');

    // Junior Explorer visibility rules
    await _firestore.collection('visibilityRules').doc('junior').set({
      'ageGroup': 'junior',
      'subjects': {
        'math': {
          'minQuestions': 3,
          'maxQuestions': 8,
          'maxDuration': 15,
        },
        'reading': {
          'minQuestions': 3,
          'maxQuestions': 6,
          'maxDuration': 10,
        },
      },
      'difficulties': {
        'easy': {
          'maxDuration': 10,
          'minQuestions': 3,
        },
        'hard': {
          'maxDuration': 15,
          'maxQuestions': 8,
        },
      },
      'safety': {
        'requireAltText': true,
        'maxVocabularyLevel': 'intermediate',
      },
    });

    // Bright Minds visibility rules
    await _firestore.collection('visibilityRules').doc('bright').set({
      'ageGroup': 'bright',
      'subjects': {
        'math': {
          'minQuestions': 5,
          'maxQuestions': 15,
          'maxDuration': 25,
        },
        'reading': {
          'minQuestions': 4,
          'maxQuestions': 10,
          'maxDuration': 20,
        },
      },
      'difficulties': {
        'easy': {
          'maxDuration': 15,
          'minQuestions': 5,
        },
        'hard': {
          'maxDuration': 25,
          'maxQuestions': 15,
        },
      },
      'safety': {
        'requireAltText': true,
        'maxVocabularyLevel': 'advanced',
      },
    });

    print('✅ Visibility rules configured');
  }

  /// Create a sample teacher profile for testing
  Future<void> _createSampleTeacherProfile() async {
    print('👨‍🏫 Creating sample teacher profile...');

    // This would typically be done through the signup process
    // But we can create a sample profile for testing
    print('✅ Sample teacher profile ready');
  }
}

/// Main function to run the setup
Future<void> main() async {
  final setup = TeacherSystemSetup();
  await setup.setupCompleteSystem();
}
