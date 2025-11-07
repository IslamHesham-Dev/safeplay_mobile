import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

class FishTankQuizGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const FishTankQuizGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<FishTankQuizGame> createState() => _FishTankQuizGameState();
}

class _FishTankQuizGameState extends State<FishTankQuizGame>
    with TickerProviderStateMixin {
  late final AnimationController _mascotController;
  late final AnimationController _fishFlipController;
  late final AnimationController _shakeController;
  String? _selectedOption;
  String? _shakingOption;
  final Set<String> _disabledFish = {};
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
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fishFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _fishFlipController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap(String option) {
    if (_answerLocked || _disabledFish.contains(option)) return;

    final isCorrect =
        option.toLowerCase().trim() == _correctAnswer.toLowerCase().trim();

    if (isCorrect) {
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _selectedOption = option;
        _answerLocked = true;
      });
      _fishFlipController.forward(from: 0);
      _mascotController.forward(from: 0);
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
        _disabledFish.add(option);
        _shakingOption = option;
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F4471), Color(0xFF0E99B7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildQuestionArea(),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 16,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: _options
                    .map(
                      (option) => _FishOption(
                        label: option,
                        onTap: () => _handleTap(option),
                        isCorrect: _selectedOption == option,
                        isDisabled:
                            _disabledFish.contains(option) && !_answerLocked,
                        flip: _fishFlipController,
                        shake: _shakeController,
                        isShaking: _shakingOption == option,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          _buildMascotRow(),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    final prompt = widget.question.question;
    final hasImage = widget.question.imageUrl != null &&
        widget.question.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.93),
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
          if (hasImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.question.imageUrl!,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.white24,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMascotRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1.15).animate(
                    CurvedAnimation(
                      parent: _mascotController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 2),
                    ),
                    child: const Icon(
                      Icons.catching_pokemon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _answerLocked
                        ? '+$_earnedPoints XP!'
                        : 'Earn +$_earnedPoints XP',
                    style: JuniorTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _FishOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool isDisabled;
  final bool isShaking;
  final AnimationController flip;
  final AnimationController shake;

  const _FishOption({
    required this.label,
    required this.onTap,
    required this.isCorrect,
    required this.isDisabled,
    required this.isShaking,
    required this.flip,
    required this.shake,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isDisabled && !isCorrect ? 0.35 : 1.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: AnimatedBuilder(
        animation: Listenable.merge([flip, shake]),
        builder: (context, child) {
          final rotation = isCorrect
              ? math.sin(flip.value * math.pi) * 0.4
              : 0.0;
          final shakeOffset =
              isShaking ? math.sin(shake.value * math.pi * 8) * 5 : 0.0;
          return Transform(
            transform: Matrix4.identity()
              ..translate(shakeOffset)
              ..rotateY(rotation),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 150,
            height: 85,
            child: CustomPaint(
              painter: _FishPainter(
                color: isCorrect
                    ? const Color(0xFF8BE0A4)
                    : const Color(0xFFFCB97D),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: JuniorTheme.headingSmall.copyWith(
                      color: const Color(0xFF00334E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  final Color color;

  _FishPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.7, -size.height * 0.2,
          size.width * 0.85, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.7, size.height * 1.2,
          size.width * 0.15, size.height * 0.8)
      ..close();

    final tail = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..lineTo(0, size.height * 0.05)
      ..lineTo(0, size.height * 0.95)
      ..lineTo(size.width * 0.15, size.height * 0.8)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawShadow(body, Colors.black26, 5, true);
    canvas.drawPath(body, paint);
    canvas.drawPath(tail, paint);

    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.35),
      6,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.35),
      3,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _FishPainter oldDelegate) =>
      oldDelegate.color != color;
}

