import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';
import '../../../widgets/floating_bubbles.dart';

class SeashellQuizGame extends StatefulWidget {
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

  const SeashellQuizGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
    this.onComplete,
    this.currentScore = 0,
    this.coinCounterKey,
  });

  @override
  State<SeashellQuizGame> createState() => _SeashellQuizGameState();
}

class _SeashellQuizGameState extends State<SeashellQuizGame>
    with TickerProviderStateMixin {
  late final AnimationController _celebrationController;
  late final AnimationController _shakeController;
  late final AnimationController _tooltipController;
  late final AnimationController _scubaBobController;
  final AudioPlayer _soundPlayer = AudioPlayer();
  String? _selectedOption;
  String? _shakingOption;
  String? _tooltipOption;
  final Set<String> _disabledOptions = {};
  bool _answerLocked = false;
  bool _showHint = false;
  bool _hasAdvanced = false;
  DateTime _questionStartTime = DateTime.now();
  int _elapsedSeconds = 0;
  bool _showGreatJob = false;
  final GlobalKey _gridKey = GlobalKey(); // Key for the GridView
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
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
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
  }

  @override
  void didUpdateWidget(SeashellQuizGame oldWidget) {
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
    _showHint = false;
    _disabledOptions.clear();

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
    _celebrationController.dispose();
    _shakeController.dispose();
    _tooltipController.dispose();
    _scubaBobController.dispose();
    _soundPlayer.dispose();
    super.dispose();
  }

  void _handleSeashellTap(String option) {
    if (_answerLocked || _hasAdvanced || _disabledOptions.contains(option)) {
      return;
    }

    final normalizedSelection = option.trim();
    final isCorrect = normalizedSelection.toLowerCase() ==
        _correctAnswer.toLowerCase().trim();

    if (isCorrect) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
      // Play correct answer sound
      _soundPlayer.play(AssetSource(
          'audio/sound effects/sound effects/correct question.wav'));
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
          // Auto-advance after celebration
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) {
              setState(() {
                _showGreatJob = false;
              });
            }
          });
        }
      });

      // Submit answer after delay
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          widget.onAnswerSubmitted(
            questionId: widget.question.id,
            userAnswer: option,
            isCorrect: true,
            pointsEarned: _earnedPoints,
          );
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        }
      });
    } else {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.mediumImpact();
      setState(() {
        _shakingOption = option;
        _tooltipOption = option;
        _disabledOptions.add(option);
        // Automatically show hint on wrong answer
        if (widget.question.hint != null && widget.question.hint!.isNotEmpty) {
          _showHint = true;
        }
      });
      _shakeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _shakingOption = null);
        }
      });
      _tooltipController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() => _tooltipOption = null);
            _tooltipController.reset();
          }
        });
      });
    }
  }

  void _launchCoinFlyAnimation(String tappedOption) {
    // Find the GridView's render box
    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || widget.coinCounterKey == null) return;

    // Approximate seashell center based on GridView item size
    final optionIndex = _options.indexOf(tappedOption);
    if (optionIndex == -1) return;

    final size = renderBox.size;
    // Grid properties (matching GridView.builder configuration)
    const crossAxisCount = 2;
    const mainAxisSpacing = 20.0;
    const crossAxisSpacing = 20.0;
    const childAspectRatio = 1.1;

    final itemWidth = (size.width - (crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;
    final itemHeight = itemWidth / childAspectRatio;

    final row = optionIndex ~/ crossAxisCount;
    final col = optionIndex % crossAxisCount;

    // This calculates the center of the tapped item *within the GridView*
    final seashellLocalCenter = Offset(
      (col * (itemWidth + crossAxisSpacing)) + (itemWidth / 2),
      (row * (itemHeight + mainAxisSpacing)) + (itemHeight / 2),
    );

    // Get seashell center in global coordinates
    final seashellGlobalCenter = renderBox.localToGlobal(seashellLocalCenter);

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
        startPosition: seashellGlobalCenter,
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.question.question.isNotEmpty
        ? widget.question.question
        : 'Tap the seashell with the correct answer';

    return Container(
      decoration: const BoxDecoration(
        // Background color behind seashell image
        color: Color(0xFF0883B4), // #0883b4
      ),
      child: Stack(
        children: [
          // Background image - first layer (behind everything)
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height *
                0.15, // Start lower on screen
            bottom: 0,
            child: Image.asset(
              'assets/seashell.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to solid color if image fails to load
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0883B4), // #0883b4
                  ),
                );
              },
            ),
          ),
          // Floating bubbles effect - second layer (on top of background, under UI)
          const FloatingBubbles(
            bubbleCount: 22,
            minSize: 7.0,
            maxSize: 20.0,
            bubbleColor: Colors.white,
            opacity: 0.4,
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
                          backgroundColor:
                              Colors.white.withAlpha(51), // 0.2 alpha
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      // Coins counter
                      Container(
                        key: widget.coinCounterKey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51), // 0.2 alpha
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
                          color: Colors.white.withAlpha(51), // 0.2 alpha
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
                                ? Colors.grey.withAlpha(77) // 0.3 alpha
                                : Colors.white.withAlpha(51), // 0.2 alpha
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
                      color: Colors.white.withAlpha(242), // 0.95 alpha
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(
                            0xFF0F3057), // Same color as question text
                        width: 2,
                      ),
                      boxShadow: JuniorTheme.shadowHeavy,
                    ),
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      style: JuniorTheme.headingMedium.copyWith(
                        color: const Color(0xFF0F3057),
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
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
                        color: Colors.amber.withAlpha(242), // 0.95 alpha
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51), // 0.2 alpha
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
                    'Tap the seashell with correct answer',
                    textAlign: TextAlign.center,
                    style: JuniorTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Answer buttons (Seashells) - 2x2 grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      key: _gridKey, // Assign the key here
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio:
                            0.9, // Smaller ratio = taller cells = bigger images
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        final isSelected = _selectedOption == option;
                        final isDisabled = _disabledOptions.contains(option);
                        final isShaking = _shakingOption == option;
                        final showTooltip = _tooltipOption == option;

                        return _SeashellButton(
                          label: option,
                          onTap: () => _handleSeashellTap(option),
                          isSelected: isSelected,
                          isDisabled: isDisabled,
                          isShaking: isShaking,
                          showTooltip: showTooltip,
                          celebration: _celebrationController,
                          shake: _shakeController,
                          tooltip: _tooltipController,
                        );
                      },
                    ),
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
                color: Colors.black.withAlpha(77), // 0.3 alpha
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77), // 0.3 alpha
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      'Great job!',
                      style: JuniorTheme.headingLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: JuniorTheme.primaryGreen,
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

