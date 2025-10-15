import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// Streak display widget showing consecutive days
class StreakDisplayWidget extends StatelessWidget {
  final int streakDays;
  final VoidCallback? onTap;

  const StreakDisplayWidget({
    super.key,
    required this.streakDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SafePlayColors.brandOrange500,
              Colors.orange.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: SafePlayColors.brandOrange500.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fire emoji with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.8, end: 1.0),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 32),
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            // Streak count and label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streakDays ${streakDays == 1 ? "Day" : "Days"}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Keep it up!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
