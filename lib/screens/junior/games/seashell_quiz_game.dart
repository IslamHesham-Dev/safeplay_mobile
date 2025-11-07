import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

class SeashellQuizGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const SeashellQuizGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<SeashellQuizGame> createState() => _SeashellQuizGameState();
}

class _SeashellQuizGameState extends State<SeashellQuizGame>
    with TickerProviderStateMixin {
  late final AnimationController _celebrationController;
  late final AnimationController _shakeController;
  String? _selectedOption;
  String? _shakingOption;
  final Set<String> _disabledOptions = {};
  bool _answerLocked = false;

  List<String> get _options =>
      widget.question.options.map((e) => e.toString()).toList();

  String get _correctAnswer =>
      widget.question.correctAnswer?.toString().trim() ?? '';

  int get _earnedPoints =>
      widget.question.points > 0 ? widget.question.points : 10;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap(String option) {
    if (_answerLocked || _disabledOptions.contains(option)) return;

    final isCorrect =
        option.toLowerCase().trim() == _correctAnswer.toLowerCase().trim();

    if (isCorrect) {
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _selectedOption = option;
        _answerLocked = true;
      });
      _celebrationController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 700), () {
        widget.onAnswerSubmitted(
          questionId: widget.question.id,
          userAnswer: option,
          isCorrect: true,
          pointsEarned: _earnedPoints,
        );
      });
    } else {
      SystemSound.play(SystemSoundType.alert);
      setState(() {
        _shakingOption = option;
        _disabledOptions.add(option);
      });
      _shakeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _shakingOption = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.question.question;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF022B3A), Color(0xFF055B8A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: JuniorTheme.shadowMedium,
              ),
              child: Text(
                prompt,
                textAlign: TextAlign.center,
                style: JuniorTheme.headingSmall.copyWith(
                  color: const Color(0xFF0F3057),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the seashell with the correct answer',
            style: JuniorTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: _options
                    .map(
                      (option) => _SeashellOption(
                        label: option,
                        onTap: () => _handleTap(option),
                        isSelected: _selectedOption == option,
                        isDisabled: _disabledOptions.contains(option),
                        isShaking: _shakingOption == option,
                        celebration: _celebrationController,
                        shake: _shakeController,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          _buildScubaFooter(),
        ],
      ),
    );
  }

  Widget _buildScubaFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28, top: 8),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 1.15).animate(
          CurvedAnimation(
            parent: _celebrationController,
            curve: Curves.elasticOut,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 2),
              ),
              child: const Icon(
                Icons.scuba_diving,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _answerLocked ? '+$_earnedPoints XP!' : 'Earn +$_earnedPoints XP',
                style: JuniorTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeashellOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDisabled;
  final bool isShaking;
  final AnimationController celebration;
  final AnimationController shake;

  const _SeashellOption({
    required this.label,
    required this.onTap,
    required this.isSelected,
    required this.isDisabled,
    required this.isShaking,
    required this.celebration,
    required this.shake,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isDisabled && !isSelected ? 0.35 : 1.0;
    final showPearl = isSelected;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: AnimatedBuilder(
        animation: Listenable.merge([celebration, shake]),
        builder: (context, child) {
          final shakeOffset =
              isShaking ? math.sin(shake.value * math.pi * 8) * 6 : 0.0;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: _SeashellPainter(
                  color: isSelected
                      ? const Color(0xFFFFD27F)
                      : const Color(0xFFFFC09F),
                ),
                child: SizedBox.expand(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: JuniorTheme.headingSmall.copyWith(
                    color: const Color(0xFF4B2E08),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showPearl)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.2, end: 1.0).animate(
                    CurvedAnimation(
                      parent: celebration,
                      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
                    ),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Color(0xFFFFF9C4),
                    size: 42,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeashellPainter extends CustomPainter {
  final Color color;

  _SeashellPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.05)
      ..quadraticBezierTo(
          size.width * 0.1, size.height * 0.05, size.width * 0.05, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.02, size.height * 0.7,
          size.width * 0.5, size.height * 0.95)
      ..quadraticBezierTo(size.width * 0.98, size.height * 0.7,
          size.width * 0.95, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.9, size.height * 0.05, size.width * 0.5, size.height * 0.05)
      ..close();

    canvas.drawShadow(path, Colors.black26, 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SeashellPainter oldDelegate) =>
      oldDelegate.color != color;
}

