import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

class BubblePopGrammarGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;
  final VoidCallback? onComplete;
  final int currentScore;
  final GlobalKey? coinCounterKey;

  const BubblePopGrammarGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
    this.onComplete,
    this.currentScore = 0,
    this.coinCounterKey,
  });

  @override
  State<BubblePopGrammarGame> createState() => _BubblePopGrammarGameState();
}

class _BubblePopGrammarGameState extends State<BubblePopGrammarGame>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _celebrationController;
  late final AnimationController _shakeController;
  late final AnimationController _scubaBobController;
  late final AnimationController _tooltipController;
  final Map<String, Offset> _bubblePositions = {};
  String? _selectedOption;
  String? _shakingOption;
  String? _tooltipOption;
  bool _answerLocked = false;
  bool _showGreatJob = false;
  bool _showHint = false;
  bool _hasAdvanced = false;
  DateTime _questionStartTime = DateTime.now();
  int _elapsedSeconds = 0;

  List<String> get _options =>
      widget.question.options.map((e) => e.toString()).toList();

  String get _correctAnswer =>
      widget.question.correctAnswer?.toString().trim() ?? '';

  int get _earnedPoints =>
      widget.question.points > 0 ? widget.question.points : 10;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scubaBobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _resetQuestion();
  }

  @override
  void didUpdateWidget(BubblePopGrammarGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _resetQuestion();
    }
  }

  void _resetQuestion() {
    _questionStartTime = DateTime.now();
    _elapsedSeconds = 0;
    _answerLocked = false;
    _hasAdvanced = false;
    _selectedOption = null;
    _shakingOption = null;
    _tooltipOption = null;
    _showGreatJob = false;
    _showHint = false;
    _bubblePositions.clear();

    _celebrationController.reset();
    _shakeController.reset();
    _tooltipController.reset();

    // Start timer
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_answerLocked) {
        setState(() {
          _elapsedSeconds =
              DateTime.now().difference(_questionStartTime).inSeconds;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _celebrationController.dispose();
    _shakeController.dispose();
    _scubaBobController.dispose();
    _tooltipController.dispose();
    super.dispose();
  }

  void _onBubbleTap(String option) {
    if (_answerLocked || _hasAdvanced) return;

    final normalizedSelection = option.trim();
    final isCorrect = normalizedSelection.toLowerCase() ==
        _correctAnswer.toLowerCase().trim();

    if (isCorrect) {
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _selectedOption = option;
        _answerLocked = true;
        _hasAdvanced = true;
      });
      _celebrationController.forward(from: 0.0);

      // Launch coin fly animation
      _launchCoinFlyAnimation(option);

      // Show "Great job!" overlay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showGreatJob = true;
          });
        }
      });

      // Auto-advance after celebration
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted && _hasAdvanced) {
          setState(() {
            _showGreatJob = false;
          });
          widget.onAnswerSubmitted(
            questionId: widget.question.id,
            userAnswer: option,
            isCorrect: true,
            pointsEarned: _earnedPoints,
          );
          // Call onComplete if provided (for final question)
          widget.onComplete?.call();
        }
      });
    } else {
      SystemSound.play(SystemSoundType.alert);
      setState(() {
        _shakingOption = option;
        _tooltipOption = option;
      });
      _shakeController.forward(from: 0.0);
      _tooltipController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _shakingOption = null;
            _tooltipOption = null;
          });
          _tooltipController.reset();
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _launchCoinFlyAnimation(String tappedOption) {
    final bubblePosition = _bubblePositions[tappedOption];
    if (bubblePosition == null || widget.coinCounterKey == null) return;

    // Get bubble center in global coordinates
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final bubbleGlobalCenter = renderBox.localToGlobal(
      bubblePosition + const Offset(60, 60), // bubble center (120/2)
    );

    // Get coin counter center in global coordinates
    final coinCounterRenderBox =
        widget.coinCounterKey!.currentContext?.findRenderObject() as RenderBox?;
    if (coinCounterRenderBox == null) return;
    final coinCounterGlobalCenter = coinCounterRenderBox.localToGlobal(
      Offset(coinCounterRenderBox.size.width / 2,
          coinCounterRenderBox.size.height / 2),
    );

    // Create overlay entry for coin animation
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _CoinFlyOverlay(
        startPosition: bubbleGlobalCenter,
        targetPosition: coinCounterGlobalCenter,
        coinCount: math.min(_earnedPoints, 8),
      ),
    );
    overlay.insert(entry);

    // Remove overlay after animation completes
    Future.delayed(const Duration(milliseconds: 1200), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    final prompt = widget.question.question.isNotEmpty
        ? widget.question.question
        : 'Tap the correct word part!';

    // Calculate bubble positions to prevent overlap
    _calculateBubblePositions(screenSize);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JuniorTheme.primaryBlue,
            JuniorTheme.primaryBlue.withValues(alpha: 0.8),
            JuniorTheme.primaryGreen.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Underwater background effects
          Positioned.fill(
            child: CustomPaint(
              painter: _UnderwaterBackgroundPainter(
                _floatController,
                _scubaBobController,
              ),
            ),
          ),
          // Light rays effect
          Positioned.fill(
            child: CustomPaint(
              painter: _LightRaysPainter(_floatController),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar with back button, coins, and time
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      // Coins counter
                      Container(
                        key: widget.coinCounterKey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: JuniorTheme.accentGold,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.currentScore}',
                              style: JuniorTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Time counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(_elapsedSeconds),
                              style: JuniorTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Hint button
                      if (widget.question.hint != null &&
                          widget.question.hint!.isNotEmpty)
                        IconButton(
                          onPressed: _answerLocked
                              ? null
                              : () {
                                  setState(() {
                                    _showHint = !_showHint;
                                  });
                                },
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: _answerLocked ? Colors.grey : Colors.white,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: _answerLocked
                                ? Colors.grey.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.all(8),
                          ),
                          tooltip: 'Show Hint',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Question text - large and clear
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: JuniorTheme.shadowHeavy,
                    ),
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      style: JuniorTheme.headingMedium.copyWith(
                        color: const Color(0xFF0F3057),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                // Hint display - below question
                if (_showHint && widget.question.hint != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0.0, 4.0),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.amber.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.question.hint!,
                              style: JuniorTheme.bodyMedium.copyWith(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Collect the correct bubble!',
                    textAlign: TextAlign.center,
                    style: JuniorTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bubbles area - circular bubbles in grid layout
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: _options.map((option) {
                      final position = _bubblePositions[option] ?? Offset.zero;
                      return Positioned(
                        left: position.dx,
                        top: position.dy,
                        child: _BubbleWidget(
                          label: option,
                          floatController: _floatController,
                          celebrationController: _celebrationController,
                          shakeController: _shakeController,
                          isCollected:
                              _answerLocked && _selectedOption == option,
                          isShaking: _shakingOption == option,
                          onTap: () => _onBubbleTap(option),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Tooltip for wrong answer
                if (_tooltipOption != null)
                  _WrongAnswerTooltip(
                    option: _tooltipOption!,
                    position: _bubblePositions[_tooltipOption!] ?? Offset.zero,
                    animation: _tooltipController,
                  ),
                // Smaller scuba character
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnimatedBuilder(
                    animation: _scubaBobController,
                    builder: (context, child) {
                      final bobOffset =
                          math.sin(_scubaBobController.value * math.pi * 2) *
                              3.0;
                      return Transform.translate(
                        offset: Offset(0.0, bobOffset),
                        child: child,
                      );
                    },
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                        CurvedAnimation(
                          parent: _celebrationController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white38, width: 2),
                            ),
                            child: const Icon(
                              Icons.scuba_diving,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _answerLocked
                                  ? '+$_earnedPoints XP!'
                                  : 'Earn +$_earnedPoints XP',
                              style: JuniorTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // "Great job!" overlay
          if (_showGreatJob)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: JuniorTheme.shadowHeavy,
                    ),
                    child: Text(
                      'Great job!',
                      style: JuniorTheme.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _calculateBubblePositions(Size screenSize) {
    if (_bubblePositions.isNotEmpty) return; // Already calculated

    final bubbleSize = 120.0;
    final spacing = 20.0;
    final screenWidth = screenSize.width;

    // Calculate how many bubbles per row (3 max)
    final bubblesPerRow = math.min(3, _options.length);

    // Calculate spacing between bubbles
    final totalBubbleWidth =
        (bubblesPerRow * bubbleSize) + ((bubblesPerRow - 1) * spacing);
    final startX = (screenWidth - totalBubbleWidth) / 2;
    final startY = screenSize.height * 0.25; // Start from 25% down

    for (int i = 0; i < _options.length; i++) {
      final row = i ~/ bubblesPerRow;
      final col = i % bubblesPerRow;

      final x = startX + (col * (bubbleSize + spacing));
      final y = startY + (row * (bubbleSize + spacing + 20));

      _bubblePositions[_options[i]] = Offset(x, y);
    }
  }
}

class _BubbleWidget extends StatelessWidget {
  final String label;
  final AnimationController floatController;
  final AnimationController celebrationController;
  final AnimationController shakeController;
  final bool isCollected;
  final bool isShaking;
  final VoidCallback onTap;

  const _BubbleWidget({
    required this.label,
    required this.floatController,
    required this.celebrationController,
    required this.shakeController,
    required this.isCollected,
    required this.isShaking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isCollected ? 0.0 : 1.0,
      child: AnimatedBuilder(
        animation: Listenable.merge([floatController, shakeController]),
        builder: (context, child) {
          final floatOffset =
              math.sin(floatController.value * math.pi * 2) * 6.0;
          final shakeOffset = isShaking
              ? math.sin(shakeController.value * math.pi * 8) * 8.0
              : 0.0;
          return Transform.translate(
            offset: Offset(shakeOffset, floatOffset),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0.0, 6.0),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: JuniorTheme.bodyLarge.copyWith(
                    color: const Color(0xFF0F3057),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WrongAnswerTooltip extends StatelessWidget {
  final String option;
  final Offset position;
  final Animation<double> animation;

  const _WrongAnswerTooltip({
    required this.option,
    required this.position,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx + 40,
      top: position.dy - 30,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Text(
            'Try again!',
            style: JuniorTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _UnderwaterBackgroundPainter extends CustomPainter {
  final AnimationController floatController;
  final AnimationController scubaController;

  _UnderwaterBackgroundPainter(this.floatController, this.scubaController)
      : super(repaint: Listenable.merge([floatController, scubaController]));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.08);

    // Floating bubbles at different depths
    final bubbles = [
      Offset(
        size.width * 0.2,
        size.height * (0.4 + floatController.value * 0.05),
      ),
      Offset(
        size.width * 0.8,
        size.height * (0.3 + floatController.value * 0.04),
      ),
      Offset(
        size.width * 0.5,
        size.height * (0.6 + floatController.value * 0.03),
      ),
      Offset(
        size.width * 0.15,
        size.height * (0.7 + floatController.value * 0.06),
      ),
      Offset(
        size.width * 0.85,
        size.height * (0.5 + floatController.value * 0.04),
      ),
    ];

    for (final offset in bubbles) {
      canvas.drawCircle(offset, 30, paint);
    }

    // Additional smaller bubbles
    final smallPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.05);

    for (int i = 0; i < 8; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.12);
      final y = size.height * (0.2 + (floatController.value * 0.1) + (i * 0.1));
      canvas.drawCircle(Offset(x, y), 15, smallPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LightRaysPainter extends CustomPainter {
  final AnimationController controller;

  _LightRaysPainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height));

    // Light rays from top
    final path = Path();
    path.moveTo(size.width * 0.3, 0.0);
    path.lineTo(size.width * 0.25, size.height);
    path.lineTo(size.width * 0.35, size.height);
    path.close();

    final path2 = Path();
    path2.moveTo(size.width * 0.7, 0.0);
    path2.lineTo(size.width * 0.65, size.height);
    path2.lineTo(size.width * 0.75, size.height);
    path2.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Coin fly animation overlay
class _CoinFlyOverlay extends StatefulWidget {
  final Offset startPosition;
  final Offset targetPosition;
  final int coinCount;

  const _CoinFlyOverlay({
    required this.startPosition,
    required this.targetPosition,
    required this.coinCount,
  });

  @override
  State<_CoinFlyOverlay> createState() => _CoinFlyOverlayState();
}

class _CoinFlyOverlayState extends State<_CoinFlyOverlay>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;
  late final List<Animation<double>> _opacities;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    final coinCount = math.min(widget.coinCount, 8);
    _controllers = List.generate(
      coinCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + _random.nextInt(400)),
      ),
    );

    _animations = _controllers.map((controller) {
      final midX = (widget.startPosition.dx + widget.targetPosition.dx) / 2 +
          (_random.nextDouble() - 0.5) * 60;
      final midY = (widget.startPosition.dy + widget.targetPosition.dy) / 2 -
          (_random.nextDouble() * 80 + 40);
      final midPoint = Offset(midX, midY);

      return TweenSequence<Offset>([
        TweenSequenceItem(
          tween: Tween(begin: widget.startPosition, end: midPoint),
          weight: 0.5,
        ),
        TweenSequenceItem(
          tween: Tween(begin: midPoint, end: widget.targetPosition),
          weight: 0.5,
        ),
      ]).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _opacities = _controllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 0.7),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.3),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    // Start animations with slight delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: List.generate(_controllers.length, (index) {
          return AnimatedBuilder(
            animation: Listenable.merge([_controllers[index]]),
            builder: (context, child) {
              final position = _animations[index].value;
              final opacity = _opacities[index].value;
              return Positioned(
                left: position.dx - 15,
                top: position.dy - 15,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: _controllers[index].value * math.pi * 2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            JuniorTheme.accentGold,
                            JuniorTheme.accentGold.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                JuniorTheme.accentGold.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
