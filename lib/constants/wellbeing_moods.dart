import 'package:flutter/material.dart';

class WellbeingMoodDefinition {
  final String label;
  final String emoji;
  final Color color;
  final List<Color> gradient;
  final int score;

  const WellbeingMoodDefinition({
    required this.label,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.score,
  });
}

const List<WellbeingMoodDefinition> kWellbeingMoods = [
  WellbeingMoodDefinition(
    label: 'Amazing',
    emoji: '🤩',
    color: Color(0xFF4CAF50),
    gradient: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    score: 95,
  ),
  WellbeingMoodDefinition(
    label: 'Happy',
    emoji: '😄',
    color: Color(0xFF2196F3),
    gradient: [Color(0xFF2196F3), Color(0xFF42A5F5)],
    score: 88,
  ),
  WellbeingMoodDefinition(
    label: 'Good',
    emoji: '🙂',
    color: Color(0xFF00BCD4),
    gradient: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
    score: 78,
  ),
  WellbeingMoodDefinition(
    label: 'Okay',
    emoji: '😐',
    color: Color(0xFFFF9800),
    gradient: [Color(0xFFFF9800), Color(0xFFFFA726)],
    score: 62,
  ),
  WellbeingMoodDefinition(
    label: 'Sad',
    emoji: '😢',
    color: Color(0xFF9C27B0),
    gradient: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
    score: 45,
  ),
  WellbeingMoodDefinition(
    label: 'Upset',
    emoji: '😡',
    color: Color(0xFFE91E63),
    gradient: [Color(0xFFE91E63), Color(0xFFEC407A)],
    score: 30,
  ),
];

WellbeingMoodDefinition moodDefinitionForLabel(String label) {
  return kWellbeingMoods.firstWhere(
    (mood) => mood.label.toLowerCase() == label.toLowerCase(),
    orElse: () => kWellbeingMoods.first,
  );
}

WellbeingMoodDefinition moodDefinitionForScore(double score) {
  final sorted = [...kWellbeingMoods]
    ..sort((a, b) => b.score.compareTo(a.score));
  for (final mood in sorted) {
    if (score >= mood.score) {
      return mood;
    }
  }
  return sorted.last;
}
