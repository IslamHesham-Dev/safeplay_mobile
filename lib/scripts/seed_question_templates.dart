import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedQuestionTemplates() async {
  final firestore = FirebaseFirestore.instance;
  final col = firestore.collection('questionTemplates');

  final batch = firestore.batch();

  final templates = [
    {
      'title': 'Skip Counting Race',
      'type': 'multiple-choice',
      'prompt': 'What comes next? 10, 20, 30, __',
      'options': ['35', '40', '25', '31'],
      'correctAnswer': '40',
      'points': 20,
      'skills': ['skip-counting', 'number patterns'],
    },
    {
      'title': 'Conjunction Builder',
      'type': 'multiple-choice',
      'prompt': 'Choose the best conjunction: I like apples __ oranges.',
      'options': ['and', 'but', 'because', 'or'],
      'correctAnswer': 'and',
      'points': 10,
      'skills': ['grammar', 'conjunctions'],
    },
    {
      'title': 'Compensation Subtraction',
      'type': 'text-input',
      'prompt': 'Use compensation: 85 - 19 = ?',
      'correctAnswer': '66',
      'points': 20,
      'skills': ['mental-strategy', 'subtraction'],
    },
  ];

  for (final t in templates) {
    final ref = col.doc();
    batch.set(ref, t);
  }

  await batch.commit();
}
