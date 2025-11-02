import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../services/question_template_populator.dart';
import '../firebase_options.dart';

/// Script to populate Firebase with Math question templates
/// NOTE: Instead of running this script, use the UI:
/// Go to Teacher Dashboard → Quick Actions → "Populate Questions"
///
/// If you must run this script, ensure Firebase is properly initialized first.
void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('🚀 Starting Math questions population...');

    final populator = QuestionTemplatePopulator();
    await populator.populateMathQuestions();

    debugPrint('✅ Successfully populated all Math questions!');
  } catch (e, stackTrace) {
    debugPrint('❌ Error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}
