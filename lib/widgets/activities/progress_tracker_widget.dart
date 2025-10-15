import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// Progress tracker widget showing activity progress
class ProgressTrackerWidget extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int score;

  const ProgressTrackerWidget({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question counter and score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $currentQuestion of $totalQuestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: SafePlayColors.brandOrange500,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$score pts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SafePlayColors.brandOrange500,
                        ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: SafePlayColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(
                SafePlayColors.brandTeal500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
