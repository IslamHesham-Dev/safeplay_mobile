import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplay_mobile/models/activity.dart';
import 'package:safeplay_mobile/widgets/activities/question_widget.dart';

void main() {
  group('QuestionWidget', () {
    testWidgets('renders ordering controls for drag-drop questions',
        (tester) async {
      final question = ActivityQuestion(
        id: 'drag-1',
        type: QuestionType.dragDrop,
        question: 'Order the numbers from smallest to largest.',
        options: const ['Three', 'One', 'Two'],
        correctAnswer: const ['One', 'Two', 'Three'],
        points: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showFeedback: false,
              isCorrect: false,
              onAnswerSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsWidgets);
      expect(find.text('Submit order'), findsOneWidget);
    });

    testWidgets('renders chips for matching questions', (tester) async {
      final question = ActivityQuestion(
        id: 'match-1',
        type: QuestionType.matching,
        question: 'Match the planet names to their descriptions.',
        options: const ['Earth', 'Mars', 'Jupiter'],
        correctAnswer: const ['Earth', 'Mars'],
        points: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showFeedback: false,
              isCorrect: false,
              onAnswerSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ChoiceChip), findsNWidgets(question.options.length));
    });
  });
}
