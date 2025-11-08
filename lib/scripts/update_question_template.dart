import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/question_template_populator.dart';
import '../firebase_options.dart';

/// Script to update a specific question template in Firestore
///
/// Usage: Call this script to update the english_junior_006_comprehension_fact
/// template from a comprehension question to a vocabulary/synonyms question.
///
/// Run with: flutter run lib/scripts/update_question_template.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    print('📡 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    final populator = QuestionTemplatePopulator();

    print('🔄 Starting template update...');

    // Update the specific template
    await populator
        .updateQuestionTemplate('english_junior_006_comprehension_fact');

    print('✅ Template update completed successfully!');
  } catch (e) {
    print('❌ Error updating template: $e');
    rethrow;
  }
}
