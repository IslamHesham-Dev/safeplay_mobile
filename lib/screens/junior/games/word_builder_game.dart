import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Word Builder Game Widget
/// For building words from letters or syllables
class WordBuilderGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const WordBuilderGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  List<String> _selectedLetters = [];
  List<String> _availableLetters = [];
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _availableLetters = List.from(widget.question.options);
  }

  void _checkAnswer() {
    final builtWord = _selectedLetters.join('');
    final correctAnswer = widget.question.correctAnswer;
    final isCorrect = _isAnswerCorrect(builtWord, correctAnswer);

    setState(() {
      _hasSubmitted = true;
    });

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: builtWord,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.question.points : 0,
    );
  }

  bool _isAnswerCorrect(String userAnswer, dynamic correctAnswer) {
    if (correctAnswer is List) {
      return correctAnswer.contains(userAnswer);
    }
    return userAnswer.toLowerCase() == correctAnswer.toString().toLowerCase();
  }

  void _addLetter(String letter) {
    setState(() {
      if (_availableLetters.contains(letter)) {
        _availableLetters.remove(letter);
        _selectedLetters.add(letter);
      }
    });
  }

  void _removeLetter(int index) {
    setState(() {
      final letter = _selectedLetters.removeAt(index);
      _availableLetters.add(letter);
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
          // Built word area
          SizedBox(
            height: 80,
            child: Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                color: JuniorTheme.backgroundLight,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
              ),
              child: _selectedLetters.isEmpty
                  ? Center(
                      child: Text(
                        'Tap letters to build the word',
                        style: JuniorTheme.bodyMedium.copyWith(
                          color: JuniorTheme.textSecondary,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: JuniorTheme.spacingSmall,
                      children: _selectedLetters.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _removeLetter(entry.key),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: JuniorTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(
                                  JuniorTheme.radiusMedium),
                            ),
                            child: Center(
                              child: Text(
                                entry.value,
                                style: JuniorTheme.headingMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          // Available letters
          Wrap(
            spacing: JuniorTheme.spacingSmall,
            runSpacing: JuniorTheme.spacingSmall,
            children: _availableLetters.map((letter) {
              return GestureDetector(
                onTap: () => _addLetter(letter),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryBlue,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                    border:
                        Border.all(color: JuniorTheme.primaryBlue, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: JuniorTheme.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          GestureDetector(
            onTap:
                _hasSubmitted || _selectedLetters.isEmpty ? null : _checkAnswer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: _hasSubmitted || _selectedLetters.isEmpty
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
