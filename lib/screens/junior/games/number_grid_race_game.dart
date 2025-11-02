import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Number Grid Race Game Widget
/// For questions about skip counting, number patterns, and sequences
class NumberGridRaceGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const NumberGridRaceGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<NumberGridRaceGame> createState() => _NumberGridRaceGameState();
}

class _NumberGridRaceGameState extends State<NumberGridRaceGame>
    with TickerProviderStateMixin {
  late TextEditingController _answerController;
  String? _userAnswer;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_userAnswer == null || _userAnswer!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an answer!'),
          backgroundColor: JuniorTheme.primaryYellow,
        ),
      );
      return;
    }

    setState(() {
      _hasSubmitted = true;
    });

    final isCorrect =
        _isAnswerCorrect(_userAnswer!, widget.question.correctAnswer);

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: _userAnswer,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.question.points : 0,
    );
  }

  bool _isAnswerCorrect(String userAnswer, dynamic correctAnswer) {
    if (correctAnswer is String) {
      return userAnswer.trim().toLowerCase() ==
          correctAnswer.toString().toLowerCase();
    } else if (correctAnswer is List) {
      return correctAnswer.contains(userAnswer.trim());
    }
    return userAnswer.trim() == correctAnswer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        children: [
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowMedium,
            ),
            child: Column(
              children: [
                // Question text
                Text(
                  widget.question.question,
                  style: JuniorTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                if (widget.question.hint != null) ...[
                  const SizedBox(height: JuniorTheme.spacingSmall),
                  Container(
                    padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryYellow.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: JuniorTheme.primaryYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.question.hint!,
                          style: JuniorTheme.bodySmall.copyWith(
                            color: JuniorTheme.primaryOrange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer input based on question type
          _buildAnswerInput(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    switch (widget.question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice();
      case QuestionType.textInput:
        return _buildTextInput();
      default:
        return _buildTextInput();
    }
  }

  Widget _buildMultipleChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose the correct answer:',
          style: JuniorTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        ...widget.question.options.map((option) {
          final isSelected = _userAnswer == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
            child: GestureDetector(
              onTap: () {
                if (!_hasSubmitted) {
                  setState(() {
                    _userAnswer = option;
                  });
                  HapticFeedback.selectionClick();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: isSelected
                      ? JuniorTheme.primaryGreen.withOpacity(0.3)
                      : JuniorTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? JuniorTheme.primaryGreen
                        : JuniorTheme.primaryBlue.withOpacity(0.3),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? JuniorTheme.shadowMedium
                      : JuniorTheme.shadowLight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? JuniorTheme.primaryGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? JuniorTheme.primaryGreen
                              : JuniorTheme.textSecondary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: JuniorTheme.spacingMedium),
                    Expanded(
                      child: Text(
                        option,
                        style: JuniorTheme.bodyLarge.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Type your answer:',
          style: JuniorTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: JuniorTheme.backgroundLight,
            borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
            border: Border.all(
              color: JuniorTheme.primaryBlue,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _answerController,
            textAlign: TextAlign.center,
            style: JuniorTheme.headingMedium,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter answer here',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingMedium,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _userAnswer = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled =
        _userAnswer != null && _userAnswer!.isNotEmpty && !_hasSubmitted;

    return GestureDetector(
      onTap: isEnabled ? _checkAnswer : null,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: JuniorTheme.spacingMedium),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? JuniorTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    JuniorTheme.textLight,
                    JuniorTheme.textLight,
                  ],
                ),
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
          boxShadow:
              isEnabled ? JuniorTheme.shadowMedium : JuniorTheme.shadowLight,
        ),
        child: Text(
          _hasSubmitted ? 'Answer Submitted!' : 'Check Answer',
          style: JuniorTheme.buttonText.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
