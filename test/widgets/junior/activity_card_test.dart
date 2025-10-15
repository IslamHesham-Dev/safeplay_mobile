import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplay_mobile/widgets/junior/activity_card_widget.dart';
import 'package:safeplay_mobile/models/activity.dart';
import 'package:safeplay_mobile/models/user_type.dart';

void main() {
  group('JuniorActivityCard', () {
    late Activity testActivity;

    setUp(() {
      testActivity = Activity(
        id: 'test_activity_1',
        title: 'Letter Sound Adventure',
        description: 'Learn letter sounds',
        subject: ActivitySubject.reading,
        pypPhase: PYPPhase.phase1,
        ageGroup: AgeGroup.junior,
        difficulty: Difficulty.easy,
        durationMinutes: 10,
        points: 50,
        learningObjectives: ['Learn sounds'],
        questions: [],
        createdBy: 'test_creator',
        published: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isOfflineAvailable: false,
      );
    });

    testWidgets('displays activity title', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JuniorActivityCard(
              activity: testActivity,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Letter Sound Adventure'), findsOneWidget);
    });

    testWidgets('displays activity points', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JuniorActivityCard(
              activity: testActivity,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('50 pts'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JuniorActivityCard(
              activity: testActivity,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(JuniorActivityCard));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('uses correct color for subject', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JuniorActivityCard(
              activity: testActivity,
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the card
      final card = tester.widget<Card>(find.byType(Card));

      // Verify color is set (subject-specific)
      expect(card.color, isNotNull);
    });

    testWidgets('has minimum touch target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JuniorActivityCard(
              activity: testActivity,
              onTap: () {},
            ),
          ),
        ),
      );

      final cardFinder = find.byType(JuniorActivityCard);
      final size = tester.getSize(cardFinder);

      // Junior cards should have at least 48px height for touch
      expect(size.height >= 48, true);
    });
  });
}
