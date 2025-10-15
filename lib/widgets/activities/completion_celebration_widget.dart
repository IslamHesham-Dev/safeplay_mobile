import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../design_system/colors.dart';

/// Completion celebration widget with confetti
class CompletionCelebrationWidget extends StatelessWidget {
  final int score;
  final int totalPoints;
  final ConfettiController confettiController;
  final VoidCallback onContinue;

  const CompletionCelebrationWidget({
    super.key,
    required this.score,
    required this.totalPoints,
    required this.confettiController,
    required this.onContinue,
  });

  double get percentage => (score / totalPoints) * 100;

  String get message {
    if (percentage == 100) return 'Perfect! 🌟';
    if (percentage >= 80) return 'Excellent! 🎉';
    if (percentage >= 60) return 'Great Job! 👍';
    if (percentage >= 40) return 'Good Try! 💪';
    return 'Keep Learning! 📚';
  }

  Color get color {
    if (percentage >= 80) return SafePlayColors.success;
    if (percentage >= 60) return SafePlayColors.brandTeal500;
    if (percentage >= 40) return SafePlayColors.brandOrange500;
    return SafePlayColors.neutral500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [
                SafePlayColors.brandTeal500,
                SafePlayColors.brandOrange500,
                SafePlayColors.juniorPurple,
                SafePlayColors.juniorPink,
                SafePlayColors.brightIndigo,
              ],
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Trophy icon with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: color,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Message
                    Text(
                      message,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$score / $totalPoints',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                          Text(
                            '${percentage.round()}% Correct',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: SafePlayColors.neutral700,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // XP earned
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: SafePlayColors.brandOrange500,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+$score XP',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: SafePlayColors.brandOrange500,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Continue button
                    ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
