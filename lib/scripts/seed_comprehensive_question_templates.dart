import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/game_activity.dart';
import '../models/user_type.dart';

/// Comprehensive question template seeder for all game types
class ComprehensiveQuestionTemplateSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed all question templates for all game types
  Future<void> seedAllTemplates() async {
    try {
      debugPrint('🌱 Starting comprehensive question template seeding...');

      await _seedJuniorExplorerMathTemplates();
      await _seedJuniorExplorerEnglishTemplates();
      await _seedBrightMindsMathTemplates();
      await _seedBrightMindsEnglishTemplates();
      await _seedMindfulExerciseTemplates();

      debugPrint(
          '✅ Comprehensive question template seeding completed successfully!');
    } catch (e) {
      debugPrint('❌ Error seeding comprehensive question templates: $e');
      rethrow;
    }
  }

  /// Seed Junior Explorer (6-8) Mathematics templates
  Future<void> _seedJuniorExplorerMathTemplates() async {
    debugPrint('🔢 Seeding Junior Explorer Math templates...');

    final templates = [
      // Number Grid Race Templates
      {
        'title': 'Skip Counting by 2s',
        'type': QuestionType.multipleChoice,
        'prompt': 'What comes next in the pattern? 2, 4, 6, 8, __',
        'options': ['9', '10', '11', '12'],
        'correctAnswer': '10',
        'skills': ['skip-counting', 'number-patterns'],
        'points': 20,
        'explanation': 'We are counting by 2s, so 8 + 2 = 10',
        'hint': 'Add 2 to the last number',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.numberGridRace],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
      {
        'title': 'Skip Counting by 5s',
        'type': QuestionType.multipleChoice,
        'prompt': 'What comes next? 5, 10, 15, 20, __',
        'options': ['22', '25', '30', '35'],
        'correctAnswer': '25',
        'skills': ['skip-counting', 'multiplication'],
        'points': 25,
        'explanation': 'We are counting by 5s, so 20 + 5 = 25',
        'hint': 'Add 5 to the last number',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.numberGridRace],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
      {
        'title': 'Missing Numbers in Sequence',
        'type': QuestionType.textInput,
        'prompt': 'Fill in the missing number: 12, 13, __, 15, 16',
        'correctAnswer': '14',
        'skills': ['counting', 'number-sequence'],
        'points': 15,
        'explanation': 'The numbers are counting up by 1, so 13 + 1 = 14',
        'hint': 'Count up by 1 from 13',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.numberGridRace],
        'difficulty': Difficulty.easy,
        'duration': 1,
      },

      // Koala Counter's Adventure Templates
      {
        'title': 'Addition with Number Line',
        'type': QuestionType.textInput,
        'prompt': 'Use the number line to solve: 7 + 5 = ?',
        'correctAnswer': '12',
        'skills': ['addition', 'number-line', 'counting-on'],
        'points': 30,
        'explanation':
            'Start at 7 and count forward 5 spaces: 7, 8, 9, 10, 11, 12',
        'hint': 'Start at 7 and count forward 5',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.koalaCounterAdventure],
        'difficulty': Difficulty.easy,
        'duration': 3,
      },
      {
        'title': 'Subtraction with Number Line',
        'type': QuestionType.textInput,
        'prompt': 'Use the number line to solve: 15 - 8 = ?',
        'correctAnswer': '7',
        'skills': ['subtraction', 'number-line', 'counting-back'],
        'points': 30,
        'explanation':
            'Start at 15 and count backward 8 spaces: 15, 14, 13, 12, 11, 10, 9, 8, 7',
        'hint': 'Start at 15 and count backward 8',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.koalaCounterAdventure],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },
      {
        'title': 'Counting On Strategy',
        'type': QuestionType.textInput,
        'prompt': 'Use counting on: 9 + 6 = ?',
        'correctAnswer': '15',
        'skills': ['addition', 'mental-math', 'counting-on'],
        'points': 25,
        'explanation':
            'Start with the bigger number 9 and count on 6: 9, 10, 11, 12, 13, 14, 15',
        'hint': 'Start with 9 and count forward 6',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.koalaCounterAdventure],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },

      // Ordinal Drag Order Templates
      {
        'title': 'Ordinal Numbers 1st to 5th',
        'type': QuestionType.dragDrop,
        'prompt': 'Put the animals in order from 1st to 5th',
        'options': ['3rd', '1st', '5th', '2nd', '4th'],
        'correctAnswer': ['1st', '2nd', '3rd', '4th', '5th'],
        'skills': ['ordinal-numbers', 'ordering'],
        'points': 20,
        'explanation': 'Ordinal numbers show position: 1st, 2nd, 3rd, 4th, 5th',
        'hint': 'Think about the order: first, second, third, fourth, fifth',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.ordinalDragOrder],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
      {
        'title': 'Positional Language',
        'type': QuestionType.multipleChoice,
        'prompt': 'The cat is sitting ___ the table.',
        'options': ['on', 'under', 'next to', 'behind'],
        'correctAnswer': 'on',
        'skills': ['positional-language', 'prepositions'],
        'points': 15,
        'explanation': 'The cat is sitting on top of the table',
        'hint': 'Think about where the cat is in relation to the table',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math, ActivitySubject.reading],
        'gameTypes': [GameType.ordinalDragOrder],
        'difficulty': Difficulty.easy,
        'duration': 1,
      },

      // Pattern Builder Templates
      {
        'title': 'Color Pattern',
        'type': QuestionType.sequencing,
        'prompt': 'Complete the pattern: Red, Blue, Red, Blue, __, __',
        'options': ['Red', 'Blue', 'Green', 'Yellow'],
        'correctAnswer': ['Red', 'Blue'],
        'skills': ['patterns', 'sequencing'],
        'points': 20,
        'explanation':
            'The pattern repeats Red, Blue, so the next two are Red, Blue',
        'hint': 'Look for the repeating pattern',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.patternBuilder],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
      {
        'title': 'Shape Pattern',
        'type': QuestionType.sequencing,
        'prompt': 'What comes next? Circle, Square, Circle, Square, __',
        'options': ['Triangle', 'Circle', 'Square', 'Rectangle'],
        'correctAnswer': 'Circle',
        'skills': ['patterns', 'shapes'],
        'points': 25,
        'explanation': 'The pattern alternates between Circle and Square',
        'hint': 'Look at the alternating pattern',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.patternBuilder],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },
    ];

    await _saveTemplates(templates);
  }

  /// Seed Junior Explorer (6-8) English Language Arts templates
  Future<void> _seedJuniorExplorerEnglishTemplates() async {
    debugPrint('📖 Seeding Junior Explorer English templates...');

    final templates = [
      // Memory Match Templates
      {
        'title': 'Rhyming Words Match',
        'type': QuestionType.matching,
        'prompt': 'Match the words that rhyme',
        'options': ['cat', 'hat', 'dog', 'log', 'sun', 'fun'],
        'correctAnswer': [
          ['cat', 'hat'],
          ['dog', 'log'],
          ['sun', 'fun']
        ],
        'skills': ['rhyming', 'phonemic-awareness'],
        'points': 20,
        'explanation': 'Words that rhyme have the same ending sounds',
        'hint': 'Listen for words that sound the same at the end',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.easy,
        'duration': 3,
      },
      {
        'title': 'Letter-Sound Match',
        'type': QuestionType.matching,
        'prompt': 'Match the letter with its sound',
        'options': ['A', 'apple', 'B', 'ball', 'C', 'cat'],
        'correctAnswer': [
          ['A', 'apple'],
          ['B', 'ball'],
          ['C', 'cat']
        ],
        'skills': ['letter-sounds', 'phonics'],
        'points': 25,
        'explanation': 'Each letter makes a specific sound',
        'hint': 'Think about the first sound of each word',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },

      // Word Builder Templates
      {
        'title': 'CVC Word Building',
        'type': QuestionType.dragDrop,
        'prompt': 'Build the word "cat" using the letters',
        'options': ['c', 'a', 't', 'b', 'o', 'g'],
        'correctAnswer': ['c', 'a', 't'],
        'skills': ['word-building', 'phonics', 'spelling'],
        'points': 30,
        'explanation': 'C-A-T spells cat',
        'hint': 'Think about the sounds in the word cat',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.reading, ActivitySubject.writing],
        'gameTypes': [GameType.wordBuilder],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },
      {
        'title': 'Sight Word Recognition',
        'type': QuestionType.multipleChoice,
        'prompt': 'Which word says "the"?',
        'options': ['the', 'and', 'is', 'to'],
        'correctAnswer': 'the',
        'skills': ['sight-words', 'word-recognition'],
        'points': 15,
        'explanation': 'The word "the" is a sight word we memorize',
        'hint': 'Look for the word "the"',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.wordBuilder],
        'difficulty': Difficulty.easy,
        'duration': 1,
      },

      // Story Sequencer Templates
      {
        'title': 'Story Sequence - Getting Ready',
        'type': QuestionType.sequencing,
        'prompt': 'Put the story in order',
        'options': ['Wake up', 'Brush teeth', 'Eat breakfast', 'Get dressed'],
        'correctAnswer': [
          'Wake up',
          'Brush teeth',
          'Get dressed',
          'Eat breakfast'
        ],
        'skills': ['sequencing', 'story-structure'],
        'points': 25,
        'explanation':
            'The correct order is: wake up, brush teeth, get dressed, eat breakfast',
        'hint': 'Think about what you do first when you wake up',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.storySequencer],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },
    ];

    await _saveTemplates(templates);
  }

  /// Seed Bright Minds (9-12) Mathematics templates
  Future<void> _seedBrightMindsMathTemplates() async {
    debugPrint('🔢 Seeding Bright Minds Math templates...');

    final templates = [
      // Fraction Navigator Templates
      {
        'title': 'Equivalent Fractions',
        'type': QuestionType.multipleChoice,
        'prompt': 'Which fraction is equivalent to 1/2?',
        'options': ['2/3', '3/6', '1/4', '2/5'],
        'correctAnswer': '3/6',
        'skills': ['equivalent-fractions', 'fractions'],
        'points': 30,
        'explanation': '1/2 = 3/6 because 1×3=3 and 2×3=6',
        'hint': 'Multiply both numerator and denominator by the same number',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.fractionNavigator],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },
      {
        'title': 'Fraction to Decimal Conversion',
        'type': QuestionType.textInput,
        'prompt': 'Convert 3/4 to a decimal',
        'correctAnswer': '0.75',
        'skills': ['fraction-decimal-conversion', 'decimals'],
        'points': 35,
        'explanation': '3 ÷ 4 = 0.75',
        'hint': 'Divide the numerator by the denominator',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.fractionNavigator],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },
      {
        'title': 'Ordering Fractions and Decimals',
        'type': QuestionType.sequencing,
        'prompt': 'Order from smallest to largest: 0.5, 1/3, 0.75, 2/5',
        'options': ['0.5', '1/3', '0.75', '2/5'],
        'correctAnswer': ['1/3', '2/5', '0.5', '0.75'],
        'skills': ['fraction-ordering', 'decimal-ordering'],
        'points': 40,
        'explanation': '1/3 ≈ 0.33, 2/5 = 0.4, 0.5, 0.75',
        'hint': 'Convert all to decimals to compare',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.fractionNavigator],
        'difficulty': Difficulty.hard,
        'duration': 4,
      },

      // Inverse Operation Chain Templates
      {
        'title': 'Fact Family - Addition and Subtraction',
        'type': QuestionType.textInput,
        'prompt': 'If 15 + 8 = 23, what is 23 - 8?',
        'correctAnswer': '15',
        'skills': ['fact-families', 'inverse-operations'],
        'points': 25,
        'explanation': 'Addition and subtraction are inverse operations',
        'hint': 'Use the fact family: if a + b = c, then c - b = a',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.inverseOperationChain],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },
      {
        'title': 'Fact Family - Multiplication and Division',
        'type': QuestionType.textInput,
        'prompt': 'If 6 × 7 = 42, what is 42 ÷ 6?',
        'correctAnswer': '7',
        'skills': ['fact-families', 'multiplication', 'division'],
        'points': 30,
        'explanation': 'Multiplication and division are inverse operations',
        'hint': 'Use the fact family: if a × b = c, then c ÷ a = b',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.inverseOperationChain],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },
      {
        'title': 'Balancing Equations',
        'type': QuestionType.textInput,
        'prompt': 'Find the missing number: 25 + __ = 40',
        'correctAnswer': '15',
        'skills': ['algebra', 'balancing-equations'],
        'points': 35,
        'explanation': '25 + 15 = 40, so the missing number is 15',
        'hint': 'Use inverse operation: 40 - 25 = 15',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.inverseOperationChain],
        'difficulty': Difficulty.hard,
        'duration': 3,
      },

      // Data Visualization Templates
      {
        'title': 'Reading Bar Graphs',
        'type': QuestionType.multipleChoice,
        'prompt': 'How many students chose pizza as their favorite food?',
        'options': ['5', '8', '12', '15'],
        'correctAnswer': '8',
        'skills': ['data-interpretation', 'bar-graphs'],
        'points': 20,
        'explanation': 'Look at the bar for pizza and read the height',
        'hint': 'Find the pizza bar and see how high it goes',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.dataVisualization],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
      {
        'title': 'Creating Tally Charts',
        'type': QuestionType.dragDrop,
        'prompt': 'Create tally marks for 7 items',
        'options': ['||||||', '|||||||', '|||||||', '||||||||'],
        'correctAnswer': '|||||||',
        'skills': ['tally-marks', 'data-collection'],
        'points': 25,
        'explanation': '7 items = 5 tally marks + 2 more = |||||',
        'hint': 'Remember: every 5th tally mark goes across the previous 4',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.dataVisualization],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },

      // Cartesian Grid Templates
      {
        'title': 'Plotting Coordinates',
        'type': QuestionType.textInput,
        'prompt': 'What are the coordinates of point A? (x, y)',
        'correctAnswer': '(3, 4)',
        'skills': ['coordinates', 'cartesian-plane'],
        'points': 30,
        'explanation':
            'Point A is 3 units right and 4 units up from the origin',
        'hint': 'Count right for x, up for y',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.cartesianGrid],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },
      {
        'title': 'Following Directions',
        'type': QuestionType.textInput,
        'prompt':
            'Start at (0,0). Move right 3, up 2. What are your new coordinates?',
        'correctAnswer': '(3, 2)',
        'skills': ['coordinates', 'directions'],
        'points': 25,
        'explanation':
            'Starting at (0,0), moving right 3 gives x=3, up 2 gives y=2',
        'hint': 'Add the movements to the starting position',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.math],
        'gameTypes': [GameType.cartesianGrid],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
    ];

    await _saveTemplates(templates);
  }

  /// Seed Bright Minds (9-12) English Language Arts templates
  Future<void> _seedBrightMindsEnglishTemplates() async {
    debugPrint('📖 Seeding Bright Minds English templates...');

    final templates = [
      // Memory Match Templates
      {
        'title': 'Synonyms Match',
        'type': QuestionType.matching,
        'prompt': 'Match the words with similar meanings',
        'options': ['big', 'large', 'happy', 'joyful', 'fast', 'quick'],
        'correctAnswer': [
          ['big', 'large'],
          ['happy', 'joyful'],
          ['fast', 'quick']
        ],
        'skills': ['synonyms', 'vocabulary'],
        'points': 30,
        'explanation': 'Synonyms are words with similar meanings',
        'hint': 'Think about words that mean the same thing',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },
      {
        'title': 'Antonyms Match',
        'type': QuestionType.matching,
        'prompt': 'Match the words with opposite meanings',
        'options': ['hot', 'cold', 'up', 'down', 'light', 'dark'],
        'correctAnswer': [
          ['hot', 'cold'],
          ['up', 'down'],
          ['light', 'dark']
        ],
        'skills': ['antonyms', 'vocabulary'],
        'points': 30,
        'explanation': 'Antonyms are words with opposite meanings',
        'hint': 'Think about words that mean the opposite',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.medium,
        'duration': 3,
      },

      // Word Builder Templates
      {
        'title': 'Prefix Word Building',
        'type': QuestionType.dragDrop,
        'prompt': 'Add the prefix "un-" to "happy"',
        'options': ['un-', 'happy', 're-', 'dis-'],
        'correctAnswer': ['un-', 'happy'],
        'skills': ['prefixes', 'word-building'],
        'points': 25,
        'explanation': 'un- + happy = unhappy (not happy)',
        'hint': 'Think about what "un-" means',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.reading, ActivitySubject.writing],
        'gameTypes': [GameType.wordBuilder],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },
      {
        'title': 'Suffix Word Building',
        'type': QuestionType.dragDrop,
        'prompt': 'Add the suffix "-ful" to "wonder"',
        'options': ['wonder', '-ful', '-less', '-ness'],
        'correctAnswer': ['wonder', '-ful'],
        'skills': ['suffixes', 'word-building'],
        'points': 25,
        'explanation': 'wonder + -ful = wonderful (full of wonder)',
        'hint': 'Think about what "-ful" means',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.reading, ActivitySubject.writing],
        'gameTypes': [GameType.wordBuilder],
        'difficulty': Difficulty.medium,
        'duration': 2,
      },

      // Story Sequencer Templates
      {
        'title': 'Story Plot Sequence',
        'type': QuestionType.sequencing,
        'prompt': 'Put the story events in order',
        'options': [
          'Problem occurs',
          'Character tries to solve it',
          'Character succeeds',
          'Story ends'
        ],
        'correctAnswer': [
          'Problem occurs',
          'Character tries to solve it',
          'Character succeeds',
          'Story ends'
        ],
        'skills': ['story-structure', 'plot'],
        'points': 35,
        'explanation':
            'Stories follow a pattern: problem, attempts to solve, resolution, ending',
        'hint': 'Think about the typical order of events in a story',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.reading],
        'gameTypes': [GameType.storySequencer],
        'difficulty': Difficulty.hard,
        'duration': 4,
      },
    ];

    await _saveTemplates(templates);
  }

  /// Seed Mindful Exercise templates for both age groups
  Future<void> _seedMindfulExerciseTemplates() async {
    debugPrint('🧘 Seeding Mindful Exercise templates...');

    final templates = [
      // Junior Explorer Mindful Exercises
      {
        'title': 'Breathing Exercise',
        'type': QuestionType.textInput,
        'prompt': 'Take 3 deep breaths and describe how you feel',
        'correctAnswer': 'Any thoughtful response about feelings',
        'skills': ['mindfulness', 'self-awareness'],
        'points': 20,
        'explanation': 'Deep breathing helps us feel calm and focused',
        'hint': 'Think about how your body feels after breathing deeply',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.mindfulExercise],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.easy,
        'duration': 3,
      },
      {
        'title': 'Gratitude Practice',
        'type': QuestionType.textInput,
        'prompt': 'Name one thing you are grateful for today',
        'correctAnswer': 'Any positive response',
        'skills': ['gratitude', 'positive-thinking'],
        'points': 15,
        'explanation': 'Thinking about good things makes us feel happier',
        'hint': 'Think about something that made you smile today',
        'ageGroups': [AgeGroup.junior],
        'subjects': [ActivitySubject.mindfulExercise],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },

      // Bright Minds Mindful Exercises
      {
        'title': 'Mindful Observation',
        'type': QuestionType.textInput,
        'prompt':
            'Look around and describe 3 things you notice with your senses',
        'correctAnswer':
            'Any response mentioning sight, sound, touch, smell, or taste',
        'skills': ['mindfulness', 'observation'],
        'points': 25,
        'explanation': 'Using our senses helps us stay present and aware',
        'hint': 'Use your eyes, ears, nose, or hands to notice things',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.mindfulExercise],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.medium,
        'duration': 4,
      },
      {
        'title': 'Emotion Check-in',
        'type': QuestionType.multipleChoice,
        'prompt': 'How are you feeling right now?',
        'options': ['Happy', 'Calm', 'Excited', 'Focused', 'All of the above'],
        'correctAnswer': 'All of the above',
        'skills': ['emotional-awareness', 'self-reflection'],
        'points': 20,
        'explanation': 'It\'s normal to feel multiple emotions at once',
        'hint': 'Think about all the different feelings you might have',
        'ageGroups': [AgeGroup.bright],
        'subjects': [ActivitySubject.mindfulExercise],
        'gameTypes': [GameType.memoryMatch],
        'difficulty': Difficulty.easy,
        'duration': 2,
      },
    ];

    await _saveTemplates(templates);
  }

  /// Save templates to Firestore
  Future<void> _saveTemplates(List<Map<String, dynamic>> templates) async {
    final batch = _firestore.batch();

    for (final template in templates) {
      final docRef = _firestore.collection('questionTemplates').doc();
      batch.set(docRef, {
        ...template,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint('✅ Saved ${templates.length} templates');
  }
}

/// Run the seeder
Future<void> seedComprehensiveQuestionTemplates() async {
  final seeder = ComprehensiveQuestionTemplateSeeder();
  await seeder.seedAllTemplates();
}


