import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to populate question templates collection with structured data
/// Designed for optimal game building, tracking, and child engagement
class QuestionTemplatePopulator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// New collection for structured curriculum question templates
  /// Separated from the old questionTemplates collection for better organization
  static const String collectionName = 'curriculumQuestionTemplates';

  /// Populate English questions for Junior and Bright age groups
  Future<void> populateEnglishQuestions() async {
    try {
      debugPrint('🚀 Starting English questions population...');

      final juniorQuestions = _createJuniorEnglishQuestions();
      final brightQuestions = _createBrightEnglishQuestions();

      final batch = _firestore.batch();
      int count = 0;

      // Add Junior questions
      for (final question in juniorQuestions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      // Add Bright questions
      for (final question in brightQuestions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      await batch.commit();
      debugPrint('✅ Successfully populated $count English question templates!');
    } catch (e) {
      debugPrint('❌ Error populating English questions: $e');
      rethrow;
    }
  }

  /// Populate Science questions for Junior and Bright age groups
  Future<void> populateScienceQuestions() async {
    try {
      debugPrint('🚀 Starting Science questions population...');

      final juniorQuestions = _createJuniorScienceQuestions();
      final brightQuestions = _createBrightScienceQuestions();

      final batch = _firestore.batch();
      int count = 0;

      // Add Junior questions
      for (final question in juniorQuestions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      // Add Bright questions
      for (final question in brightQuestions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      await batch.commit();
      debugPrint('✅ Successfully populated $count Science question templates!');
    } catch (e) {
      debugPrint('❌ Error populating Science questions: $e');
      rethrow;
    }
  }

  /// Populate Math questions for Junior and Bright age groups
  /// Includes proper game type mapping, points, and tracking metadata
  Future<void> populateMathQuestions() async {
    try {
      debugPrint('🚀 Starting Math questions population...');

      final juniorQuestions = _createJuniorMathQuestions();
      final brightQuestions = _createBrightMathQuestions();

      final batch = _firestore.batch();
      int count = 0;

      // Add Junior questions
      for (final question in juniorQuestions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      // Add Bright questions
      for (final question in brightQuestions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      await batch.commit();
      debugPrint('✅ Successfully populated $count Math question templates!');
    } catch (e) {
      debugPrint('❌ Error populating Math questions: $e');
      rethrow;
    }
  }

  /// Create Junior (6-8) Math questions with proper structure
  List<Map<String, dynamic>> _createJuniorMathQuestions() {
    return [
      // Question 1: Number/Counting
      {
        'id': 'math_junior_001_counting_subtraction',
        'title': 'Counting and Subtraction',
        'type': 'multipleChoice',
        'prompt':
            'When counting back, what word is another way of saying "take away"?',
        'options': ['Addition', 'Subtraction', 'Multiplication', 'Division'],
        'correctAnswer': 'Subtraction',
        'explanation': 'Subtraction means taking away or removing something.',
        'hint': 'Think about what you do when you "take away" items.',
        'points': 15,
        'skills': ['counting', 'subtraction', 'vocabulary'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Counting'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['numberGridRace', 'koalaCounterAdventure'],
        'recommendedGameType': 'numberGridRace',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K',
          'learningObjective': 'Understand subtraction vocabulary',
          'prerequisiteSkills': [],
          'followUpSkills': ['subtraction-operations'],
        },
      },

      // Question 2: Place Value
      {
        'id': 'math_junior_002_place_value_tens',
        'title': 'Place Value - Tens',
        'type': 'multipleChoice',
        'prompt': 'In the number 37, the \'3\' represents how many tens?',
        'options': ['3', '30', '7', '37'],
        'correctAnswer': '3',
        'explanation':
            'In the number 37, the digit 3 is in the tens place, which means 3 tens (30).',
        'hint': 'Count by tens: 10, 20, 30...',
        'points': 20,
        'skills': ['place-value', 'number-recognition'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Place Value'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 45,
        'gameTypes': ['numberGridRace'],
        'recommendedGameType': 'numberGridRace',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Identify place value in two-digit numbers',
          'prerequisiteSkills': ['counting-to-100'],
          'followUpSkills': ['hundreds-place'],
        },
      },

      // Question 3: Addition
      {
        'id': 'math_junior_003_addition_basic',
        'title': 'Basic Addition',
        'type': 'multipleChoice',
        'prompt':
            'If you have 4 cookies and you get 2 more, how many do you have altogether?',
        'options': ['5', '6', '7', '8'],
        'correctAnswer': '6',
        'explanation': '4 cookies + 2 cookies = 6 cookies altogether.',
        'hint': 'Count: 4, then add 2 more. How many is that?',
        'points': 15,
        'skills': ['addition', 'counting'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Addition'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 25,
        'gameTypes': ['fishTankQuiz', 'koalaCounterAdventure'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K',
          'learningObjective': 'Add single-digit numbers',
          'prerequisiteSkills': ['counting-to-10'],
          'followUpSkills': ['addition-to-20'],
        },
      },

      // Question 4: Subtraction
      {
        'id': 'math_junior_004_subtraction_basic',
        'title': 'Basic Subtraction',
        'type': 'multipleChoice',
        'prompt': 'What is 17 take away 5?',
        'options': ['11', '12', '13', '14'],
        'correctAnswer': '12',
        'explanation': '17 - 5 = 12. Taking away 5 from 17 leaves 12.',
        'hint': 'Start at 17 and count back 5.',
        'points': 20,
        'skills': ['subtraction', 'number-operations'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Subtraction'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['fishTankQuiz', 'koalaCounterAdventure'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Subtract single-digit from two-digit numbers',
          'prerequisiteSkills': ['counting-to-20'],
          'followUpSkills': ['subtraction-with-borrowing'],
        },
      },

      // Question 5: Division/Sharing
      {
        'id': 'math_junior_005_division_sharing',
        'title': 'Division as Sharing',
        'type': 'multipleChoice',
        'prompt':
            'If 12 items are shared equally between 3 people, how many does each person get?',
        'options': ['3', '4', '5', '6'],
        'correctAnswer': '4',
        'explanation':
            '12 items ÷ 3 people = 4 items per person. Each person gets 4 items.',
        'hint': 'Share 12 items into 3 equal groups. How many in each group?',
        'points': 25,
        'skills': ['division', 'sharing', 'equal-groups'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Division', 'Sharing'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['numberGridRace', 'patternBuilder'],
        'recommendedGameType': 'numberGridRace',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Understand division as equal sharing',
          'prerequisiteSkills': ['counting', 'grouping'],
          'followUpSkills': ['division-facts'],
        },
      },

      // Question 6: Fractions - Half
      {
        'id': 'math_junior_006_fractions_half',
        'title': 'Understanding Half',
        'type': 'multipleChoice',
        'prompt':
            'If you cut a whole apple into two pieces of the same size, what is each piece called?',
        'options': ['Whole', 'Half', 'Quarter', 'Third'],
        'correctAnswer': 'Half',
        'explanation':
            'When you divide something into 2 equal parts, each part is called a half (½).',
        'hint': 'Two equal parts means each is half of the whole.',
        'points': 20,
        'skills': ['fractions', 'equal-parts'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Fractions'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['patternBuilder', 'memoryMatch'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Understand the concept of half',
          'prerequisiteSkills': ['counting', 'equal-parts'],
          'followUpSkills': ['quarters', 'thirds'],
        },
      },

      // Question 7: Fractions - Quarters
      {
        'id': 'math_junior_007_fractions_quarters',
        'title': 'Quarters Make a Whole',
        'type': 'multipleChoice',
        'prompt': 'How many quarters are needed to make one whole?',
        'options': ['2', '3', '4', '5'],
        'correctAnswer': '4',
        'explanation':
            'Four quarters (¼ + ¼ + ¼ + ¼) make one whole. Each quarter is one-fourth.',
        'hint':
            'Think of a pizza cut into 4 equal slices. How many slices make the whole pizza?',
        'points': 25,
        'skills': ['fractions', 'quarters'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Fractions'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['patternBuilder', 'ordinalDragOrder'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Understand that 4 quarters make a whole',
          'prerequisiteSkills': ['half'],
          'followUpSkills': ['comparing-fractions'],
        },
      },

      // Question 8: Data Handling
      {
        'id': 'math_junior_008_data_handling',
        'title': 'Understanding Data',
        'type': 'multipleChoice',
        'prompt':
            'When creating a pictograph, what does the word \'data\' mean?',
        'options': ['Pictures', 'Information', 'Numbers', 'Colors'],
        'correctAnswer': 'Information',
        'explanation':
            'Data means information or facts that we collect and organize, like counting how many of something.',
        'hint': 'Data helps us learn and make decisions.',
        'points': 15,
        'skills': ['data-handling', 'vocabulary'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Data Handling'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 25,
        'gameTypes': ['fishTankQuiz'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K',
          'learningObjective': 'Understand the concept of data',
          'prerequisiteSkills': [],
          'followUpSkills': ['collecting-data'],
        },
      },

      // Question 9: Measurement - Length
      {
        'id': 'math_junior_009_measurement_length',
        'title': 'Measuring Length',
        'type': 'multipleChoice',
        'prompt':
            'If you are measuring a book, what must you do with the items you use (like paperclips) to measure the length?',
        'options': [
          'Stack them up',
          'Line them up with no gaps',
          'Put them in a circle',
          'Count them quickly'
        ],
        'correctAnswer': 'Line them up with no gaps',
        'explanation':
            'To measure accurately, you need to place the measuring items (like paperclips) in a straight line with no gaps or overlaps.',
        'hint':
            'Think about how you would line up toys or blocks to measure something.',
        'points': 20,
        'skills': ['measurement', 'length', 'accuracy'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Measurement', 'Length'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['fishTankQuiz', 'ordinalDragOrder'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K',
          'learningObjective': 'Understand proper measurement technique',
          'prerequisiteSkills': ['counting', 'ordering'],
          'followUpSkills': ['standard-units'],
        },
      },

      // Question 10: Measurement - Area
      {
        'id': 'math_junior_010_measurement_area',
        'title': 'Understanding Area',
        'type': 'multipleChoice',
        'prompt':
            'What is the name for the amount of surface an object takes up?',
        'options': ['Length', 'Width', 'Area', 'Volume'],
        'correctAnswer': 'Area',
        'explanation':
            'Area is the amount of space or surface that a shape covers. It\'s measured in square units.',
        'hint': 'Think about how much space a rug covers on the floor.',
        'points': 20,
        'skills': ['measurement', 'area', 'spatial-awareness'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Measurement', 'Area'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['patternBuilder', 'memoryMatch'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Understand the concept of area',
          'prerequisiteSkills': ['shapes'],
          'followUpSkills': ['calculating-area'],
        },
      },

      // Question 11: Shapes - Triangle
      {
        'id': 'math_junior_011_shapes_triangle',
        'title': 'Triangle Shape',
        'type': 'multipleChoice',
        'prompt': 'What is a 2D shape with three sides called?',
        'options': ['Square', 'Circle', 'Triangle', 'Rectangle'],
        'correctAnswer': 'Triangle',
        'explanation':
            'A triangle is a 2D shape with exactly three sides and three corners (vertices).',
        'hint': 'Count the sides: tri means three!',
        'points': 15,
        'skills': ['shapes', 'geometry', 'vocabulary'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Shape and Space'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 25,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K',
          'learningObjective': 'Identify triangle shape',
          'prerequisiteSkills': ['counting', 'shape-recognition'],
          'followUpSkills': ['other-shapes'],
        },
      },

      // Question 12: Comparing Numbers
      {
        'id': 'math_junior_012_comparing_numbers',
        'title': 'Comparing Numbers - Smallest',
        'type': 'multipleChoice',
        'prompt': 'Which is the smallest number in this group: 13, 67, 113?',
        'options': ['13', '67', '113', 'All are equal'],
        'correctAnswer': '13',
        'explanation':
            '13 is smaller than 67, which is smaller than 113. So 13 is the smallest.',
        'hint':
            'Compare the numbers: which one has the fewest digits or smallest value?',
        'points': 20,
        'skills': ['comparing-numbers', 'number-order'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Comparing'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['fishTankQuiz', 'numberGridRace'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Compare and identify smallest number',
          'prerequisiteSkills': ['counting', 'number-recognition'],
          'followUpSkills': ['ordering-numbers'],
        },
      },

      // Question 13: Patterns
      {
        'id': 'math_junior_013_patterns_skip_counting',
        'title': 'Number Patterns - Skip Counting',
        'type': 'textInput',
        'prompt':
            'To continue the pattern 56, 58, 60, what is the next number?',
        'options': [], // Text input question
        'correctAnswer': '62',
        'explanation':
            'The pattern is counting by 2s: 56, 58, 60, 62. Each number is 2 more than the previous.',
        'hint': 'Count by 2s: 56, 58, 60... what comes next?',
        'points': 25,
        'skills': ['patterns', 'skip-counting', 'number-sequences'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Patterns'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['patternBuilder', 'numberGridRace'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 2',
          'learningObjective': 'Continue number patterns by skip counting',
          'prerequisiteSkills': ['counting-by-2s'],
          'followUpSkills': ['complex-patterns'],
        },
      },

      // Question 14: Probability - Certain
      {
        'id': 'math_junior_014_probability_certain',
        'title': 'Probability - Certain Event',
        'type': 'multipleChoice',
        'prompt':
            'If an event is "certain" to happen, what is the probability?',
        'options': ['0', '1/2', '1', '100'],
        'correctAnswer': '1',
        'explanation':
            'If something is certain to happen, the probability is 1 (or 100%). This means it will definitely happen.',
        'hint': 'Certain means it will definitely happen - that\'s 100% or 1.',
        'points': 20,
        'skills': ['probability', 'chance', 'vocabulary'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Chance'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['memoryMatch'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 2',
          'learningObjective': 'Understand certain probability',
          'prerequisiteSkills': [],
          'followUpSkills': ['impossible', 'likely'],
        },
      },
    ];
  }

  /// Create Bright (9-12) Math questions with proper structure
  List<Map<String, dynamic>> _createBrightMathQuestions() {
    return [
      // Question 1: Divisibility
      {
        'id': 'math_bright_001_divisibility_three',
        'title': 'Divisibility by 3',
        'type': 'trueFalse',
        'prompt':
            'A number is exactly divisible by 3 if the sum of its digits is divisible by 3. Is 531 divisible by 3?',
        'options': ['True', 'False'],
        'correctAnswer': 'True',
        'explanation':
            '5 + 3 + 1 = 9. Since 9 is divisible by 3, 531 is also divisible by 3.',
        'hint': 'Add the digits: 5 + 3 + 1. Is the sum divisible by 3?',
        'points': 30,
        'skills': ['divisibility', 'number-properties'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Number', 'Divisibility'],
        'difficultyLevel': 'hard',
        'estimatedTimeSeconds': 45,
        'gameTypes': ['fractionNavigator', 'inverseOperationChain'],
        'recommendedGameType': 'fractionNavigator',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5',
          'learningObjective': 'Apply divisibility rules',
          'prerequisiteSkills': ['multiplication', 'addition'],
          'followUpSkills': ['prime-numbers'],
        },
      },

      // Question 2: Even Numbers
      {
        'id': 'math_bright_002_even_numbers',
        'title': 'Even Number Definition',
        'type': 'multipleChoice',
        'prompt':
            'What is the smallest digit that must be in the ones column of a number for it to be considered even?',
        'options': ['0', '1', '2', '4'],
        'correctAnswer': '0',
        'explanation':
            'Even numbers end in 0, 2, 4, 6, or 8. The smallest digit is 0.',
        'hint':
            'Think about even numbers: 10, 20, 30... what digit do they end in?',
        'points': 25,
        'skills': ['even-odd', 'number-properties'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Number', 'Place Value'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['fractionNavigator', 'dataVisualization'],
        'recommendedGameType': 'fractionNavigator',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 4',
          'learningObjective': 'Identify even number properties',
          'prerequisiteSkills': ['place-value'],
          'followUpSkills': ['odd-numbers'],
        },
      },

      // Question 3: Mental Math Strategies
      {
        'id': 'math_bright_003_mental_strategies',
        'title': 'Extended Number Facts',
        'type': 'multipleChoice',
        'prompt':
            'If 80 - 40 = 40, what is 800 - 400? (Using extended number facts)',
        'options': ['40', '400', '4000', '8000'],
        'correctAnswer': '400',
        'explanation':
            'If 80 - 40 = 40, then 800 - 400 = 400. Both numbers are multiplied by 10, so the answer is also multiplied by 10.',
        'hint':
            'Multiply everything by 10: 80×10 = 800, 40×10 = 400, so 40×10 = ?',
        'points': 30,
        'skills': ['mental-math', 'number-facts', 'multiplication'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Number', 'Mental Strategies'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['inverseOperationChain', 'fractionNavigator'],
        'recommendedGameType': 'inverseOperationChain',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3',
          'learningObjective':
              'Apply mental math strategies using number facts',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['larger-numbers'],
        },
      },

      // Question 4: Comparing Fractions
      {
        'id': 'math_bright_004_comparing_fractions',
        'title': 'Comparing Fractions - Largest',
        'type': 'multipleChoice',
        'prompt': 'Which fraction is the largest: 1/2, 1/4, or 1/8?',
        'options': ['1/2', '1/4', '1/8', 'They are equal'],
        'correctAnswer': '1/2',
        'explanation':
            'When the numerator is the same (all are 1), the fraction with the smallest denominator is the largest. 1/2 > 1/4 > 1/8.',
        'hint':
            'Think of a pizza: half a pizza is bigger than a quarter, which is bigger than an eighth.',
        'points': 35,
        'skills': ['fractions', 'comparing', 'number-sense'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Fractions', 'Comparison'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 45,
        'gameTypes': ['fractionNavigator'],
        'recommendedGameType': 'fractionNavigator',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3',
          'learningObjective': 'Compare fractions with same numerator',
          'prerequisiteSkills': ['fractions', 'comparison'],
          'followUpSkills': ['different-numerators'],
        },
      },

      // Question 5: Multiplication Strategies
      {
        'id': 'math_bright_005_multiplication_strategy',
        'title': 'Mental Multiplication Strategy',
        'type': 'multipleChoice',
        'prompt':
            'To multiply a number by 4, what mental strategy can you use?',
        'options': [
          'Add the number twice',
          'Double, then double again',
          'Multiply by 2, then add 2',
          'Divide by 2, then multiply by 8'
        ],
        'correctAnswer': 'Double, then double again',
        'explanation':
            'Multiplying by 4 is the same as doubling twice. For example, 6 × 4 = (6 × 2) × 2 = 12 × 2 = 24.',
        'hint':
            'Think: to get 4 times, you can double (×2), then double again (×2).',
        'points': 30,
        'skills': ['multiplication', 'mental-strategies'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Multiplication', 'Strategies'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['inverseOperationChain'],
        'recommendedGameType': 'inverseOperationChain',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3',
          'learningObjective': 'Use mental strategies for multiplication',
          'prerequisiteSkills': ['multiplication-facts'],
          'followUpSkills': ['other-strategies'],
        },
      },

      // Question 6: Division Terminology
      {
        'id': 'math_bright_006_division_terminology',
        'title': 'Division Vocabulary - Dividend',
        'type': 'multipleChoice',
        'prompt':
            'What is the number you start with (the amount being divided) in a written division problem called?',
        'options': [
          'The quotient',
          'The divisor',
          'The dividend',
          'The remainder'
        ],
        'correctAnswer': 'The dividend',
        'explanation':
            'In division, the number being divided is called the dividend. For example, in 12 ÷ 3 = 4, 12 is the dividend.',
        'hint': 'Think: dividend is what you\'re dividing (splitting up).',
        'points': 25,
        'skills': ['division', 'vocabulary'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Division'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['fractionNavigator', 'inverseOperationChain'],
        'recommendedGameType': 'inverseOperationChain',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 6',
          'learningObjective': 'Understand division terminology',
          'prerequisiteSkills': ['division'],
          'followUpSkills': ['long-division'],
        },
      },

      // Question 7: Fractions to Decimals
      {
        'id': 'math_bright_007_fractions_decimals',
        'title': 'Decimal to Fraction',
        'type': 'multipleChoice',
        'prompt': 'How is the decimal 0.1 written as a fraction?',
        'options': ['1/1', '1/10', '1/100', '10/1'],
        'correctAnswer': '1/10',
        'explanation':
            '0.1 means one-tenth, which is written as the fraction 1/10.',
        'hint': '0.1 has one digit after the decimal point, so it\'s tenths.',
        'points': 30,
        'skills': ['decimals', 'fractions', 'conversion'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Fractions', 'Decimals'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['fractionNavigator'],
        'recommendedGameType': 'fractionNavigator',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 4',
          'learningObjective': 'Convert decimals to fractions',
          'prerequisiteSkills': ['fractions', 'decimals'],
          'followUpSkills': ['percentages'],
        },
      },

      // Question 8: Percentages to Decimals
      {
        'id': 'math_bright_008_percentage_decimal',
        'title': 'Percentage to Decimal',
        'type': 'multipleChoice',
        'prompt':
            'The symbol % (per cent) means "out of a hundred." How is 50% written as a decimal?',
        'options': ['0.05', '0.5', '5.0', '50.0'],
        'correctAnswer': '0.5',
        'explanation':
            '50% means 50 out of 100, which is 50/100 = 0.5 as a decimal.',
        'hint': 'Percent means per hundred, so divide by 100.',
        'points': 30,
        'skills': ['percentages', 'decimals', 'conversion'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Percentage', 'Decimals'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['fractionNavigator'],
        'recommendedGameType': 'fractionNavigator',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Convert percentages to decimals',
          'prerequisiteSkills': ['percentages', 'decimals'],
          'followUpSkills': ['fractions-to-percentages'],
        },
      },

      // Question 9: Area Units
      {
        'id': 'math_bright_009_measurement_area_units',
        'title': 'Area Units - Square Centimeters',
        'type': 'multipleChoice',
        'prompt':
            'What is the standard abbreviation used for square centimetres?',
        'options': ['cm', 'cm²', 'sq cm', 'cm2'],
        'correctAnswer': 'cm²',
        'explanation':
            'Square centimetres is abbreviated as cm². The small "2" (superscript) means "squared" or multiplied by itself.',
        'hint':
            'The superscript 2 means squared - it\'s a small 2 above the cm.',
        'points': 25,
        'skills': ['measurement', 'area', 'units'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Measurement', 'Area'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3',
          'learningObjective': 'Understand area unit notation',
          'prerequisiteSkills': ['area'],
          'followUpSkills': ['calculating-area'],
        },
      },

      // Question 10: Capacity - Liters to Milliliters
      {
        'id': 'math_bright_010_capacity_conversion',
        'title': 'Capacity Conversion - Liters to Milliliters',
        'type': 'multipleChoice',
        'prompt': 'How many millilitres (mL) are in 1 Litre (L)?',
        'options': ['10 mL', '100 mL', '1000 mL', '10000 mL'],
        'correctAnswer': '1000 mL',
        'explanation':
            '1 litre equals 1000 millilitres. The prefix "milli" means one-thousandth, so 1000 mL = 1 L.',
        'hint': 'Think: milli means thousand, so 1 L = 1000 mL.',
        'points': 25,
        'skills': ['measurement', 'capacity', 'conversion'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Measurement', 'Capacity'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization', 'fractionNavigator'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3',
          'learningObjective': 'Convert between liters and milliliters',
          'prerequisiteSkills': ['measurement'],
          'followUpSkills': ['other-capacity-units'],
        },
      },

      // Question 11: Time - Analogue
      {
        'id': 'math_bright_011_time_analogue',
        'title': 'Analogue Clock',
        'type': 'multipleChoice',
        'prompt':
            'Which type of time uses hands and numbers on a clock face to indicate hours and minutes?',
        'options': [
          'Digital time',
          'Analogue time',
          'Military time',
          '24-hour time'
        ],
        'correctAnswer': 'Analogue time',
        'explanation':
            'Analogue time uses a clock face with hands (hour and minute hands) and numbers to show the time.',
        'hint': 'Think about a traditional clock with moving hands.',
        'points': 20,
        'skills': ['time', 'clocks'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Measurement', 'Time'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 25,
        'gameTypes': ['memoryMatch'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 2/3',
          'learningObjective': 'Identify analogue clock features',
          'prerequisiteSkills': ['time'],
          'followUpSkills': ['telling-time'],
        },
      },

      // Question 12: Geometry - Angles
      {
        'id': 'math_bright_012_geometry_angles',
        'title': 'Angle Types - Obtuse',
        'type': 'multipleChoice',
        'prompt':
            'What is the name of an angle that is larger than 90° but smaller than 180°?',
        'options': [
          'Acute angle',
          'Right angle',
          'Obtuse angle',
          'Straight angle'
        ],
        'correctAnswer': 'Obtuse angle',
        'explanation':
            'An obtuse angle is greater than 90° but less than 180°. It looks wider than a right angle.',
        'hint':
            'Obtuse means "blunt" or wide - it\'s bigger than a right angle (90°).',
        'points': 30,
        'skills': ['geometry', 'angles', 'vocabulary'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Geometry', 'Angles'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['dataVisualization', 'fractionNavigator'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3/4',
          'learningObjective': 'Identify obtuse angles',
          'prerequisiteSkills': ['angles', 'degrees'],
          'followUpSkills': ['measuring-angles'],
        },
      },

      // Question 13: Data Handling - Graphs
      {
        'id': 'math_bright_013_graphs_axes',
        'title': 'Graph Axes - Vertical Axis',
        'type': 'multipleChoice',
        'prompt': 'On a bar graph, what is the vertical axis usually called?',
        'options': ['x-axis', 'y-axis', 'z-axis', 'horizontal axis'],
        'correctAnswer': 'y-axis',
        'explanation':
            'On a bar graph (or any coordinate graph), the vertical axis is called the y-axis. It goes up and down.',
        'hint':
            'Think: y-axis goes up (vertical), x-axis goes across (horizontal).',
        'points': 25,
        'skills': ['data-handling', 'graphs', 'coordinates'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Data Handling', 'Graphs'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization', 'cartesianGrid'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 3/5',
          'learningObjective': 'Identify graph components',
          'prerequisiteSkills': ['graphs'],
          'followUpSkills': ['plotting-points'],
        },
      },

      // Question 14: Probability - Percentage
      {
        'id': 'math_bright_014_probability_percentage',
        'title': 'Probability as Percentage',
        'type': 'multipleChoice',
        'prompt':
            'If an event has a 1/2 chance of happening, how is this described using a percentage?',
        'options': ['10%', '25%', '50%', '100%'],
        'correctAnswer': '50%',
        'explanation':
            '1/2 means one out of two, which is 50 out of 100, or 50%. Half of the time it will happen.',
        'hint': 'Half means 50% - think of a coin flip, it\'s 50-50.',
        'points': 30,
        'skills': ['probability', 'percentages', 'fractions'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Chance', 'Probability'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['dataVisualization', 'fractionNavigator'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5',
          'learningObjective': 'Convert probability to percentage',
          'prerequisiteSkills': ['fractions', 'percentages'],
          'followUpSkills': ['conditional-probability'],
        },
      },

      // Question 15: Order of Operations
      {
        'id': 'math_bright_015_order_operations',
        'title': 'Order of Operations - BODMAS',
        'type': 'multipleChoice',
        'prompt':
            'According to BODMAS, which operation should you solve before Multiplication?',
        'options': ['Addition', 'Subtraction', 'Brackets', 'Division'],
        'correctAnswer': 'Brackets',
        'explanation':
            'BODMAS stands for Brackets, Order (powers), Division, Multiplication, Addition, Subtraction. Brackets come first, then powers, then division and multiplication, then addition and subtraction.',
        'hint': 'BODMAS: B stands for Brackets - it comes first!',
        'points': 35,
        'skills': ['order-of-operations', 'algebra'],
        'subjects': ['math'],
        'ageGroups': ['bright'],
        'topics': ['Algebra', 'Order of Operations'],
        'difficultyLevel': 'hard',
        'estimatedTimeSeconds': 50,
        'gameTypes': ['inverseOperationChain'],
        'recommendedGameType': 'inverseOperationChain',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 6',
          'learningObjective': 'Apply BODMAS order of operations',
          'prerequisiteSkills': ['all-operations'],
          'followUpSkills': ['complex-expressions'],
        },
      },
    ];
  }

  /// Create Junior (6-8) English questions with proper structure
  List<Map<String, dynamic>> _createJuniorEnglishQuestions() {
    return [
      // Question 1: Spelling/Suffixes
      {
        'id': 'english_junior_001_spelling_suffixes_ing',
        'title': 'Spelling - Adding -ing',
        'type': 'multipleChoice',
        'prompt': 'To change LIVE to "living", what is the new ending?',
        'options': ['ing', 'liv'],
        'correctAnswer': 'ing',
        'explanation':
            'Drop the silent "e" in live and add -ing to form living.',
        'hint': 'Remove the letter e before you add the new ending.',
        'points': 20,
        'skills': ['spelling', 'suffixes', 'word-formation'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Spelling', 'Suffixes'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective':
              'Understand spelling rules for adding -ing suffix',
          'prerequisiteSkills': ['basic-spelling'],
          'followUpSkills': ['other-suffixes'],
        },
      },

      // Question 2: Grammar/Adverbs
      {
        'id': 'english_junior_002_grammar_adverbs',
        'title': 'Understanding Adverbs',
        'type': 'multipleChoice',
        'prompt':
            'An adverb is a word that gives more information about which part of a sentence?',
        'options': [
          'A noun',
          'A person (pronoun)',
          'An action (verb)',
          'A descriptive word (adjective)'
        ],
        'correctAnswer': 'An action (verb)',
        'explanation':
            'An adverb describes how, when, where, or to what extent an action (verb) happens. For example, "run quickly" - quickly is the adverb.',
        'hint': 'Think about words that tell you HOW someone does something.',
        'points': 20,
        'skills': ['grammar', 'adverbs', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Grammar', 'Adverbs'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['seashellQuiz', 'memoryMatch'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Identify what adverbs describe',
          'prerequisiteSkills': ['verbs', 'nouns'],
          'followUpSkills': ['adverb-types'],
        },
      },

      // Question 3: Vocabulary/Plurals
      {
        'id': 'english_junior_003_vocabulary_plurals_f_to_v',
        'title': 'Plurals - Words Ending in f or fe',
        'type': 'multipleChoice',
        'prompt': 'To make LEAF into \"leaves\", we change the \"f\" to...? ',
        'options': ['ves', 'f', 's'],
        'correctAnswer': 'ves',
        'explanation':
            'Leaf becomes leaves because the \"f\" sound changes to \"v\" and we add -es, creating the part \"ves\".',
        'hint': 'Listen to the end of the word leaves.',
        'points': 20,
        'skills': ['vocabulary', 'plurals', 'spelling'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Plurals'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective':
              'Understand plural formation for words ending in f/fe',
          'prerequisiteSkills': ['basic-plurals'],
          'followUpSkills': ['irregular-plurals'],
        },
      },

      // Question 4: Adverbs (How)
      {
        'id': 'english_junior_004_adverbs_how',
        'title': 'Adverbs - How Something is Done',
        'type': 'multipleChoice',
        'prompt': 'Find the adverb part in the word \"politely\".',
        'options': ['ly', 'polite'],
        'correctAnswer': 'ly',
        'explanation':
            'The ending -ly is the adverb part that tells how something is done.',
        'hint': 'Look at the ending of the word politely.',
        'points': 20,
        'skills': ['adverbs', 'vocabulary', 'comprehension'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Adverbs'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['bubblePopGrammar', 'seashellQuiz'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Identify adverb suffixes in words',
          'prerequisiteSkills': ['adverbs'],
          'followUpSkills': ['adverb-when', 'adverb-where'],
        },
      },

      // Question 5: Language Strands
      {
        'id': 'english_junior_005_language_strands_oral',
        'title': 'Language Strands - Oral Language',
        'type': 'multipleChoice',
        'prompt': 'Which language strand involves listening and speaking?',
        'options': [
          'Oral language',
          'Visual language',
          'Written language',
          'Mother tongue'
        ],
        'correctAnswer': 'Oral language',
        'explanation':
            'Oral language is communication through listening and speaking. It\'s how we talk and hear language.',
        'hint': 'Think about how you communicate by talking and listening.',
        'points': 15,
        'skills': ['vocabulary', 'language-strands'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Language Strands'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 25,
        'gameTypes': ['memoryMatch'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Understand language strands - oral language',
          'prerequisiteSkills': [],
          'followUpSkills': ['other-strands'],
        },
      },

      // Question 6: Vocabulary - Synonyms
      {
        'id': 'english_junior_006_comprehension_fact',
        'title': 'Vocabulary - Synonyms',
        'type': 'multipleChoice',
        'prompt': 'Which word means the same as "happy"?',
        'options': ['Sad', 'Glad', 'Angry', 'Tired'],
        'correctAnswer': 'Glad',
        'explanation':
            'Glad means the same as happy - they are synonyms. Both words describe a feeling of joy or pleasure.',
        'hint': 'Think of a word that means the same as happy.',
        'points': 15,
        'skills': ['vocabulary', 'synonyms', 'word-meaning'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Synonyms'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['seashellQuiz', 'memoryMatch'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective':
              'Identify synonyms - words with similar meanings',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['antonyms'],
        },
      },

      // Question 7: Spelling (-ed endings)
      {
        'id': 'english_junior_007_spelling_ed_endings',
        'title': 'Spelling - Adding -ed to Words',
        'type': 'multipleChoice',
        'prompt': 'Find the part you add to DROP to make it \"dropped\".',
        'options': ['ed', 'dropp'],
        'correctAnswer': 'ed',
        'explanation':
            'After doubling the final consonant in drop, we add -ed to make dropped.',
        'hint': 'Think about the ending sound in dropped.',
        'points': 25,
        'skills': ['spelling', 'word-formation', 'past-tense'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Spelling', '-ed endings'],
        'difficultyLevel': 'hard',
        'estimatedTimeSeconds': 45,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective':
              'Apply spelling rule for doubling consonants before -ed',
          'prerequisiteSkills': ['basic-spelling'],
          'followUpSkills': ['other-spelling-rules'],
        },
      },
    ];
  }

  /// Create Bright (9-12) English questions with proper structure
  List<Map<String, dynamic>> _createBrightEnglishQuestions() {
    return [
      // Question 1: Grammar/Connectives
      {
        'id': 'english_bright_001_grammar_connectives',
        'title': 'Subordinating Connectives',
        'type': 'multipleChoice',
        'prompt':
            'Choose the correct subordinating connective to complete this sentence: "The house ___ my friend lives has a blue door."',
        'options': ['which', 'that', 'where', 'when'],
        'correctAnswer': 'where',
        'explanation':
            '\'Where\' is used to refer to a place. In this sentence, it connects the main clause to the subordinate clause about the location.',
        'hint': 'Think about what word refers to a PLACE.',
        'points': 30,
        'skills': ['grammar', 'connectives', 'sentence-structure'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Grammar', 'Connectives'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['wordBuilder', 'storySequencer'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Use subordinating connectives correctly',
          'prerequisiteSkills': ['basic-grammar'],
          'followUpSkills': ['complex-sentences'],
        },
      },

      // Question 2: Vocabulary/Prefixes
      {
        'id': 'english_bright_002_vocabulary_prefixes_sub',
        'title': 'Prefixes - Sub',
        'type': 'multipleChoice',
        'prompt':
            'The prefix \'sub-\' means \'below\' or \'less than\'. Which word means \'below human\'?',
        'options': ['substandard', 'suborder', 'subhuman', 'subarea'],
        'correctAnswer': 'subhuman',
        'explanation':
            '\'Subhuman\' means below or less than human. The prefix \'sub-\' combined with \'human\' creates this meaning.',
        'hint': 'Which word combines "sub-" (below) with "human"?',
        'points': 25,
        'skills': ['vocabulary', 'prefixes', 'word-formation'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Vocabulary', 'Prefixes'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['wordBuilder'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Understand prefix meanings and word formation',
          'prerequisiteSkills': ['vocabulary'],
          'followUpSkills': ['other-prefixes'],
        },
      },

      // Question 3: Language/Figurative
      {
        'id': 'english_bright_003_language_figurative',
        'title': 'Figurative Language',
        'type': 'multipleChoice',
        'prompt':
            'Which of these is defined as language that enhances writing and includes types like metaphors and idioms?',
        'options': [
          'Subordinating conjunction',
          'Verb conjugation',
          'Figurative language',
          'Antonyms'
        ],
        'correctAnswer': 'Figurative language',
        'explanation':
            'Figurative language uses words or expressions with meanings different from literal meanings. It includes metaphors, similes, idioms, and other creative language.',
        'hint':
            'Think about creative ways to describe things - like saying "it\'s raining cats and dogs".',
        'points': 25,
        'skills': ['vocabulary', 'figurative-language', 'writing'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Language', 'Figurative'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['wordBuilder', 'storySequencer'],
        'recommendedGameType': 'storySequencer',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Understand figurative language concepts',
          'prerequisiteSkills': ['vocabulary'],
          'followUpSkills': ['metaphors', 'similes'],
        },
      },

      // Question 4: Spelling/Suffixes (Jobs)
      {
        'id': 'english_bright_004_spelling_suffixes_jobs',
        'title': 'Spelling - Job Suffixes (-cian)',
        'type': 'multipleChoice',
        'prompt':
            'Which suffix ending is used in the names of jobs, such as \'beautician\' or \'mathematician\'?',
        'options': ['-sion', '-tion', '-cian', '-tian'],
        'correctAnswer': '-cian',
        'explanation':
            'The suffix -cian is used for people who do certain jobs or activities, like beautician (beauty), mathematician (mathematics), and magician (magic).',
        'hint':
            'Think about the ending of words like "magician" or "musician".',
        'points': 25,
        'skills': ['spelling', 'suffixes', 'vocabulary'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Spelling', 'Suffixes'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['wordBuilder'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Identify job-related suffixes',
          'prerequisiteSkills': ['basic-spelling'],
          'followUpSkills': ['other-job-suffixes'],
        },
      },

      // Question 5: Grammar/Modals
      {
        'id': 'english_bright_005_grammar_modals',
        'title': 'Modal Verbs - Should',
        'type': 'multipleChoice',
        'prompt':
            'Which word from the list is a modal verb used to express advice, recommendation, or obligation?',
        'options': ['should', 'watch', 'homework', 'later'],
        'correctAnswer': 'should',
        'explanation':
            '\'Should\' is a modal verb used to give advice or make recommendations. For example: "You should do your homework."',
        'hint': 'Which word gives advice or tells someone what is good to do?',
        'points': 25,
        'skills': ['grammar', 'modal-verbs', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Grammar', 'Modals'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['wordBuilder', 'memoryMatch'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Identify modal verbs and their uses',
          'prerequisiteSkills': ['verbs'],
          'followUpSkills': ['other-modals'],
        },
      },

      // Question 6: Vocabulary/Suffixes
      {
        'id': 'english_bright_006_vocabulary_suffixes_less',
        'title': 'Suffixes - -less Meaning',
        'type': 'multipleChoice',
        'prompt': 'What does the suffix \'-less\' mean (as in \'wireless\')?',
        'options': ['without', 'quality', 'relating to', 'double'],
        'correctAnswer': 'without',
        'explanation':
            'The suffix -less means "without" or "lacking". For example: wireless (without wires), hopeless (without hope), careless (without care).',
        'hint': 'Think about what "wireless" means - it means without wires!',
        'points': 25,
        'skills': ['vocabulary', 'suffixes', 'word-formation'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Vocabulary', 'Suffixes'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['wordBuilder'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Understand suffix meanings',
          'prerequisiteSkills': ['vocabulary'],
          'followUpSkills': ['other-suffixes'],
        },
      },

      // Question 7: Grammar/Pronouns
      {
        'id': 'english_bright_007_grammar_pronouns_object',
        'title': 'Pronouns - Object Pronouns',
        'type': 'multipleChoice',
        'prompt':
            'In the following original text: "Felix saw his friends and stopped to pat the dog," which word could replace the underlined phrase "his friends" if it were the object of the sentence?',
        'options': ['he', 'they', 'them', 'their'],
        'correctAnswer': 'them',
        'explanation':
            '\'Them\' is the object pronoun that replaces "his friends" when used as the object in a sentence. Object pronouns (me, you, him, her, it, us, them) are used after verbs or prepositions.',
        'hint': 'Which pronoun is used for objects (receiving the action)?',
        'points': 30,
        'skills': ['grammar', 'pronouns', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Grammar', 'Pronouns'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['wordBuilder', 'storySequencer'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Use object pronouns correctly',
          'prerequisiteSkills': ['pronouns'],
          'followUpSkills': ['subject-pronouns'],
        },
      },

      // Question 8: Vocabulary/Roots
      {
        'id': 'english_bright_008_vocabulary_roots_vit',
        'title': 'Word Roots - Vit (Life)',
        'type': 'multipleChoice',
        'prompt':
            'In words of Latin or Greek root (like vitality), what is the meaning of the root \'vit\'?',
        'options': ['feel, be aware', 'life', 'year', 'meat'],
        'correctAnswer': 'life',
        'explanation':
            'The root \'vit\' comes from Latin and means "life". Words like vitality, vitamin, and survive all relate to life.',
        'hint': 'Think about words like "vitamin" - what do they relate to?',
        'points': 30,
        'skills': ['vocabulary', 'word-roots', 'etymology'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Vocabulary', 'Roots'],
        'difficultyLevel': 'hard',
        'estimatedTimeSeconds': 45,
        'gameTypes': ['wordBuilder', 'memoryMatch'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Understand word roots and etymology',
          'prerequisiteSkills': ['vocabulary'],
          'followUpSkills': ['other-roots'],
        },
      },

      // Question 9: Spelling/Prefixes
      {
        'id': 'english_bright_009_spelling_prefixes_re',
        'title': 'Prefixes - Re- (Again)',
        'type': 'multipleChoice',
        'prompt':
            'If the prefix \'re-\' means \'again,\' which option correctly describes the meaning of the word \'retell\'?',
        'options': [
          'to tell too little',
          'to tell in the opposite way',
          'to tell too much',
          'to tell again'
        ],
        'correctAnswer': 'to tell again',
        'explanation':
            'The prefix re- means "again" or "back". So "retell" means "to tell again" or "to tell a story again".',
        'hint': 'If "re-" means again, what does "retell" mean?',
        'points': 25,
        'skills': ['spelling', 'prefixes', 'vocabulary'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Spelling', 'Prefixes'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['wordBuilder'],
        'recommendedGameType': 'wordBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Understand prefix re- meaning',
          'prerequisiteSkills': ['vocabulary'],
          'followUpSkills': ['other-prefixes'],
        },
      },

      // Question 10: Language Strands
      {
        'id': 'english_bright_010_language_strands_visual',
        'title': 'Language Strands - Visual Language',
        'type': 'multipleChoice',
        'prompt':
            'The interpretation of charts, diagrams, and illustrations falls under which language strand?',
        'options': [
          'Oral language',
          'Reading comprehension',
          'Visual language',
          'Written language'
        ],
        'correctAnswer': 'Visual language',
        'explanation':
            'Visual language involves understanding and interpreting visual information like charts, diagrams, illustrations, graphs, and pictures.',
        'hint': 'Think about what you use to understand charts and pictures.',
        'points': 25,
        'skills': ['vocabulary', 'language-strands', 'visual-literacy'],
        'subjects': ['reading'],
        'ageGroups': ['bright'],
        'topics': ['Language Strands'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 5/6',
          'learningObjective': 'Understand visual language strand',
          'prerequisiteSkills': ['basic-reading'],
          'followUpSkills': ['data-visualization'],
        },
      },
    ];
  }

  /// Create Junior (6-8) Science questions with proper structure
  List<Map<String, dynamic>> _createJuniorScienceQuestions() {
    return [
      // Question 1: Materials/Properties
      {
        'id': 'science_junior_001_materials_properties_metal',
        'title': 'Material Properties - Metal',
        'type': 'multipleChoice',
        'prompt':
            'Which material property describes something that is hard and shiny and can be hammered into shape?',
        'options': ['Fabric', 'Metal', 'Glass', 'Wool'],
        'correctAnswer': 'Metal',
        'explanation':
            'Metal is hard, shiny, and can be shaped by hammering. It is malleable, which means it can be hammered or pressed into shape.',
        'hint': 'Think about what material is used to make tools and coins.',
        'points': 20,
        'skills': ['materials', 'properties', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Materials', 'Properties'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Identify metal material properties',
          'prerequisiteSkills': ['basic-materials'],
          'followUpSkills': ['other-materials'],
        },
      },

      // Question 2: Materials/Classification
      {
        'id': 'science_junior_002_materials_classification_natural',
        'title': 'Natural Materials',
        'type': 'multipleChoice',
        'prompt': 'Which of these is classified as a natural material?',
        'options': ['Plastic', 'Steel', 'Stone', 'Glass'],
        'correctAnswer': 'Stone',
        'explanation':
            'Natural materials come from nature and are not made by humans. Stone is found in nature, while plastic, steel, and glass are made by humans.',
        'hint':
            'Which one comes directly from nature without being made by people?',
        'points': 20,
        'skills': ['materials', 'classification', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Materials', 'Classification'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Distinguish natural from man-made materials',
          'prerequisiteSkills': ['basic-materials'],
          'followUpSkills': ['material-sources'],
        },
      },

      // Question 3: Living Things/Classification
      {
        'id': 'science_junior_003_living_things_vertebrates',
        'title': 'Vertebrates - Animals with Skeletons',
        'type': 'multipleChoice',
        'prompt':
            'Animals that have a skeleton inside their bodies are called what?',
        'options': ['Insects', 'Invertebrates', 'Vertebrates', 'Mammals'],
        'correctAnswer': 'Vertebrates',
        'explanation':
            'Vertebrates are animals with a backbone and internal skeleton. Examples include mammals, birds, fish, reptiles, and amphibians.',
        'hint':
            'Think about animals with bones inside - like dogs, birds, and fish.',
        'points': 20,
        'skills': ['living-things', 'classification', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Living Things', 'Classification'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Understand vertebrate classification',
          'prerequisiteSkills': ['basic-animals'],
          'followUpSkills': ['invertebrates'],
        },
      },

      // Question 4: Forces/Movement
      {
        'id': 'science_junior_004_forces_movement_pull',
        'title': 'Forces - Pull',
        'type': 'multipleChoice',
        'prompt':
            'Which word describes the force used when you pull a door handle towards you?',
        'options': ['Twist', 'Squash', 'Pull', 'Bend'],
        'correctAnswer': 'Pull',
        'explanation':
            'Pull is a force that moves something towards you. When you pull a door handle, you are using a pulling force.',
        'hint': 'What do you do when you move something towards yourself?',
        'points': 15,
        'skills': ['forces', 'movement', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Forces', 'Movement'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 25,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Identify pull force',
          'prerequisiteSkills': ['basic-forces'],
          'followUpSkills': ['push', 'other-forces'],
        },
      },

      // Question 5: Materials/State Change
      {
        'id': 'science_junior_005_materials_state_change_melting',
        'title': 'State Changes - Melting',
        'type': 'multipleChoice',
        'prompt':
            'When solid ice turns to liquid water, this process is called:',
        'options': ['Cooling', 'Melting', 'Steam', 'Baking'],
        'correctAnswer': 'Melting',
        'explanation':
            'Melting is the process when a solid (like ice) turns into a liquid (like water) when it gets warmer.',
        'hint': 'What happens to ice when it gets warm?',
        'points': 20,
        'skills': ['materials', 'state-changes', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Materials', 'State Change'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Understand melting as a state change',
          'prerequisiteSkills': ['basic-states'],
          'followUpSkills': ['freezing', 'evaporation'],
        },
      },

      // Question 6: Electricity/Sources of Power
      {
        'id': 'science_junior_006_electricity_battery',
        'title': 'Electricity - Battery',
        'type': 'multipleChoice',
        'prompt':
            'What is the main component that stores electricity to make small things like torches and toys work?',
        'options': ['Battery', 'Wire', 'Socket', 'Buzzer'],
        'correctAnswer': 'Battery',
        'explanation':
            'A battery stores electrical energy and provides power to devices like torches and toys. It contains chemicals that produce electricity.',
        'hint': 'What do you put in a torch to make it work?',
        'points': 20,
        'skills': ['electricity', 'circuits', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Electricity', 'Sources of Power'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch', 'patternBuilder'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Identify battery as power source',
          'prerequisiteSkills': ['basic-electricity'],
          'followUpSkills': ['circuits'],
        },
      },

      // Question 7: Measurement/Forces
      {
        'id': 'science_junior_007_measurement_forces_forcemeter',
        'title': 'Measuring Forces - Forcemeter',
        'type': 'multipleChoice',
        'prompt':
            'What instrument can be used to measure the size of a push or pull force?',
        'options': [
          'Ruler',
          'Thermometer',
          'Balance scale',
          'Forcemeter (Spring Balance)'
        ],
        'correctAnswer': 'Forcemeter (Spring Balance)',
        'explanation':
            'A forcemeter (or spring balance) measures forces. It uses a spring that stretches when a force is applied, showing how strong the force is.',
        'hint': 'Which tool measures how strong a push or pull is?',
        'points': 25,
        'skills': ['measurement', 'forces', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Measurement', 'Forces'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['memoryMatch'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Identify tool for measuring forces',
          'prerequisiteSkills': ['basic-measurement'],
          'followUpSkills': ['force-units'],
        },
      },

      // Question 8: Light/Reflection
      {
        'id': 'science_junior_008_light_reflection_sun',
        'title': 'Light Sources - The Sun',
        'type': 'multipleChoice',
        'prompt':
            'Which object listed below is a source of light, rather than reflecting light from another source?',
        'options': ['The Moon', 'A Mirror', 'A Spoon', 'The Sun'],
        'correctAnswer': 'The Sun',
        'explanation':
            'The Sun is a source of light - it produces its own light. The Moon, mirrors, and spoons reflect light but do not produce it themselves.',
        'hint': 'Which one makes its own light and shines during the day?',
        'points': 20,
        'skills': ['light', 'reflection', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['junior'],
        'topics': ['Light', 'Reflection'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 1-3',
          'learningObjective': 'Distinguish light sources from reflectors',
          'prerequisiteSkills': ['basic-light'],
          'followUpSkills': ['other-light-sources'],
        },
      },
    ];
  }

  /// Create Bright (9-12) Science questions with proper structure
  List<Map<String, dynamic>> _createBrightScienceQuestions() {
    return [
      // Question 1: States of Matter (Gas)
      {
        'id': 'science_bright_001_states_matter_gas',
        'title': 'States of Matter - Gas Particles',
        'type': 'multipleChoice',
        'prompt':
            'Which statement accurately describes the particles in a gas?',
        'options': [
          'They are packed closely and do not move much.',
          'They are packed closely but can move a small amount.',
          'They are far apart and can move quickly in every direction.',
          'They have a fixed shape and volume.'
        ],
        'correctAnswer':
            'They are far apart and can move quickly in every direction.',
        'explanation':
            'In a gas, particles are far apart and move quickly in all directions. Gases have no fixed shape or volume.',
        'hint': 'Think about how gas particles can spread out and move freely.',
        'points': 30,
        'skills': ['states-of-matter', 'particles', 'scientific-concepts'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['States of Matter'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['dataVisualization', 'memoryMatch'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Understand particle behavior in gases',
          'prerequisiteSkills': ['basic-states'],
          'followUpSkills': ['solid-particles', 'liquid-particles'],
        },
      },

      // Question 2: Magnetism
      {
        'id': 'science_bright_002_magnetism_repel',
        'title': 'Magnetism - Like Poles Repel',
        'type': 'multipleChoice',
        'prompt':
            'What happens when the North pole of one bar magnet is brought close to the North pole of another bar magnet?',
        'options': [
          'The magnets attract each other.',
          'The magnets become non-magnetic.',
          'The magnets repel each other.',
          'They stay together, but spin around.'
        ],
        'correctAnswer': 'The magnets repel each other.',
        'explanation':
            'Like poles (North-North or South-South) repel each other. Opposite poles (North-South) attract each other.',
        'hint': 'What happens when you try to push two similar poles together?',
        'points': 30,
        'skills': ['magnetism', 'forces', 'scientific-concepts'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['Magnetism'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['dataVisualization', 'memoryMatch'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Understand magnetic pole interactions',
          'prerequisiteSkills': ['basic-magnetism'],
          'followUpSkills': ['magnetic-fields'],
        },
      },

      // Question 3: States of Matter (Melting Point)
      {
        'id': 'science_bright_003_states_matter_melting_point',
        'title': 'Melting Point of Ice',
        'type': 'multipleChoice',
        'prompt':
            'At what temperature (°C) does solid ice melt into liquid water?',
        'options': ['100°C', '-10°C', '0°C', '40°C'],
        'correctAnswer': '0°C',
        'explanation':
            'Ice melts at 0°C (32°F). This is the melting point of water - the temperature at which ice turns into liquid water.',
        'hint':
            'Think about what temperature water freezes - that\'s also when ice melts!',
        'points': 25,
        'skills': ['states-of-matter', 'temperature', 'measurement'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['States of Matter'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Know the melting point of water',
          'prerequisiteSkills': ['temperature'],
          'followUpSkills': ['boiling-point'],
        },
      },

      // Question 4: Circuits/Components
      {
        'id': 'science_bright_004_circuits_components_switch',
        'title': 'Circuits - Switch Component',
        'type': 'multipleChoice',
        'prompt':
            'In an electric circuit, which component is used specifically to break the circuit?',
        'options': ['Battery', 'Lamp (Bulb)', 'Wire', 'Switch'],
        'correctAnswer': 'Switch',
        'explanation':
            'A switch is used to break or complete a circuit. When open, it stops the flow of electricity. When closed, it allows electricity to flow.',
        'hint': 'What do you turn on and off to control a light?',
        'points': 25,
        'skills': ['circuits', 'electricity', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['Circuits', 'Components'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization', 'patternBuilder'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Identify switch function in circuits',
          'prerequisiteSkills': ['basic-circuits'],
          'followUpSkills': ['circuit-diagrams'],
        },
      },

      // Question 5: Sound/Measurement
      {
        'id': 'science_bright_005_sound_measurement_decibels',
        'title': 'Sound Measurement - Decibels',
        'type': 'multipleChoice',
        'prompt': 'Sound level is measured in which unit?',
        'options': [
          'Decibels (dB)',
          'Centimetres (cm)',
          'Newtons (N)',
          'Volts (V)'
        ],
        'correctAnswer': 'Decibels (dB)',
        'explanation':
            'Sound level (loudness) is measured in decibels (dB). The higher the decibels, the louder the sound.',
        'hint': 'Which unit is used to measure how loud something is?',
        'points': 25,
        'skills': ['sound', 'measurement', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['Sound', 'Measurement'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Know unit for measuring sound',
          'prerequisiteSkills': ['basic-measurement'],
          'followUpSkills': ['sound-properties'],
        },
      },

      // Question 6: Habitats/Ecology
      {
        'id': 'science_bright_006_habitats_ecology_identification_key',
        'title': 'Ecology - Identification Key',
        'type': 'multipleChoice',
        'prompt':
            'To identify different animals or plants found in a habitat, scientists often use a structured tool called an:',
        'options': [
          'Observation table',
          'Census sheet',
          'Bar graph',
          'Identification key'
        ],
        'correctAnswer': 'Identification key',
        'explanation':
            'An identification key (or dichotomous key) is a tool scientists use to identify and classify living things by answering a series of questions.',
        'hint':
            'Which tool helps you identify and name different living things?',
        'points': 30,
        'skills': ['habitats', 'ecology', 'scientific-methods'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['Habitats', 'Ecology'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['dataVisualization', 'memoryMatch'],
        'recommendedGameType': 'dataVisualization',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Understand identification keys in ecology',
          'prerequisiteSkills': ['basic-classification'],
          'followUpSkills': ['using-keys'],
        },
      },

      // Question 7: Circuits/Function
      {
        'id': 'science_bright_007_circuits_function_open_switch',
        'title': 'Circuits - Open Switch',
        'type': 'multipleChoice',
        'prompt':
            'When a switch is open in an electric circuit, what happens to the electricity?',
        'options': [
          'It flows faster',
          'It cannot flow',
          'It flows to the buzzer',
          'The lamp gets brighter'
        ],
        'correctAnswer': 'It cannot flow',
        'explanation':
            'When a switch is open, it breaks the circuit, so electricity cannot flow. The circuit is incomplete, so no current passes through.',
        'hint': 'What happens when you turn a switch OFF?',
        'points': 25,
        'skills': ['circuits', 'electricity', 'scientific-concepts'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['Circuits', 'Function'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['dataVisualization', 'patternBuilder'],
        'recommendedGameType': 'patternBuilder',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Understand switch function in circuits',
          'prerequisiteSkills': ['basic-circuits'],
          'followUpSkills': ['complete-circuits'],
        },
      },

      // Question 8: Magnetism/Materials
      {
        'id': 'science_bright_008_magnetism_materials_steel',
        'title': 'Magnetic Materials - Steel',
        'type': 'multipleChoice',
        'prompt':
            'Which metal is mentioned in the sources as one that is magnetic?',
        'options': ['Aluminium', 'Copper', 'Steel', 'None of these'],
        'correctAnswer': 'Steel',
        'explanation':
            'Steel is a magnetic material - magnets are attracted to it. Aluminium and copper are not magnetic.',
        'hint': 'Which metal do magnets stick to?',
        'points': 25,
        'skills': ['magnetism', 'materials', 'vocabulary'],
        'subjects': ['science'],
        'ageGroups': ['bright'],
        'topics': ['Magnetism', 'Materials'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['memoryMatch', 'dataVisualization'],
        'recommendedGameType': 'memoryMatch',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'Stage 4',
          'learningObjective': 'Identify magnetic materials',
          'prerequisiteSkills': ['basic-magnetism'],
          'followUpSkills': ['non-magnetic-materials'],
        },
      },
    ];
  }

  /// Update a specific question template in Firestore
  Future<void> updateQuestionTemplate(String templateId) async {
    try {
      debugPrint('🔄 Updating question template: $templateId');

      // Get the current document to preserve createdAt
      final docRef = _firestore.collection(collectionName).doc(templateId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Template $templateId does not exist in Firestore');
      }

      // Get the updated question data from the junior English questions
      final juniorQuestions = _createJuniorEnglishQuestions();
      final updatedQuestion = juniorQuestions.firstWhere(
        (q) => q['id'] == templateId,
        orElse: () => throw Exception('Template $templateId not found in code'),
      );

      // Remove the id from the data (it's the document ID)
      final updateData = Map<String, dynamic>.from(updatedQuestion);
      updateData.remove('id');

      // Preserve createdAt if it exists
      final existingData = docSnapshot.data();
      if (existingData != null && existingData.containsKey('createdAt')) {
        updateData['createdAt'] = existingData['createdAt'];
      }

      // Always update updatedAt
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Update the document in Firestore
      await docRef.set(updateData, SetOptions(merge: true));

      debugPrint('✅ Successfully updated question template: $templateId');
    } catch (e) {
      debugPrint('❌ Error updating question template: $e');
      rethrow;
    }
  }

  /// Populate new Add Equations questions for Junior age group
  Future<void> populateAddEquationsQuestions() async {
    try {
      debugPrint('🚀 Starting Add Equations questions population...');

      final questions = _createAddEquationsQuestions();

      final batch = _firestore.batch();
      int count = 0;

      // Add questions
      for (final question in questions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question);
        count++;
      }

      await batch.commit();
      debugPrint(
          '✅ Successfully populated $count Add Equations question templates!');
    } catch (e) {
      debugPrint('❌ Error populating Add Equations questions: $e');
      rethrow;
    }
  }

  /// Create Add Equations questions from the provided JSON data
  List<Map<String, dynamic>> _createAddEquationsQuestions() {
    return [
      // Add Equations: Missing Addend 1
      {
        'id': 'math_junior_add_001_missing_addend',
        'title': 'Add Equations: Missing Addend 1',
        'type': 'drag-drop',
        'prompt': '_ + 6 = 9',
        'options': ['2', '1', '3'],
        'correctAnswer': '3',
        'skills': ['addition', 'missing-addend', 'balancing-equations'],
        'points': 20,
        'explanation':
            'Drag the number 3 to the blank. Three plus six equals nine. The visual shows 3 raspberries and 6 oranges.',
        'hint': 'Count the raspberries and drag that number to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Find missing addend in addition equations',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Add Equations: Simple Addition 1
      {
        'id': 'math_junior_add_002_simple_addition',
        'title': 'Add Equations: Simple Addition 1',
        'type': 'drag-drop',
        'prompt': '4 + 4 = _',
        'options': ['7', '9', '8'],
        'correctAnswer': '8',
        'skills': ['addition', 'counting', 'doubles'],
        'points': 20,
        'explanation':
            'Drag the number 8 to the blank. Four plus four equals eight. The visual shows 4 raspberries and 4 oranges.',
        'hint': 'Count all the fruit and drag the total to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Add single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['doubles-facts'],
        },
      },
      // Add Equations: Missing Addend 2
      {
        'id': 'math_junior_add_003_missing_addend_2',
        'title': 'Add Equations: Missing Addend 2',
        'type': 'drag-drop',
        'prompt': '1 + _ = 7',
        'options': ['8', '6', '10'],
        'correctAnswer': '6',
        'skills': ['addition', 'missing-addend', 'balancing-equations'],
        'points': 20,
        'explanation':
            'Drag the number 6 to the blank. One plus six equals seven.',
        'hint':
            'Start at 1 and count up to 7. Drag the number of steps you took.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Find missing addend in addition equations',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Add Equations: Missing Addend 3
      {
        'id': 'math_junior_add_004_missing_addend_3',
        'title': 'Add Equations: Missing Addend 3',
        'type': 'drag-drop',
        'prompt': '_ + 5 = 6',
        'options': ['3', '2', '1'],
        'correctAnswer': '1',
        'skills': ['addition', 'missing-addend'],
        'points': 20,
        'explanation':
            'Drag the number 1 to the blank. One plus five equals six. The visual shows a 1-dot die and a 5-dot die.',
        'hint': 'What number do you add to 5 to get 6? Drag it to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Find missing addend in addition equations',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Add Equations: Simple Addition 2
      {
        'id': 'math_junior_add_005_simple_addition_2',
        'title': 'Add Equations: Simple Addition 2',
        'type': 'drag-drop',
        'prompt': '2 + 3 = _',
        'options': ['2', '4', '5'],
        'correctAnswer': '5',
        'skills': ['addition', 'counting'],
        'points': 20,
        'explanation':
            'Drag the number 5 to the blank. Two plus three equals five. The visual shows a 2-dot die and a 3-dot die.',
        'hint': 'Count the dots on both dice and drag the total to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Add single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['addition-facts'],
        },
      },
      // Add Equations: Missing Addend 4
      {
        'id': 'math_junior_add_006_missing_addend_4',
        'title': 'Add Equations: Missing Addend 4',
        'type': 'drag-drop',
        'prompt': '6 + _ = 10',
        'options': ['6', '4', '5'],
        'correctAnswer': '4',
        'skills': ['addition', 'missing-addend', 'make-ten'],
        'points': 25,
        'explanation':
            'Drag the number 4 to the blank. Six plus four equals ten. The visual shows a ten-frame.',
        'hint': 'How many more to make 10? Drag the number to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Find missing addend to make 10',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['make-ten-strategies'],
        },
      },
      // Add Equations: Simple Addition 3
      {
        'id': 'math_junior_add_007_simple_addition_3',
        'title': 'Add Equations: Simple Addition 3',
        'type': 'drag-drop',
        'prompt': '3 + 5 = _',
        'options': ['8', '6', '7'],
        'correctAnswer': '8',
        'skills': ['addition', 'counting'],
        'points': 20,
        'explanation':
            'Drag the number 8 to the blank. Three plus five equals eight.',
        'hint': 'You can count on: 5... 6, 7, 8. Drag the final number.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Add single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['addition-facts'],
        },
      },
      // Add Equations: Missing Addend 5
      {
        'id': 'math_junior_add_008_missing_addend_5',
        'title': 'Add Equations: Missing Addend 5',
        'type': 'drag-drop',
        'prompt': '_ + 2 = 4',
        'options': ['2', '3', '1'],
        'correctAnswer': '2',
        'skills': ['addition', 'missing-addend', 'doubles'],
        'points': 20,
        'explanation':
            'Drag the number 2 to the blank. Two plus two equals four.',
        'hint': 'What number plus 2 makes 4? Drag it to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Find missing addend in addition equations',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['doubles-facts'],
        },
      },
      // Add Equations: Simple Addition (Vertical)
      {
        'id': 'math_junior_add_009_simple_addition_vertical',
        'title': 'Add Equations: Simple Addition (Vertical)',
        'type': 'drag-drop',
        'prompt': '3 + 7 = _',
        'options': ['10', '8', '9'],
        'correctAnswer': '10',
        'skills': ['addition', 'make-ten'],
        'points': 25,
        'explanation':
            'Drag the number 10 to the blank. Three plus seven makes ten.',
        'hint': 'This is a \'Make 10\' pair! Drag the answer to the box.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Add numbers to make 10',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['make-ten-strategies'],
        },
      },
      // Add Equations: Missing Addend (Vertical)
      {
        'id': 'math_junior_add_010_missing_addend_vertical',
        'title': 'Add Equations: Missing Addend (Vertical)',
        'type': 'drag-drop',
        'prompt': '4 + _ = 7',
        'options': ['4', '5', '3'],
        'correctAnswer': '3',
        'skills': ['addition', 'missing-addend'],
        'points': 20,
        'explanation':
            'Drag the number 3 to the blank. Four plus three equals seven.',
        'hint': 'Start at 4 and count up to 7. Drag the number of steps.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Find missing addend in addition equations',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Add 10-20: Simple Addition
      {
        'id': 'math_junior_add_011_add_10_20_simple',
        'title': 'Add 10-20: Simple Addition',
        'type': 'drag-drop',
        'prompt': '8 + 5 = _',
        'options': ['11', '13', '10'],
        'correctAnswer': '13',
        'skills': ['addition', 'counting-on', 'add-to-20'],
        'points': 25,
        'explanation':
            'Drag the number 13 to the blank. Start at 8 and count on 5: 9, 10, 11, 12, 13.',
        'hint':
            'The visual shows 8 items in one tray and 5 in another. Drag the total.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add 10-20'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add 10-20',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Add numbers within 20',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['addition-to-20'],
        },
      },
      // Add 10-20: Missing Addend
      {
        'id': 'math_junior_add_012_add_10_20_missing',
        'title': 'Add 10-20: Missing Addend',
        'type': 'drag-drop',
        'prompt': '11 + _ = 14',
        'options': ['2', '3', '4'],
        'correctAnswer': '3',
        'skills': ['addition', 'missing-addend', 'add-to-20'],
        'points': 25,
        'explanation':
            'Drag the number 3 to the blank. Start at 11 and count up to 14: 12, 13, 14. That\'s 3 steps.',
        'hint': 'How many jumps from 11 to 14? Drag that number.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add 10-20'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add 10-20',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Find missing addend within 20',
          'prerequisiteSkills': ['addition-to-20'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Subtract Equations: Missing Minuend 1
      {
        'id': 'math_junior_sub_001_missing_minuend',
        'title': 'Subtract Equations: Missing Minuend 1',
        'type': 'drag-drop',
        'prompt': '_ - 1 = 6',
        'options': ['5', '8', '7'],
        'correctAnswer': '7',
        'skills': ['subtraction', 'missing-minuend'],
        'points': 25,
        'explanation':
            'Drag the number 7 to the blank. Seven minus one equals six. The visual shows 7 buttons.',
        'hint':
            'What number, when you take 1 away, leaves 6? Drag it to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Find missing minuend in subtraction equations',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Subtract Equations: Simple Subtraction 1
      {
        'id': 'math_junior_sub_002_simple_subtraction',
        'title': 'Subtract Equations: Simple Subtraction 1',
        'type': 'drag-drop',
        'prompt': '8 - 5 = _',
        'options': ['3', '6', '5'],
        'correctAnswer': '3',
        'skills': ['subtraction', 'counting'],
        'points': 20,
        'explanation':
            'Drag the number 3 to the blank. Eight minus five equals three. The visual shows 8 buttons, with 5 fading away.',
        'hint': 'Start with 8 and take 5 away. Drag the answer.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Subtract single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['subtraction-facts'],
        },
      },
      // Subtract Equations: Missing Subtrahend 1
      {
        'id': 'math_junior_sub_003_missing_subtrahend',
        'title': 'Subtract Equations: Missing Subtrahend 1',
        'type': 'drag-drop',
        'prompt': '9 - _ = 7',
        'options': ['4', '6', '2'],
        'correctAnswer': '2',
        'skills': ['subtraction', 'missing-subtrahend'],
        'points': 25,
        'explanation':
            'Drag the number 2 to the blank. Nine minus two equals seven.',
        'hint':
            'Start at 9 and count back to 7. How many steps? Drag that number.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective':
              'Find missing subtrahend in subtraction equations',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Subtract Equations: Missing Minuend 2
      {
        'id': 'math_junior_sub_004_missing_minuend_2',
        'title': 'Subtract Equations: Missing Minuend 2',
        'type': 'drag-drop',
        'prompt': '_ - 1 = 4',
        'options': ['2', '5', '3'],
        'correctAnswer': '5',
        'skills': ['subtraction', 'missing-minuend'],
        'points': 25,
        'explanation':
            'Drag the number 5 to the blank. Five minus one equals four. The visual shows a 5-dot die.',
        'hint': 'What number, when you take 1 away, leaves 4? Drag it.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Find missing minuend in subtraction equations',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Subtract Equations: Simple Subtraction 2
      {
        'id': 'math_junior_sub_005_simple_subtraction_2',
        'title': 'Subtract Equations: Simple Subtraction 2',
        'type': 'drag-drop',
        'prompt': '3 - 2 = _',
        'options': ['3', '1', '2'],
        'correctAnswer': '1',
        'skills': ['subtraction'],
        'points': 20,
        'explanation':
            'Drag the number 1 to the blank. Three minus two equals one.',
        'hint': '3 take away 2 leaves how many? Drag the answer.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Subtract single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['subtraction-facts'],
        },
      },
      // Subtract Equations: Simple Subtraction 3
      {
        'id': 'math_junior_sub_006_simple_subtraction_3',
        'title': 'Subtract Equations: Simple Subtraction 3',
        'type': 'drag-drop',
        'prompt': '9 - 7 = _',
        'options': ['3', '5', '2'],
        'correctAnswer': '2',
        'skills': ['subtraction'],
        'points': 20,
        'explanation':
            'Drag the number 2 to the blank. Nine minus seven equals two.',
        'hint': 'Start at 9 and count back 7. Drag the number you land on.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Subtract single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['subtraction-facts'],
        },
      },
      // Subtract Equations: Simple Subtraction 4
      {
        'id': 'math_junior_sub_007_simple_subtraction_4',
        'title': 'Subtract Equations: Simple Subtraction 4',
        'type': 'drag-drop',
        'prompt': '8 - 4 = _',
        'options': ['9', '4', '7'],
        'correctAnswer': '4',
        'skills': ['subtraction', 'doubles'],
        'points': 20,
        'explanation':
            'Drag the number 4 to the blank. Eight minus four equals four. This is a doubles fact!',
        'hint': 'What is half of 8? Drag the answer.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Subtract single-digit numbers',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['doubles-facts'],
        },
      },
      // Subtract Equations: Simple Subtraction (Vertical)
      {
        'id': 'math_junior_sub_008_simple_subtraction_vertical',
        'title': 'Subtract Equations: Simple Subtraction (Vertical)',
        'type': 'drag-drop',
        'prompt': '10 - 6 = _',
        'options': ['5', '4', '6'],
        'correctAnswer': '4',
        'skills': ['subtraction', 'make-ten'],
        'points': 20,
        'explanation':
            'Drag the number 4 to the box. Ten minus six equals four.',
        'hint': 'If 6 + 4 = 10, then 10 - 6 = ?',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Subtract from 10',
          'prerequisiteSkills': ['make-ten'],
          'followUpSkills': ['subtraction-facts'],
        },
      },
      // Subtract Equations: Missing Subtrahend (Vertical)
      {
        'id': 'math_junior_sub_009_missing_subtrahend_vertical',
        'title': 'Subtract Equations: Missing Subtrahend (Vertical)',
        'type': 'drag-drop',
        'prompt': '4 - _ = 2',
        'options': ['2', '5', '6'],
        'correctAnswer': '2',
        'skills': ['subtraction', 'missing-subtrahend', 'doubles'],
        'points': 20,
        'explanation':
            'Drag the number 2 to the box. Four minus two equals two.',
        'hint': '4 take away what number leaves 2? Drag it to the box.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective':
              'Find missing subtrahend in subtraction equations',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['doubles-facts'],
        },
      },
      // Subtract Equations: Missing Minuend (Vertical)
      {
        'id': 'math_junior_sub_010_missing_minuend_vertical',
        'title': 'Subtract Equations: Missing Minuend (Vertical)',
        'type': 'drag-drop',
        'prompt': '_ - 3 = 4',
        'options': ['7', '6', '5'],
        'correctAnswer': '7',
        'skills': ['subtraction', 'missing-minuend'],
        'points': 25,
        'explanation':
            'Drag the number 7 to the box. Seven minus three equals four.',
        'hint':
            'What number, when you take 3 away, leaves 4? (Hint: 3 + 4 = ?)',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract Equations'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Find missing minuend in subtraction equations',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['complex-equations'],
        },
      },
      // Subtract 10-20: Simple Subtraction
      {
        'id': 'math_junior_sub_011_subtract_10_20_simple',
        'title': 'Subtract 10-20: Simple Subtraction',
        'type': 'drag-drop',
        'prompt': '11 - 2 = _',
        'options': ['11', '9', '8'],
        'correctAnswer': '9',
        'skills': ['subtraction', 'subtract-from-20'],
        'points': 20,
        'explanation':
            'Drag the number 9 to the blank. Eleven minus two equals nine.',
        'hint': 'Start at 11 and count back 2. Drag the answer.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract 10-20'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract 10-20',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Subtract from numbers within 20',
          'prerequisiteSkills': ['basic-subtraction'],
          'followUpSkills': ['subtraction-to-20'],
        },
      },
      // Subtract 10-20: Missing Subtrahend
      {
        'id': 'math_junior_sub_012_subtract_10_20_missing',
        'title': 'Subtract 10-20: Missing Subtrahend',
        'type': 'drag-drop',
        'prompt': '13 - _ = 9',
        'options': ['4', '5', '2'],
        'correctAnswer': '4',
        'skills': ['subtraction', 'missing-subtrahend', 'subtract-from-20'],
        'points': 25,
        'explanation':
            'Drag the number 4 to the blank. Thirteen minus four equals nine.',
        'hint':
            'Start at 13 and count back to 9. How many steps? Drag that number.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Subtract 10-20'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Subtract 10-20',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Find missing subtrahend within 20',
          'prerequisiteSkills': ['subtraction-to-20'],
          'followUpSkills': ['complex-equations'],
        },
      },
    ];
  }

  /// Update existing math questions
  Future<void> updateMathQuestions() async {
    try {
      debugPrint('🔄 Starting Math questions update...');

      final questionsToUpdate = _createUpdatedMathQuestions();

      final batch = _firestore.batch();
      int count = 0;

      for (final question in questionsToUpdate) {
        final templateId = question['id'] as String;
        final docRef = _firestore.collection(collectionName).doc(templateId);

        // Get existing document to preserve createdAt
        final docSnapshot = await docRef.get();

        // Remove id from data (it's the document ID)
        final updateData = Map<String, dynamic>.from(question);
        updateData.remove('id');

        // Preserve createdAt if it exists
        if (docSnapshot.exists) {
          final existingData = docSnapshot.data();
          if (existingData != null && existingData.containsKey('createdAt')) {
            updateData['createdAt'] = existingData['createdAt'];
          }
        }

        // Always update updatedAt
        updateData['updatedAt'] = FieldValue.serverTimestamp();

        // Update or create the document
        batch.set(docRef, updateData, SetOptions(merge: true));
        count++;
      }

      await batch.commit();
      debugPrint('✅ Successfully updated $count Math question templates!');
    } catch (e) {
      debugPrint('❌ Error updating Math questions: $e');
      rethrow;
    }
  }

  /// Create updated math questions from the provided JSON data
  List<Map<String, dynamic>> _createUpdatedMathQuestions() {
    return [
      // Skip Counting by 2s
      {
        'id': 'math_junior_013_patterns_skip_counting',
        'title': 'Skip Counting by 2s',
        'type': 'drag-drop',
        'prompt': 'What comes next in the pattern? 2, 4, 6, 8, _',
        'options': ['9', '10', '11'],
        'correctAnswer': '10',
        'skills': ['skip-counting', 'number-patterns'],
        'points': 20,
        'explanation':
            'We are counting by 2s, so 8 + 2 = 10. Drag the 10 to the blank.',
        'hint': 'Add 2 to the last number and drag the answer to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Continue number patterns by skip counting',
          'prerequisiteSkills': ['counting-by-2s'],
          'followUpSkills': ['complex-patterns'],
        },
      },
      // Skip Counting by 5s
      {
        'id': 'math_junior_014_patterns_skip_counting_5s',
        'title': 'Skip Counting by 5s',
        'type': 'drag-drop',
        'prompt': 'What comes next? 5, 10, 15, 20, _',
        'options': ['22', '25', '30'],
        'correctAnswer': '25',
        'skills': ['skip-counting', 'multiplication'],
        'points': 25,
        'explanation':
            'We are counting by 5s, so 20 + 5 = 25. Drag the 25 to the blank.',
        'hint': 'Add 5 to the last number and drag the answer to the blank.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective':
              'Continue number patterns by skip counting by 5s',
          'prerequisiteSkills': ['counting-by-5s'],
          'followUpSkills': ['multiplication-facts'],
        },
      },
      // Missing Numbers in Sequence
      {
        'id': 'math_junior_015_patterns_missing_numbers',
        'title': 'Missing Numbers in Sequence',
        'type': 'drag-drop',
        'prompt': 'Fill in the missing number: 12, 13, _, 15, 16',
        'options': ['11', '14', '17'],
        'correctAnswer': '14',
        'skills': ['counting', 'number-sequence'],
        'points': 15,
        'explanation':
            'The numbers are counting up by 1, so 13 + 1 = 14. Drag the 14 to the blank.',
        'hint': 'Count up by 1 from 13 and drag the missing number.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add Equations'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 60,
        'recommendedGameType': 'Add Equations',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Identify missing numbers in sequences',
          'prerequisiteSkills': ['counting'],
          'followUpSkills': ['number-patterns'],
        },
      },
      // Counting On Strategy
      {
        'id': 'math_junior_016_mental_strategies_counting_on',
        'title': 'Counting On Strategy',
        'type': 'drag-drop',
        'prompt': 'Use counting on: 9 + 6 = _',
        'options': ['14', '15', '16'],
        'correctAnswer': '15',
        'skills': ['addition', 'mental-math', 'counting-on'],
        'points': 25,
        'explanation':
            'Start with the bigger number 9 and count on 6: 10, 11, 12, 13, 14, 15. Drag 15 to the blank.',
        'hint': 'Start with 9 and count forward 6. Drag the final number.',
        'ageGroups': ['junior'],
        'subjects': ['math'],
        'gameTypes': ['Add 10-20'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 120,
        'recommendedGameType': 'Add 10-20',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Use counting on strategy for addition',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['mental-math-strategies'],
        },
      },
    ];
  }

  /// Populate additional questions for BubblePop (English), FishTank (Math), and Seashell (English) games
  Future<void> populateAdditionalGameQuestions() async {
    try {
      debugPrint('🚀 Starting additional game questions population...');

      final questions = _createAdditionalGameQuestions();

      final batch = _firestore.batch();
      int count = 0;

      for (final question in questions) {
        final docRef =
            _firestore.collection(collectionName).doc(question['id'] as String);
        batch.set(docRef, question, SetOptions(merge: true));
        count++;
      }

      await batch.commit();
      debugPrint(
          '✅ Successfully populated $count additional game question templates!');
    } catch (e) {
      debugPrint('❌ Error populating additional game questions: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _createAdditionalGameQuestions() {
    return [
      // BubblePop Grammar Questions (English - Junior)
      {
        'id': 'english_junior_008_grammar_nouns',
        'title': 'Identifying Nouns',
        'type': 'multipleChoice',
        'prompt': 'Which word is a noun?',
        'options': ['run', 'happy', 'cat', 'quickly'],
        'correctAnswer': 'cat',
        'explanation':
            'A noun is a person, place, or thing. Cat is a thing, so it is a noun.',
        'hint': 'Think about words that name a person, place, or thing.',
        'points': 20,
        'skills': ['grammar', 'nouns', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Grammar', 'Nouns'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Identify nouns in sentences',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['proper-nouns'],
        },
      },
      {
        'id': 'english_junior_009_grammar_verbs',
        'title': 'Identifying Verbs',
        'type': 'multipleChoice',
        'prompt': 'Which word is a verb?',
        'options': ['dog', 'jump', 'blue', 'table'],
        'correctAnswer': 'jump',
        'explanation':
            'A verb is an action word. Jump is an action, so it is a verb.',
        'hint': 'Think about words that show action or what someone does.',
        'points': 20,
        'skills': ['grammar', 'verbs', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Grammar', 'Verbs'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Identify verbs in sentences',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['verb-tenses'],
        },
      },
      {
        'id': 'english_junior_010_grammar_adjectives',
        'title': 'Identifying Adjectives',
        'type': 'multipleChoice',
        'prompt': 'Which word is an adjective?',
        'options': ['play', 'big', 'run', 'eat'],
        'correctAnswer': 'big',
        'explanation':
            'An adjective describes a noun. Big describes how something looks, so it is an adjective.',
        'hint':
            'Think about words that describe how something looks, feels, or sounds.',
        'points': 20,
        'skills': ['grammar', 'adjectives', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Grammar', 'Adjectives'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Identify adjectives in sentences',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['comparative-adjectives'],
        },
      },
      {
        'id': 'english_junior_011_grammar_pronouns',
        'title': 'Understanding Pronouns',
        'type': 'multipleChoice',
        'prompt': 'Which word is a pronoun?',
        'options': ['book', 'she', 'happy', 'run'],
        'correctAnswer': 'she',
        'explanation':
            'A pronoun takes the place of a noun. She takes the place of a person\'s name, so it is a pronoun.',
        'hint': 'Think about words that can replace a person\'s name.',
        'points': 20,
        'skills': ['grammar', 'pronouns', 'parts-of-speech'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Grammar', 'Pronouns'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Identify pronouns in sentences',
          'prerequisiteSkills': ['nouns'],
          'followUpSkills': ['pronoun-agreement'],
        },
      },
      {
        'id': 'english_junior_012_grammar_plurals',
        'title': 'Making Plurals',
        'type': 'multipleChoice',
        'prompt': 'What is the plural of "book"?',
        'options': ['book', 'books', 'bookes', 'bookies'],
        'correctAnswer': 'books',
        'explanation':
            'To make most words plural, we add -s. Book becomes books.',
        'hint': 'Add -s to the end of the word.',
        'points': 20,
        'skills': ['grammar', 'plurals', 'spelling'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Grammar', 'Plurals'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['bubblePopGrammar'],
        'recommendedGameType': 'bubblePopGrammar',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Form regular plurals by adding -s',
          'prerequisiteSkills': ['basic-spelling'],
          'followUpSkills': ['irregular-plurals'],
        },
      },

      // FishTank Math Questions (Math - Junior)
      {
        'id': 'math_junior_017_addition_within_20',
        'title': 'Addition Within 20',
        'type': 'multipleChoice',
        'prompt': 'What is 8 + 7?',
        'options': ['13', '14', '15', '16'],
        'correctAnswer': '15',
        'explanation':
            '8 + 7 = 15. You can count on from 8: 9, 10, 11, 12, 13, 14, 15.',
        'hint': 'Start at 8 and count forward 7.',
        'points': 20,
        'skills': ['addition', 'counting-on', 'add-to-20'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Addition'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['fishTankQuiz'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Add numbers within 20',
          'prerequisiteSkills': ['counting-to-20'],
          'followUpSkills': ['addition-with-regrouping'],
        },
      },
      {
        'id': 'math_junior_018_subtraction_within_20',
        'title': 'Subtraction Within 20',
        'type': 'multipleChoice',
        'prompt': 'What is 15 - 6?',
        'options': ['8', '9', '10', '11'],
        'correctAnswer': '9',
        'explanation':
            '15 - 6 = 9. Start at 15 and count back 6: 14, 13, 12, 11, 10, 9.',
        'hint': 'Start at 15 and count backward 6.',
        'points': 20,
        'skills': ['subtraction', 'counting-back', 'subtract-from-20'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Subtraction'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['fishTankQuiz'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Subtract numbers within 20',
          'prerequisiteSkills': ['counting-to-20'],
          'followUpSkills': ['subtraction-with-borrowing'],
        },
      },
      {
        'id': 'math_junior_019_number_comparison',
        'title': 'Comparing Numbers',
        'type': 'multipleChoice',
        'prompt': 'Which number is greater: 14 or 19?',
        'options': ['14', '19', 'They are equal', 'Cannot tell'],
        'correctAnswer': '19',
        'explanation':
            '19 is greater than 14 because it comes after 14 when counting.',
        'hint': 'Think about which number comes later when counting.',
        'points': 20,
        'skills': ['number-comparison', 'greater-than', 'less-than'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Comparison'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['fishTankQuiz'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective':
              'Compare numbers using greater than and less than',
          'prerequisiteSkills': ['counting-to-20'],
          'followUpSkills': ['number-ordering'],
        },
      },
      {
        'id': 'math_junior_020_place_value_tens',
        'title': 'Place Value - Tens',
        'type': 'multipleChoice',
        'prompt': 'In the number 17, what digit is in the tens place?',
        'options': ['1', '7', '17', '0'],
        'correctAnswer': '1',
        'explanation':
            'In 17, the digit 1 is in the tens place, which means 1 ten or 10.',
        'hint': 'The tens place is the first digit from the left.',
        'points': 25,
        'skills': ['place-value', 'tens', 'number-structure'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Place Value'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['fishTankQuiz'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Understand place value in two-digit numbers',
          'prerequisiteSkills': ['counting-to-20'],
          'followUpSkills': ['place-value-hundreds'],
        },
      },
      {
        'id': 'math_junior_021_doubles_facts',
        'title': 'Doubles Facts',
        'type': 'multipleChoice',
        'prompt': 'What is 6 + 6?',
        'options': ['10', '11', '12', '13'],
        'correctAnswer': '12',
        'explanation':
            '6 + 6 = 12. This is a doubles fact - when you add a number to itself.',
        'hint': 'Think about adding the same number twice.',
        'points': 20,
        'skills': ['addition', 'doubles-facts', 'mental-math'],
        'subjects': ['math'],
        'ageGroups': ['junior'],
        'topics': ['Number', 'Addition'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['fishTankQuiz'],
        'recommendedGameType': 'fishTankQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective': 'Memorize doubles facts',
          'prerequisiteSkills': ['basic-addition'],
          'followUpSkills': ['near-doubles'],
        },
      },

      // Seashell Quiz Questions (English - Junior)
      {
        'id': 'english_junior_013_vocabulary_antonyms',
        'title': 'Understanding Antonyms',
        'type': 'multipleChoice',
        'prompt': 'What is the opposite of "hot"?',
        'options': ['warm', 'cold', 'cool', 'fire'],
        'correctAnswer': 'cold',
        'explanation':
            'Hot and cold are opposites, or antonyms. They mean the opposite of each other.',
        'hint': 'Think about the opposite temperature of hot.',
        'points': 20,
        'skills': ['vocabulary', 'antonyms', 'word-meaning'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Antonyms'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['seashellQuiz'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1',
          'learningObjective':
              'Identify antonyms - words with opposite meanings',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['synonyms'],
        },
      },
      {
        'id': 'english_junior_014_vocabulary_rhyming',
        'title': 'Rhyming Words',
        'type': 'multipleChoice',
        'prompt': 'Which word rhymes with "cat"?',
        'options': ['dog', 'bat', 'car', 'cup'],
        'correctAnswer': 'bat',
        'explanation':
            'Cat and bat rhyme because they end with the same sound: -at.',
        'hint': 'Listen for words that end with the same sound.',
        'points': 20,
        'skills': ['vocabulary', 'rhyming', 'phonemic-awareness'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Rhyming'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['seashellQuiz'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Identify rhyming words',
          'prerequisiteSkills': ['phonemic-awareness'],
          'followUpSkills': ['word-families'],
        },
      },
      {
        'id': 'english_junior_015_vocabulary_categories',
        'title': 'Word Categories',
        'type': 'multipleChoice',
        'prompt':
            'Which word does NOT belong with the others: apple, banana, car, orange?',
        'options': ['apple', 'banana', 'car', 'orange'],
        'correctAnswer': 'car',
        'explanation':
            'Apple, banana, and orange are all fruits. Car is not a fruit, so it does not belong.',
        'hint': 'Think about which word is different from the others.',
        'points': 20,
        'skills': ['vocabulary', 'categorization', 'word-classification'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Categories'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 35,
        'gameTypes': ['seashellQuiz'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Categorize words into groups',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['word-relationships'],
        },
      },
      {
        'id': 'english_junior_016_vocabulary_compound_words',
        'title': 'Compound Words',
        'type': 'multipleChoice',
        'prompt': 'What two words make up "sunshine"?',
        'options': ['sun + shine', 'sun + light', 'sun + day', 'sun + bright'],
        'correctAnswer': 'sun + shine',
        'explanation':
            'Sunshine is made from two words: sun and shine. When you put them together, you get sunshine.',
        'hint': 'Break the word into two parts.',
        'points': 25,
        'skills': ['vocabulary', 'compound-words', 'word-formation'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Compound Words'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 40,
        'gameTypes': ['seashellQuiz'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP 1/2',
          'learningObjective': 'Identify compound words and their parts',
          'prerequisiteSkills': ['basic-vocabulary'],
          'followUpSkills': ['word-analysis'],
        },
      },
      {
        'id': 'english_junior_017_vocabulary_sight_words',
        'title': 'Sight Words',
        'type': 'multipleChoice',
        'prompt': 'Which word is a sight word?',
        'options': ['elephant', 'the', 'beautiful', 'running'],
        'correctAnswer': 'the',
        'explanation':
            'The word "the" is a sight word - a common word that we recognize quickly without sounding it out.',
        'hint': 'Think about words you see very often in books.',
        'points': 20,
        'skills': ['vocabulary', 'sight-words', 'reading-fluency'],
        'subjects': ['reading'],
        'ageGroups': ['junior'],
        'topics': ['Vocabulary', 'Sight Words'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 30,
        'gameTypes': ['seashellQuiz'],
        'recommendedGameType': 'seashellQuiz',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'citation': 'PYP K/1',
          'learningObjective': 'Recognize common sight words',
          'prerequisiteSkills': ['letter-recognition'],
          'followUpSkills': ['reading-fluency'],
        },
      },
    ];
  }
}
