import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// Sage the Shield mascot widget for Junior Explorer
class MascotWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SafePlayColors.brandTeal50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SafePlayColors.brandTeal500,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Animated mascot icon
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bounceAnimation.value),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: SafePlayColors.brandTeal500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SafePlayColors.brandTeal500
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 16),

            // Speech bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral900,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
