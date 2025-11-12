import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';
import '../../../widgets/floating_bubbles.dart';

class FishTankQuizGame extends StatefulWidget {
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

  const FishTankQuizGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
    this.onComplete,
    this.currentScore = 0,
    this.coinCounterKey,
  });

  @override
  State<FishTankQuizGame> createState() => _FishTankQuizGameState();
}

class _FishTankQuizGameState extends State<FishTankQuizGame>
    with TickerProviderStateMixin {
  late final AnimationController _mascotController;
  late final AnimationController _fishFlipController;
  late final AnimationController _shakeController;
  late final AnimationController _celebrationController;
  late final AnimationController _tooltipController;
  late final AnimationController _scubaBobController;
  final AudioPlayer _soundPlayer = AudioPlayer();
  String? _selectedOption;
  String? _shakingOption;
  String? _tooltipOption;
  final Set<String> _disabledFish = {};
  bool _answerLocked = false;
  bool _showGreatJob = false;
  bool _showHint = false;
  bool _hasAdvanced = false;
  DateTime _questionStartTime = DateTime.now();
  int _elapsedSeconds = 0;
  final Map<String, Offset> _fishPositions = {};
  late List<String> _shuffledOptions;

  List<String> get _options => _shuffledOptions;

  String get _correctAnswer =>
      widget.question.correctAnswer?.toString().trim() ?? '';

  int get _earnedPoints =>
      widget.question.points > 0 ? widget.question.points : 10;

  void _shuffleOptions() {
    final options = widget.question.options.map((e) => e.toString()).toList();
    _shuffledOptions = List<String>.from(options)..shuffle(Random());
  }

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
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
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scubaBobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Configure sound player to not interfere with background music
    _soundPlayer.setPlayerMode(PlayerMode.lowLatency);

    _resetQuestion();
    // Initialize fixed positions - will be set when build is called with screen size
  }

  @override
  void didUpdateWidget(FishTankQuizGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _resetQuestion();
    }
  }

  void _resetQuestion() {
    _shuffleOptions();
    _questionStartTime = DateTime.now();
    _elapsedSeconds = 0;
    _answerLocked = false;
    _hasAdvanced = false;
    _selectedOption = null;
    _shakingOption = null;
    _tooltipOption = null;
    _showGreatJob = false;
    _showHint = false;
    _disabledFish.clear();

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
    _mascotController.dispose();
    _fishFlipController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _tooltipController.dispose();
    _scubaBobController.dispose();
    _soundPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _launchCoinFlyAnimation(String tappedOption) {
    final fishPosition = _fishPositions[tappedOption];
    if (fishPosition == null || widget.coinCounterKey == null) return;

    // Get fish center in global coordinates
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final fishGlobalCenter = renderBox.localToGlobal(
      fishPosition + const Offset(75, 42.5), // fish center (150/2, 85/2)
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
        startPosition: fishGlobalCenter,
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

  void _handleTap(String option) {
    if (_answerLocked || _hasAdvanced) return;

    final isCorrect =
        option.toLowerCase().trim() == _correctAnswer.toLowerCase().trim();

    if (isCorrect) {
      SystemSound.play(SystemSoundType.click);
      // Play correct answer sound
      _soundPlayer.play(AssetSource(
          'audio/sound effects/sound effects/correct question.wav'));
      setState(() {
        _selectedOption = option;
        _answerLocked = true;
        _hasAdvanced = true;
      });
      _fishFlipController.forward(from: 0);
      _mascotController.forward(from: 0);
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
        _disabledFish.add(option);
        _shakingOption = option;
        _tooltipOption = option;
        // Automatically show hint on wrong answer
        if (widget.question.hint != null && widget.question.hint!.isNotEmpty) {
          _showHint = true;
        }
      });
      _shakeController.forward(from: 0);
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

  void _calculateFishPositions(Size areaSize) {
    _fishPositions.clear();

    const fishWidth = 150.0;
    const fishHeight = 85.0;
    const spacing = 16.0;
    const verticalSpacing = spacing + 20;
    const horizontalOffset = 10.0; // Reintroduce slight right shift
    const verticalOffset = 20.0; // Push the grid slightly downward

    final maxPerRow = math.min(2, _options.length);
    final totalRows = (_options.length / maxPerRow).ceil();
    final totalHeight =
        (totalRows * fishHeight) + ((totalRows - 1) * verticalSpacing);
    final startY =
        math.max(0, (areaSize.height - totalHeight) / 2 + verticalOffset);

    var optionIndex = 0;
    var currentRow = 0;

    while (optionIndex < _options.length) {
      final remaining = _options.length - optionIndex;
      final fishThisRow = math.min(maxPerRow, remaining);
      final rowTotalWidth =
          (fishThisRow * fishWidth) + ((fishThisRow - 1) * spacing);
      final rowStartX = (areaSize.width - rowTotalWidth) / 2 + horizontalOffset;

      for (int col = 0; col < fishThisRow; col++) {
        final x = rowStartX + (col * (fishWidth + spacing));
        final y = startY + (currentRow * (fishHeight + verticalSpacing));
        _fishPositions[_options[optionIndex]] = Offset(x, y);
        optionIndex += 1;
      }
      currentRow += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.question.question.isNotEmpty
        ? widget.question.question
        : 'Tap the correct answer!';

    return Container(
      decoration: const BoxDecoration(
        // Background color behind fishtank image
        color: Color(0xFF0F4471), // Deep blue
      ),
      child: Stack(
        children: [
          // Background image - first layer (behind everything)
          Positioned.fill(
            child: Image.asset(
              'assets/images/Fishtank.JPG',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image fails to load
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F4471), Color(0xFF0E99B7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
          ),
          // Floating bubbles effect - second layer (on top of background, under UI)
          const FloatingBubbles(
            bubbleCount: 18,
            minSize: 5.0,
            maxSize: 16.0,
            bubbleColor: Colors.white,
            opacity: 0.35,
          ),
          // UI elements - top layer (on top of bubbles)
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _calculateFishPositions(
                        Size(constraints.maxWidth, constraints.maxHeight),
                      );
                      return Stack(
                        children: [
                          // Fish options
                          ..._options.map((option) {
                            final position = _fishPositions[option];
                            if (position == null) {
                              return const SizedBox.shrink();
                            }
                            return Positioned(
                              left: position.dx,
                              top: position.dy,
                              child: _FishOption(
                                label: option,
                                onTap: () => _handleTap(option),
                                isCorrect: _selectedOption == option,
                                isDisabled: _disabledFish.contains(option) &&
                                    !_answerLocked,
                                flip: _fishFlipController,
                                shake: _shakeController,
                                isShaking: _shakingOption == option,
                              ),
                            );
                          }),
                          // Tooltip for wrong answer
                          if (_tooltipOption != null)
                            Positioned(
                              left: _fishPositions[_tooltipOption]?.dx ?? 0,
                              top: (_fishPositions[_tooltipOption]?.dy ?? 0) -
                                  40,
                              child: AnimatedBuilder(
                                animation: _tooltipController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _tooltipController.value < 0.5
                                        ? _tooltipController.value * 2
                                        : 1.0 -
                                            ((_tooltipController.value - 0.5) *
                                                2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
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
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // XP text at bottom - centered like Add Equations game
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
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
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _celebrationController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        'Great job!',
                        style: JuniorTheme.headingLarge.copyWith(
                          color: JuniorTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
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
          final rotation =
              isCorrect ? math.sin(flip.value * math.pi) * 0.4 : 0.0;
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
