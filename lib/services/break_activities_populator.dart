import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to populate break activities and mindful games collection
/// Designed for break time relaxation, mindfulness, and fun activities
class BreakActivitiesPopulator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'breakActivities';

  /// Populate all break activities for Junior and Bright age groups
  Future<void> populateBreakActivities() async {
    try {
      debugPrint('🚀 Starting break activities population...');

      final juniorActivities = _createJuniorBreakActivities();
      final brightActivities = _createBrightBreakActivities();

      final batch = _firestore.batch();
      int count = 0;

      // Add Junior activities
      for (final activity in juniorActivities) {
        final docRef =
            _firestore.collection(collectionName).doc(activity['id'] as String);
        batch.set(docRef, activity);
        count++;
      }

      // Add Bright activities
      for (final activity in brightActivities) {
        final docRef =
            _firestore.collection(collectionName).doc(activity['id'] as String);
        batch.set(docRef, activity);
        count++;
      }

      await batch.commit();
      debugPrint('✅ Successfully populated $count break activity templates!');
    } catch (e) {
      debugPrint('❌ Error populating break activities: $e');
      rethrow;
    }
  }

  /// Create Junior (6-8) break activities - Simple, fun, calming
  List<Map<String, dynamic>> _createJuniorBreakActivities() {
    return [
      // Activity 1: Breathing Bubble Game
      {
        'id': 'break_junior_001_breathing_bubbles',
        'title': 'Bubble Breathing',
        'type': 'interactive',
        'prompt':
            'Let\'s blow bubbles together! Breathe in slowly, then blow out gently to create bubbles. Count how many bubbles you can make!',
        'instructions': [
          'Take a deep breath in (count to 3)',
          'Blow out slowly like you\'re blowing bubbles',
          'Watch the bubbles float away',
          'Repeat 3 times',
          'How do you feel now?'
        ],
        'points': 15,
        'skills': ['breathing', 'calm', 'focus'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Mindfulness', 'Breathing'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'activityType': 'breathing',
        'gameType': 'breathingBubble',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice calming breathing technique',
          'emotionalGoal': 'Calm and relax',
          'prerequisiteSkills': [],
          'followUpSkills': ['deep-breathing'],
        },
      },

      // Activity 2: Color the Mandala
      {
        'id': 'break_junior_002_coloring_mandala',
        'title': 'Color the Mandala',
        'type': 'creative',
        'prompt':
            'Choose your favorite colors and fill in the beautiful mandala! There\'s no right or wrong way - just have fun!',
        'instructions': [
          'Look at the mandala pattern',
          'Choose 3-5 colors you like',
          'Start coloring from the center out',
          'Take your time, no need to rush',
          'Enjoy creating something beautiful!'
        ],
        'points': 20,
        'skills': ['creativity', 'focus', 'calm'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Art', 'Mindfulness'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 300,
        'activityType': 'coloring',
        'gameType': 'coloringMandala',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice mindful coloring and focus',
          'emotionalGoal': 'Creative expression and calm',
          'prerequisiteSkills': [],
          'followUpSkills': ['pattern-recognition'],
        },
      },

      // Activity 3: Animal Yoga Poses
      {
        'id': 'break_junior_003_animal_yoga',
        'title': 'Animal Yoga Poses',
        'type': 'movement',
        'prompt':
            'Let\'s pretend to be animals! Can you do the cat pose? The dog pose? The butterfly pose?',
        'instructions': [
          'Watch each animal pose demonstration',
          'Try to copy the pose',
          'Hold the pose for 5 seconds',
          'Try the next animal pose',
          'Which animal pose felt best?'
        ],
        'options': [
          'Cat Pose',
          'Dog Pose',
          'Butterfly Pose',
          'Tree Pose',
          'Lion Pose'
        ],
        'points': 18,
        'skills': ['movement', 'body-awareness', 'calm'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Movement', 'Yoga'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 180,
        'activityType': 'movement',
        'gameType': 'animalYoga',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice simple yoga poses through play',
          'emotionalGoal': 'Energy and body awareness',
          'prerequisiteSkills': [],
          'followUpSkills': ['balance', 'flexibility'],
        },
      },

      // Activity 4: Gratitude Drawing
      {
        'id': 'break_junior_004_gratitude_drawing',
        'title': 'Gratitude Drawing',
        'type': 'creative',
        'prompt':
            'Think of something you\'re happy about today. Can you draw it? Maybe your favorite toy, a friend, or something fun you did!',
        'instructions': [
          'Think of something that made you happy today',
          'Draw a picture of it',
          'You can use colors, shapes, or anything you like!',
          'Tell yourself "I\'m grateful for..."',
          'Feel the happiness in your heart!'
        ],
        'points': 20,
        'skills': ['gratitude', 'creativity', 'emotions'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Gratitude', 'Emotions'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 240,
        'activityType': 'gratitude',
        'gameType': 'gratitudeDrawing',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice gratitude through creative expression',
          'emotionalGoal': 'Happiness and appreciation',
          'prerequisiteSkills': [],
          'followUpSkills': ['emotional-awareness'],
        },
      },

      // Activity 5: Musical Rhythm Tap
      {
        'id': 'break_junior_005_musical_rhythm',
        'title': 'Musical Rhythm Game',
        'type': 'rhythm',
        'prompt':
            'Listen to the beat and tap along! Follow the rhythm - fast, slow, fast, slow!',
        'instructions': [
          'Listen to the rhythm pattern',
          'Tap your finger or clap along',
          'Try to match the beat',
          'Speed up or slow down with the music',
          'Feel the rhythm in your body!'
        ],
        'points': 15,
        'skills': ['rhythm', 'listening', 'coordination'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Music', 'Rhythm'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 150,
        'activityType': 'music',
        'gameType': 'rhythmTap',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice rhythm and listening skills',
          'emotionalGoal': 'Fun and energy',
          'prerequisiteSkills': [],
          'followUpSkills': ['music-appreciation'],
        },
      },

      // Activity 6: Nature Sounds Listening
      {
        'id': 'break_junior_006_nature_sounds',
        'title': 'Nature Sounds Adventure',
        'type': 'mindfulness',
        'prompt':
            'Close your eyes and listen! Can you hear the birds? The rain? The ocean waves? Which sound is your favorite?',
        'instructions': [
          'Find a quiet place',
          'Close your eyes gently',
          'Listen carefully to each sound',
          'Try to guess what makes each sound',
          'Which sound made you feel most calm?'
        ],
        'options': [
          'Bird Chirping',
          'Rain Drops',
          'Ocean Waves',
          'Wind Blowing',
          'Forest Sounds'
        ],
        'points': 15,
        'skills': ['listening', 'calm', 'focus'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Mindfulness', 'Nature'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 180,
        'activityType': 'mindfulness',
        'gameType': 'natureSounds',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice mindful listening and calm',
          'emotionalGoal': 'Relaxation and peace',
          'prerequisiteSkills': [],
          'followUpSkills': ['meditation'],
        },
      },

      // Activity 7: Feelings Faces Game
      {
        'id': 'break_junior_007_feelings_faces',
        'title': 'Feelings Faces',
        'type': 'emotional',
        'prompt':
            'Look at the faces! Can you name how each person feels? Happy? Sad? Excited? Scared?',
        'instructions': [
          'Look at each face carefully',
          'Try to guess the feeling',
          'Think of a time you felt that way',
          'Share or draw about that feeling',
          'Remember: all feelings are okay!'
        ],
        'options': ['Happy', 'Sad', 'Excited', 'Calm', 'Proud', 'Worried'],
        'correctAnswer': 'All feelings are valid',
        'points': 18,
        'skills': ['emotional-awareness', 'empathy', 'vocabulary'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Emotions', 'Social Skills'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 180,
        'activityType': 'emotional',
        'gameType': 'feelingsFaces',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Recognize and name different emotions',
          'emotionalGoal': 'Emotional awareness and expression',
          'prerequisiteSkills': [],
          'followUpSkills': ['emotional-regulation'],
        },
      },

      // Activity 8: Simple Puzzle - Animal Match
      {
        'id': 'break_junior_008_animal_match',
        'title': 'Animal Friends Match',
        'type': 'puzzle',
        'prompt':
            'Help the animals find their friends! Match the mama animal with the baby animal!',
        'instructions': [
          'Look at all the animal cards',
          'Find the mama and baby pairs',
          'Tap to match them together',
          'Watch them celebrate!',
          'How many pairs did you find?'
        ],
        'points': 20,
        'skills': ['matching', 'problem-solving', 'focus'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Puzzle', 'Animals'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 180,
        'activityType': 'puzzle',
        'gameType': 'animalMatch',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice matching and pattern recognition',
          'emotionalGoal': 'Fun and achievement',
          'prerequisiteSkills': [],
          'followUpSkills': ['memory-games'],
        },
      },

      // Activity 9: Body Scan Relaxation
      {
        'id': 'break_junior_009_body_scan',
        'title': 'Body Scan Relaxation',
        'type': 'relaxation',
        'prompt':
            'Let\'s relax each part of your body! Start with your toes... wiggle them! Now your feet... your legs... all the way to your head!',
        'instructions': [
          'Lie down or sit comfortably',
          'Close your eyes',
          'Wiggle your toes and feet',
          'Move your arms gently',
          'Stretch your neck carefully',
          'Take a deep breath',
          'Feel your whole body relaxed!'
        ],
        'points': 18,
        'skills': ['relaxation', 'body-awareness', 'calm'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Relaxation', 'Mindfulness'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 210,
        'activityType': 'relaxation',
        'gameType': 'bodyScan',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice body awareness and relaxation',
          'emotionalGoal': 'Calm and relaxation',
          'prerequisiteSkills': [],
          'followUpSkills': ['progressive-relaxation'],
        },
      },

      // Activity 10: Happy Dance Movement
      {
        'id': 'break_junior_010_happy_dance',
        'title': 'Happy Dance Party',
        'type': 'movement',
        'prompt':
            'Time for a dance party! Move your body to the happy music! Dance like nobody\'s watching!',
        'instructions': [
          'Stand up and find some space',
          'Play the happy music',
          'Move your body however feels good!',
          'Jump, spin, wiggle - have fun!',
          'Feel the happiness in your body!'
        ],
        'points': 15,
        'skills': ['movement', 'joy', 'energy'],
        'subjects': ['wellbeing'],
        'ageGroups': ['junior'],
        'topics': ['Movement', 'Joy'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 120,
        'activityType': 'movement',
        'gameType': 'happyDance',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Express joy through movement',
          'emotionalGoal': 'Happiness and energy release',
          'prerequisiteSkills': [],
          'followUpSkills': ['self-expression'],
        },
      },
    ];
  }

  /// Create Bright (9-12) break activities - More sophisticated, engaging
  List<Map<String, dynamic>> _createBrightBreakActivities() {
    return [
      // Activity 1: Mindful Breathing Challenge
      {
        'id': 'break_bright_001_breathing_challenge',
        'title': 'Breathing Challenge',
        'type': 'interactive',
        'prompt':
            'Follow the breathing pattern on screen! Breathe in for 4 counts, hold for 4, breathe out for 4, hold for 4. Can you complete 3 rounds?',
        'instructions': [
          'Watch the breathing guide on screen',
          'Breathe in through your nose (count 1-2-3-4)',
          'Hold your breath (count 1-2-3-4)',
          'Breathe out through your mouth (count 1-2-3-4)',
          'Hold empty (count 1-2-3-4)',
          'Repeat for 3 rounds',
          'Notice how you feel after!'
        ],
        'points': 25,
        'skills': ['breathing', 'calm', 'self-regulation'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Mindfulness', 'Breathing'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 180,
        'activityType': 'breathing',
        'gameType': 'breathingChallenge',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective':
              'Master box breathing technique for stress management',
          'emotionalGoal': 'Calm and focus',
          'prerequisiteSkills': ['basic-breathing'],
          'followUpSkills': ['advanced-meditation'],
        },
      },

      // Activity 2: Creative Drawing Challenge
      {
        'id': 'break_bright_002_creative_challenge',
        'title': 'Creative Drawing Challenge',
        'type': 'creative',
        'prompt':
            'You have 3 minutes to create something amazing! Use these shapes: circle, triangle, square. What can you make?',
        'instructions': [
          'Look at the provided shapes',
          'Set a timer for 3 minutes',
          'Create something unique using the shapes',
          'There\'s no wrong answer - be creative!',
          'Share what you created (if you want)'
        ],
        'points': 30,
        'skills': ['creativity', 'problem-solving', 'self-expression'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Art', 'Creativity'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 180,
        'activityType': 'creative',
        'gameType': 'creativeDrawing',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Encourage creative thinking and expression',
          'emotionalGoal': 'Satisfaction and self-expression',
          'prerequisiteSkills': ['basic-drawing'],
          'followUpSkills': ['advanced-art'],
        },
      },

      // Activity 3: Guided Meditation Journey
      {
        'id': 'break_bright_003_meditation_journey',
        'title': 'Mindful Journey Meditation',
        'type': 'meditation',
        'prompt':
            'Close your eyes and imagine a peaceful place. Maybe a beach, a forest, or a favorite spot. Let\'s take a 5-minute journey there!',
        'instructions': [
          'Find a comfortable, quiet spot',
          'Close your eyes gently',
          'Listen to the guided journey',
          'Follow along with the visualization',
          'Notice your breathing',
          'When finished, slowly open your eyes',
          'Take a moment to feel refreshed'
        ],
        'points': 30,
        'skills': ['meditation', 'visualization', 'calm'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Meditation', 'Mindfulness'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 300,
        'activityType': 'meditation',
        'gameType': 'guidedMeditation',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice guided meditation and visualization',
          'emotionalGoal': 'Peace and mental clarity',
          'prerequisiteSkills': ['basic-breathing'],
          'followUpSkills': ['self-guided-meditation'],
        },
      },

      // Activity 4: Gratitude Journal Entry
      {
        'id': 'break_bright_004_gratitude_journal',
        'title': 'Gratitude Journal',
        'type': 'writing',
        'prompt':
            'Write about 3 things you\'re grateful for today. They can be big or small - what matters is they made you feel good!',
        'instructions': [
          'Think about your day so far',
          'Write down 3 things you\'re grateful for',
          'For each one, write why it made you feel good',
          'Draw a small picture if you want',
          'Read them back to yourself',
          'Feel the gratitude in your heart!'
        ],
        'points': 25,
        'skills': ['gratitude', 'writing', 'self-reflection'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Gratitude', 'Journaling'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 240,
        'activityType': 'journaling',
        'gameType': 'gratitudeJournal',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice gratitude through journaling',
          'emotionalGoal': 'Happiness and appreciation',
          'prerequisiteSkills': ['basic-writing'],
          'followUpSkills': ['advanced-journaling'],
        },
      },

      // Activity 5: Sudoku or Word Search
      {
        'id': 'break_bright_005_puzzle_challenge',
        'title': 'Puzzle Challenge',
        'type': 'puzzle',
        'prompt':
            'Choose your challenge: Easy Sudoku or Word Search! Take your time and enjoy solving it!',
        'instructions': [
          'Choose: Sudoku or Word Search',
          'Read the instructions',
          'Start solving at your own pace',
          'There\'s no time limit - enjoy it!',
          'Celebrate when you finish!'
        ],
        'options': [
          'Sudoku (Easy)',
          'Word Search',
          'Crossword (Easy)',
          'Number Puzzle'
        ],
        'points': 30,
        'skills': ['problem-solving', 'logic', 'focus'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Puzzle', 'Logic'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 300,
        'activityType': 'puzzle',
        'gameType': 'puzzleChallenge',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice problem-solving through puzzles',
          'emotionalGoal': 'Satisfaction and mental stimulation',
          'prerequisiteSkills': ['basic-logic'],
          'followUpSkills': ['advanced-puzzles'],
        },
      },

      // Activity 6: Music Creation - Beat Maker
      {
        'id': 'break_bright_006_beat_maker',
        'title': 'Beat Maker Studio',
        'type': 'music',
        'prompt':
            'Create your own beat! Mix different sounds to make a rhythm you love. Record your creation!',
        'instructions': [
          'Choose your sound instruments',
          'Tap to create a beat pattern',
          'Try different combinations',
          'Listen to your creation',
          'Save it if you like it!'
        ],
        'points': 35,
        'skills': ['creativity', 'music', 'rhythm'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Music', 'Creativity'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 300,
        'activityType': 'music',
        'gameType': 'beatMaker',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Express creativity through music creation',
          'emotionalGoal': 'Fun and creative satisfaction',
          'prerequisiteSkills': ['basic-rhythm'],
          'followUpSkills': ['music-composition'],
        },
      },

      // Activity 7: Positive Affirmations Game
      {
        'id': 'break_bright_007_affirmations',
        'title': 'Positive Affirmations',
        'type': 'emotional',
        'prompt':
            'Read these positive messages and choose 3 that feel right for you today. Say them to yourself and believe them!',
        'instructions': [
          'Read each affirmation',
          'Choose 3 that feel meaningful today',
          'Say each one out loud or in your mind',
          'Think about why they\'re true for you',
          'Carry these positive thoughts with you!'
        ],
        'options': [
          'I am capable and strong',
          'I can learn anything I put my mind to',
          'I am kind and helpful',
          'I am creative and unique',
          'I can solve problems',
          'I am growing every day',
          'I believe in myself'
        ],
        'points': 25,
        'skills': ['self-esteem', 'positive-thinking', 'emotional-wellbeing'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Self-Esteem', 'Positive Thinking'],
        'difficultyLevel': 'easy',
        'estimatedTimeSeconds': 180,
        'activityType': 'emotional',
        'gameType': 'affirmations',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective':
              'Build self-esteem through positive affirmations',
          'emotionalGoal': 'Confidence and self-worth',
          'prerequisiteSkills': ['emotional-awareness'],
          'followUpSkills': ['self-compassion'],
        },
      },

      // Activity 8: Mindful Walking Guide
      {
        'id': 'break_bright_008_mindful_walking',
        'title': 'Mindful Walking',
        'type': 'movement',
        'prompt':
            'Take a 3-minute mindful walk. Notice your steps, your breathing, and the world around you. Walk slowly and deliberately!',
        'instructions': [
          'Find a safe place to walk',
          'Start walking slowly',
          'Notice each step you take',
          'Feel your feet touching the ground',
          'Breathe in rhythm with your steps',
          'Notice what you see, hear, and feel',
          'Finish with a deep breath'
        ],
        'points': 28,
        'skills': ['mindfulness', 'movement', 'awareness'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Mindfulness', 'Movement'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 180,
        'activityType': 'movement',
        'gameType': 'mindfulWalking',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice mindfulness in motion',
          'emotionalGoal': 'Calm and awareness',
          'prerequisiteSkills': ['basic-mindfulness'],
          'followUpSkills': ['advanced-mindfulness'],
        },
      },

      // Activity 9: Emotional Check-in Wheel
      {
        'id': 'break_bright_009_emotion_wheel',
        'title': 'Emotion Check-in Wheel',
        'type': 'emotional',
        'prompt':
            'How are you feeling right now? Use the emotion wheel to explore and name your feelings. All feelings are valid!',
        'instructions': [
          'Look at the emotion wheel',
          'Identify your main feeling',
          'Explore related emotions',
          'Think about what might be causing this feeling',
          'Consider what might help',
          'Remember: feelings change!'
        ],
        'options': [
          'Happy',
          'Calm',
          'Excited',
          'Worried',
          'Frustrated',
          'Proud',
          'Curious',
          'Grateful'
        ],
        'points': 25,
        'skills': [
          'emotional-awareness',
          'self-reflection',
          'emotional-regulation'
        ],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Emotions', 'Self-Awareness'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 240,
        'activityType': 'emotional',
        'gameType': 'emotionWheel',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective':
              'Develop emotional vocabulary and self-awareness',
          'emotionalGoal': 'Understanding and acceptance of emotions',
          'prerequisiteSkills': ['basic-emotional-awareness'],
          'followUpSkills': ['emotional-regulation-strategies'],
        },
      },

      // Activity 10: Creative Story Starters
      {
        'id': 'break_bright_010_story_starters',
        'title': 'Creative Story Starters',
        'type': 'creative',
        'prompt':
            'Pick a story starter and write the beginning of your own story! What happens next? Let your imagination run wild!',
        'instructions': [
          'Read the story starters',
          'Pick one that inspires you',
          'Write the beginning of your story',
          'Be creative - there\'s no right answer!',
          'You can finish it later if you want'
        ],
        'options': [
          'Once upon a time, in a land where colors could be heard...',
          'The mysterious door appeared only at midnight...',
          'When I looked in the mirror, I saw...',
          'The message in the bottle said...',
          'In a world where gravity worked differently...'
        ],
        'points': 30,
        'skills': ['creativity', 'writing', 'imagination'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Creative Writing', 'Imagination'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 300,
        'activityType': 'creative',
        'gameType': 'storyStarters',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Encourage creative writing and imagination',
          'emotionalGoal': 'Creative expression and fun',
          'prerequisiteSkills': ['basic-writing'],
          'followUpSkills': ['advanced-writing'],
        },
      },

      // Activity 11: Progressive Muscle Relaxation
      {
        'id': 'break_bright_011_progressive_relaxation',
        'title': 'Progressive Muscle Relaxation',
        'type': 'relaxation',
        'prompt':
            'Tense and relax each muscle group! Start with your feet, work your way up to your head. Feel the tension release!',
        'instructions': [
          'Find a comfortable position',
          'Tense your feet muscles (5 seconds)',
          'Release and relax',
          'Move to your legs, tense and release',
          'Continue with each body part',
          'Finish with a full-body stretch',
          'Notice how relaxed you feel!'
        ],
        'points': 30,
        'skills': ['relaxation', 'body-awareness', 'stress-management'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Relaxation', 'Stress Management'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 300,
        'activityType': 'relaxation',
        'gameType': 'progressiveRelaxation',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Learn progressive muscle relaxation technique',
          'emotionalGoal': 'Deep relaxation and stress relief',
          'prerequisiteSkills': ['body-awareness'],
          'followUpSkills': ['advanced-relaxation'],
        },
      },

      // Activity 12: Mandala Coloring Challenge
      {
        'id': 'break_bright_012_mandala_challenge',
        'title': 'Mandala Coloring Challenge',
        'type': 'creative',
        'prompt':
            'Color this complex mandala! Choose a color scheme (warm colors, cool colors, or rainbow) and create something beautiful!',
        'instructions': [
          'Choose your color scheme',
          'Start from the center or edges - your choice!',
          'Take your time - this is about the process, not speed',
          'Enjoy the repetitive, calming motion',
          'Notice how you feel while coloring'
        ],
        'points': 35,
        'skills': ['creativity', 'focus', 'calm', 'patience'],
        'subjects': ['wellbeing'],
        'ageGroups': ['bright'],
        'topics': ['Art', 'Mindfulness'],
        'difficultyLevel': 'medium',
        'estimatedTimeSeconds': 450,
        'activityType': 'coloring',
        'gameType': 'mandalaColoring',
        'isActive': true,
        'isBreakActivity': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'learningObjective': 'Practice focused, mindful coloring',
          'emotionalGoal': 'Calm and creative satisfaction',
          'prerequisiteSkills': ['basic-coloring'],
          'followUpSkills': ['advanced-art-techniques'],
        },
      },
    ];
  }
}
