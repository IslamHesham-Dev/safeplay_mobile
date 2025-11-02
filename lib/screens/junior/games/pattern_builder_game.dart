import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Pattern Builder Game Widget
/// For questions about patterns and sequences
class PatternBuilderGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const PatternBuilderGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<PatternBuilderGame> createState() => _PatternBuilderGameState();
}

class _PatternBuilderGameState extends State<PatternBuilderGame> {
  List<String> _selectedPattern = [];
  List<String> _availableOptions = [];
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _availableOptions = List.from(widget.question.options);
  }

  void _checkAnswer() {
    final correctAnswer = widget.question.correctAnswer;
    final isCorrect = _isAnswerCorrect(_selectedPattern, correctAnswer);

    setState(() {
      _hasSubmitted = true;
    });

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: _selectedPattern,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.question.points : 0,
    );
  }

  bool _isAnswerCorrect(List<String> userAnswer, dynamic correctAnswer) {
    if (correctAnswer is List) {
      return userAnswer.toString() == correctAnswer.toString();
    }
    return userAnswer.isNotEmpty &&
        userAnswer.first == correctAnswer.toString();
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedPattern.contains(option)) {
        _selectedPattern.remove(option);
        _availableOptions.add(option);
      } else {
        _availableOptions.remove(option);
        _selectedPattern.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowMedium,
            ),
            child: Text(
              widget.question.question,
              style: JuniorTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          Wrap(
            spacing: JuniorTheme.spacingSmall,
            runSpacing: JuniorTheme.spacingSmall,
            children: _availableOptions.map((option) {
              final isSelected = _selectedPattern.contains(option);
              return GestureDetector(
                onTap: () => _toggleOption(option),
                child: Container(
                  padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? JuniorTheme.primaryGreen
                        : JuniorTheme.primaryBlue,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                    border: Border.all(
                      color: isSelected
                          ? JuniorTheme.primaryGreen
                          : JuniorTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    option,
                    style: JuniorTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          GestureDetector(
            onTap: _hasSubmitted ? null : _checkAnswer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: _hasSubmitted
                    ? LinearGradient(
                        colors: [JuniorTheme.textLight, JuniorTheme.textLight])
                    : JuniorTheme.primaryGradient,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
                boxShadow: JuniorTheme.shadowMedium,
              ),
              child: Text(
                _hasSubmitted ? 'Answer Submitted!' : 'Check Answer',
                style: JuniorTheme.buttonText.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
