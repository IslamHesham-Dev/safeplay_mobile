import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Story Sequencer Game Widget
/// For sequencing story events
class StorySequencerGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const StorySequencerGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<StorySequencerGame> createState() => _StorySequencerGameState();
}

class _StorySequencerGameState extends State<StorySequencerGame> {
  List<String> _sequence = [];
  List<String> _availableOptions = [];
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _availableOptions = List.from(widget.question.options);
  }

  void _checkAnswer() {
    final correctAnswer = widget.question.correctAnswer;
    final isCorrect = _isAnswerCorrect(_sequence, correctAnswer);

    setState(() {
      _hasSubmitted = true;
    });

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: _sequence,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.question.points : 0,
    );
  }

  bool _isAnswerCorrect(List<String> userAnswer, dynamic correctAnswer) {
    if (correctAnswer is List) {
      return userAnswer.toString() == correctAnswer.toString();
    }
    return userAnswer.toString() == correctAnswer.toString();
  }

  void _addToSequence(String item) {
    setState(() {
      _availableOptions.remove(item);
      _sequence.add(item);
    });
  }

  void _removeFromSequence(int index) {
    setState(() {
      final item = _sequence.removeAt(index);
      _availableOptions.add(item);
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
          // Sequence area
          SizedBox(
            height: 200,
            child: Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                color: JuniorTheme.backgroundLight,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
              ),
              child: _sequence.isEmpty
                  ? Center(
                      child: Text(
                        'Tap events to put them in order',
                        style: JuniorTheme.bodyMedium.copyWith(
                          color: JuniorTheme.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: _sequence.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: JuniorTheme.spacingSmall),
                          child: GestureDetector(
                            onTap: () => _removeFromSequence(entry.key),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                  JuniorTheme.spacingMedium),
                              decoration: BoxDecoration(
                                color: JuniorTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(
                                    JuniorTheme.radiusMedium),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: JuniorTheme.bodySmall.copyWith(
                                          color: JuniorTheme.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: JuniorTheme.spacingMedium),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: JuniorTheme.bodyMedium.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          // Available options
          if (_availableOptions.isNotEmpty) ...[
            Text('Available events:'),
            const SizedBox(height: JuniorTheme.spacingMedium),
            ..._availableOptions.map((option) {
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
                child: GestureDetector(
                  onTap: () => _addToSequence(option),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryBlue,
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusMedium),
                      border:
                          Border.all(color: JuniorTheme.primaryBlue, width: 2),
                    ),
                    child: Text(
                      option,
                      style: JuniorTheme.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: JuniorTheme.spacingLarge),
          if (_sequence.length == widget.question.options.length) ...[
            GestureDetector(
              onTap: _hasSubmitted ? null : _checkAnswer,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: JuniorTheme.spacingMedium),
                decoration: BoxDecoration(
                  gradient: _hasSubmitted
                      ? LinearGradient(colors: [
                          JuniorTheme.textLight,
                          JuniorTheme.textLight
                        ])
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
        ],
      ),
    );
  }
}