class _SeashellButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDisabled;
  final bool isShaking;
  final bool showTooltip;
  final AnimationController celebration;
  final AnimationController shake;
  final AnimationController tooltip;

  const _SeashellButton({
    required this.label,
    required this.onTap,
    required this.isSelected,
    required this.isDisabled,
    required this.isShaking,
    required this.showTooltip,
    required this.celebration,
    required this.shake,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isDisabled && !isSelected ? 0.35 : 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: AnimatedBuilder(
        animation: Listenable.merge([celebration, shake, tooltip]),
        builder: (context, child) {
          final shakeOffset =
              isShaking ? math.sin(shake.value * math.pi * 8) * 6 : 0.0;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Seashell image - bigger, no color effects
            GestureDetector(
              onTap: onTap,
              child: Image.asset(
                'assets/seashell_image.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to empty container if image fails to load
                  return const SizedBox.shrink();
                },
              ),
            ),
            // Text on top of the image
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Black text
                        fontWeight: FontWeight.w900, // Extra bold
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),

            // Tooltip for wrong answer
            if (showTooltip)
              Positioned(
                top: -40,
                child: FadeTransition(
                  opacity: tooltip,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77), // 0.3 alpha
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Try again!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Success indicator
            if (isSelected)
              ScaleTransition(
                scale: Tween<double>(begin: 0.2, end: 1.0).animate(
                  CurvedAnimation(
                    parent: celebration,
                    curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFFFFB703),
                  size: 42,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Coin fly animation overlay (reused from bubble game)
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
                            JuniorTheme.accentGold.withAlpha(204), // 0.8 alpha
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: JuniorTheme.accentGold
                                .withAlpha(128), // 0.5 alpha
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
