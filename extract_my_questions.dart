import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

/// Script to extract questions added by the current teacher account
Future<void> main() async {
  print('🚀 Extracting Your Teacher Questions...\n');

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully\n');

    final firestore = FirebaseFirestore.instance;

    // Extract question templates
    print('📚 Your Question Templates...');
    print('=' * 50);
    await _extractMyTemplates(firestore);

    // Extract questions from your activities
    print('\n📝 Questions from Your Activities...');
    print('=' * 50);
    await _extractMyActivityQuestions(firestore);

    print('\n✅ Extraction completed!');
  } catch (e) {
    print('❌ Error during extraction: $e');
    exit(1);
  }
}

/// Extract question templates from the database
Future<void> _extractMyTemplates(FirebaseFirestore firestore) async {
  try {
    final snapshot = await firestore
        .collection('questionTemplates')
        .where('isActive', isEqualTo: true)
        .orderBy('title')
        .get();

    if (snapshot.docs.isEmpty) {
      print('No question templates found in the database.');
      return;
    }

    print('Found ${snapshot.docs.length} question templates:\n');

    for (int i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      final data = doc.data();

      print('${i + 1}. Template: ${data['title'] ?? 'Untitled'}');
      print('   ID: ${doc.id}');
      print('   Type: ${data['type'] ?? 'Unknown'}');
      print('   Prompt: ${data['prompt'] ?? data['question'] ?? 'No prompt'}');

      if (data['options'] != null && data['options'] is List) {
        final options = data['options'] as List;
        if (options.isNotEmpty) {
          print('   Options:');
          for (int j = 0; j < options.length; j++) {
            print('     ${j + 1}. ${options[j]}');
          }
        }
      }

      print('   Correct Answer: ${data['correctAnswer'] ?? 'Not specified'}');
      print('   Points: ${data['points'] ?? 0}');

      if (data['skills'] != null && data['skills'] is List) {
        final skills = data['skills'] as List;
        if (skills.isNotEmpty) {
          print('   Skills: ${skills.join(', ')}');
        }
      }

      if (data['ageGroups'] != null && data['ageGroups'] is List) {
        final ageGroups = data['ageGroups'] as List;
        if (ageGroups.isNotEmpty) {
          print('   Age Groups: ${ageGroups.join(', ')}');
        }
      }

      if (data['subjects'] != null && data['subjects'] is List) {
        final subjects = data['subjects'] as List;
        if (subjects.isNotEmpty) {
          print('   Subjects: ${subjects.join(', ')}');
        }
      }

      if (data['explanation'] != null) {
        print('   Explanation: ${data['explanation']}');
      }

      if (data['hint'] != null) {
        print('   Hint: ${data['hint']}');
      }

      print('');
    }
  } catch (e) {
    print('❌ Error loading question templates: $e');
  }
}

/// Extract questions from teacher-created activities
Future<void> _extractMyActivityQuestions(FirebaseFirestore firestore) async {
  try {
    // Get all activities (we'll filter by createdBy if we can identify the teacher)
    final activitiesSnapshot = await firestore
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .get();

    if (activitiesSnapshot.docs.isEmpty) {
      print('No activities found in the database.');
      return;
    }

    print('Found ${activitiesSnapshot.docs.length} activities:\n');

    for (int i = 0; i < activitiesSnapshot.docs.length; i++) {
      final doc = activitiesSnapshot.docs[i];
      final data = doc.data();

      print('Activity ${i + 1}: ${data['title'] ?? 'Untitled Activity'}');
      print('   ID: ${doc.id}');
      print('   Created by: ${data['createdBy'] ?? 'Unknown'}');
      print('   Subject: ${data['subject'] ?? 'Unknown'}');
      print('   Age Group: ${data['ageGroup'] ?? 'Unknown'}');
      print('   Difficulty: ${data['difficulty'] ?? 'Unknown'}');
      print('   Publish State: ${data['publishState'] ?? 'Unknown'}');

      if (data['questions'] != null && data['questions'] is List) {
        final questions = data['questions'] as List;
        print('   Questions (${questions.length}):');

        for (int j = 0; j < questions.length; j++) {
          final question = questions[j] as Map<String, dynamic>;
          print(
              '     Question ${j + 1}: ${question['question'] ?? question['prompt'] ?? 'No question text'}');
          print('       Type: ${question['type'] ?? 'Unknown'}');
          print('       ID: ${question['id'] ?? 'No ID'}');

          if (question['options'] != null && question['options'] is List) {
            final options = question['options'] as List;
            if (options.isNotEmpty) {
              print('       Options:');
              for (int k = 0; k < options.length; k++) {
                print('         ${k + 1}. ${options[k]}');
              }
            }
          }

          print(
              '       Correct Answer: ${question['correctAnswer'] ?? 'Not specified'}');
          print('       Points: ${question['points'] ?? 0}');

          if (question['explanation'] != null) {
            print('       Explanation: ${question['explanation']}');
          }

          if (question['hint'] != null) {
            print('       Hint: ${question['hint']}');
          }

          print('');
        }
      } else {
        print('   No questions found in this activity.');
      }

      print('   ' + '-' * 40);
      print('');
    }
  } catch (e) {
    print('❌ Error loading activities: $e');
  }
}
