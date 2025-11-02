import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Koala Counter's Adventure Game Widget
/// For questions about number lines, addition, and subtraction
class KoalaCounterAdventureGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const KoalaCounterAdventureGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<KoalaCounterAdventureGame> createState() =>
      _KoalaCounterAdventureGameState();
}

class _KoalaCounterAdventureGameState extends State<KoalaCounterAdventureGame>
    with TickerProviderStateMixin {
  late TextEditingController _answerController;
  late AnimationController _koalaController;
  late Animation<double> _koalaAnimation;
  String? _userAnswer;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _koalaController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _koalaAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _koalaController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _koalaController.dispose();
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

    if (isCorrect) {
      _koalaController.forward();
    }

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: _userAnswer,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.question.points : 0,
    );
  }

  bool _isAnswerCorrect(String userAnswer, dynamic correctAnswer) {
    if (correctAnswer is String) {
      return userAnswer.trim() == correctAnswer.toString();
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
                // Koala emoji
                const Text(
                  '🐨',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: JuniorTheme.spacingSmall),
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
                      color: JuniorTheme.primaryGreen.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: JuniorTheme.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.question.hint!,
                          style: JuniorTheme.bodySmall.copyWith(
                            color: JuniorTheme.primaryGreen,
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

          // Number line visualization
          _buildNumberLine(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer input
          _buildAnswerInput(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNumberLine() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
      ),
      child: Stack(
        children: [
          // Number line
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(11, (index) {
                final number =
                    index * 2; // 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: JuniorTheme.primaryGreen.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: JuniorTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: JuniorTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 2,
                      height: 20,
                      color: JuniorTheme.primaryGreen,
                    ),
                  ],
                );
              }),
            ),
          ),

          // Animated Koala
          AnimatedBuilder(
            animation: _koalaAnimation,
            builder: (context, child) {
              return Positioned(
                left: 20 + (_koalaAnimation.value * 280),
                top: 20,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryBrown,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🐨',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
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
              color: JuniorTheme.primaryGreen,
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
