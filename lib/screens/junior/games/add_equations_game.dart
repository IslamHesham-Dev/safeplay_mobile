import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

class AddEquationsGame extends StatefulWidget {
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

  const AddEquationsGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
    this.onComplete,
    this.currentScore = 0,
    this.coinCounterKey,
  });

  @override
  State<AddEquationsGame> createState() => _AddEquationsGameState();
}

class _AddEquationsGameState extends State<AddEquationsGame>
    with TickerProviderStateMixin {
  late final AnimationController _celebrationController;
  late final AnimationController _shakeController;
  late final AnimationController _tooltipController;
  late final AnimationController _dragController;
  late final AnimationController _glowController;
  final AudioPlayer _soundPlayer = AudioPlayer();

  String? _selectedAnswer;
  String? _draggedNumber;
  String? _shakingNumber;
  String? _tooltipNumber;
  final Set<String> _disabledNumbers = {};
  bool _answerLocked = false;
  bool _showGreatJob = false;
  bool _showHint = false;
  bool _hasAdvanced = false;
  bool _isHovering = false;
  DateTime _questionStartTime = DateTime.now();
  int _elapsedSeconds = 0;
  late List<String> _shuffledOptions;

  List<String> get _options => _shuffledOptions;

  String get _correctAnswer =>
      widget.question.correctAnswer?.toString().trim() ?? '';

  int get _earnedPoints =>
      widget.question.points > 0 ? widget.question.points : 10;

  // Parse the equation from the prompt
  Map<String, String> get _equationParts {
    final prompt = widget.question.question;
    // Parse equations like "11 + ___ = 14" or "_ + 6 = 9" or "4 + 4 = _"
    final parts = <String, String>{};

    // Helper function to check if a string is a blank (contains only underscores or is empty)
    bool isBlank(String str) {
      final trimmed = str.trim();
      return trimmed.isEmpty ||
          trimmed.replaceAll('_', '').isEmpty ||
          trimmed == '_' ||
          trimmed == '__' ||
          trimmed == '___';
    }

    // Try to extract numbers and blank
    if (prompt.contains('+') && prompt.contains('=')) {
      final partsList = prompt.split('=');
      if (partsList.length == 2) {
        final leftSide = partsList[0].trim();
        final rightSide = partsList[1].trim();

        // Check if right side is blank
        if (isBlank(rightSide)) {
          parts['right'] = '';
        } else {
          parts['right'] = rightSide;
        }

        // Split left side by +
        final leftParts = leftSide.split('+');
        if (leftParts.length == 2) {
          final part1 = leftParts[0].trim();
          final part2 = leftParts[1].trim();

          if (isBlank(part1)) {
            parts['left1'] = '';
            parts['left2'] = part2;
          } else if (isBlank(part2)) {
            parts['left1'] = part1;
            parts['left2'] = '';
          } else {
            parts['left1'] = part1;
            parts['left2'] = part2;
          }
        }
      }
    } else if (prompt.contains('-') && prompt.contains('=')) {
      final partsList = prompt.split('=');
      if (partsList.length == 2) {
        final leftSide = partsList[0].trim();
        final rightSide = partsList[1].trim();

        // Check if right side is blank
        if (isBlank(rightSide)) {
          parts['right'] = '';
        } else {
          parts['right'] = rightSide;
        }

        // Split left side by -
        final leftParts = leftSide.split('-');
        if (leftParts.length == 2) {
          final part1 = leftParts[0].trim();
          final part2 = leftParts[1].trim();

          if (isBlank(part1)) {
            parts['left1'] = '';
            parts['left2'] = part2;
          } else if (isBlank(part2)) {
            parts['left1'] = part1;
            parts['left2'] = '';
          } else {
            parts['left1'] = part1;
            parts['left2'] = part2;
          }
        }
      }
    }

    return parts;
  }

  String get _equationOperator {
    final prompt = widget.question.question;
    if (prompt.contains('+')) return '+';
    if (prompt.contains('-')) return '-';
    return '+';
  }

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

    // Configure sound player to not interfere with background music
    _soundPlayer.setPlayerMode(PlayerMode.lowLatency);

    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _resetQuestion();
  }

  @override
  void didUpdateWidget(AddEquationsGame oldWidget) {
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
    _selectedAnswer = null;
    _draggedNumber = null;
    _shakingNumber = null;
    _tooltipNumber = null;
    _isHovering = false;
    _showGreatJob = false;
    _showHint = false;
    _disabledNumbers.clear();

    _celebrationController.reset();
    _shakeController.reset();
    _tooltipController.reset();
    _dragController.reset();
    _glowController.reset();

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
    _dragController.dispose();
    _glowController.dispose();
    _soundPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _launchCoinFlyAnimation(String number) {
    // Get number position (approximate center of the number button)
    final screenSize = MediaQuery.of(context).size;
    final numberIndex = _options.indexOf(number);
    if (numberIndex == -1 || widget.coinCounterKey == null) return;

    // Calculate approximate position of number button
    final numberY = screenSize.height * 0.65; // Numbers are at ~65% from top
    final numberSpacing = screenSize.width / (_options.length + 1);
    final numberX = numberSpacing * (numberIndex + 1);

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
        startPosition: Offset(numberX, numberY),
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

  void _onNumberDropped(String number) {
    if (_answerLocked || _hasAdvanced) return;

    final normalizedSelection = number.trim();
    final isCorrect = normalizedSelection.toLowerCase() ==
        _correctAnswer.toLowerCase().trim();

    if (isCorrect) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
      // Play correct answer sound
      _soundPlayer.play(AssetSource(
          'audio/sound effects/sound effects/correct question.wav'));
      setState(() {
        _selectedAnswer = number;
        _answerLocked = true;
        _hasAdvanced = true;
        _isHovering = false;
      });
      _celebrationController.forward(from: 0.0);
      _glowController.forward(from: 0.0);

      // Launch coin fly animation
      _launchCoinFlyAnimation(number);

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
            userAnswer: number,
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
        _shakingNumber = number;
        _tooltipNumber = number;
        _disabledNumbers.add(number);
        _isHovering = false;
        // Automatically show hint on wrong answer
        if (widget.question.hint != null && widget.question.hint!.isNotEmpty) {
          _showHint = true;
        }
      });
      _shakeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _shakingNumber = null);
        }
      });
      _tooltipController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _tooltipNumber = null;
              _tooltipController.reset();
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final equationParts = _equationParts;
    final operator = _equationOperator;

    return Stack(
      children: [
        // Background grass image - must be first in Stack
        Positioned.fill(
          child: Image.asset(
            'assets/images/grass.JPG',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to solid color if image fails to load
              debugPrint('Error loading grass.JPG: $error');
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFA5C67C), // Light green
                ),
              );
            },
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

              // Math equation display at top center (~25% from top)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Equation box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(242), // 0.95 alpha
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF5E2D10), // Brown border
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51), // 0.2 alpha
                              blurRadius: 12,
                              offset: const Offset(0.0, 6.0),
                            ),
                          ],
                        ),
                        child: _buildEquation(equationParts, operator),
                      ),
                    ),

                    // Hint display - below equation
                    if (_showHint && widget.question.hint != null) ...[
                      const SizedBox(height: 16),
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

                    const Spacer(),

                    // Number choices at bottom (~60-65% from top)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _options.map((number) {
                          final isDisabled = _disabledNumbers.contains(number);
                          final isShaking = _shakingNumber == number;
                          final showTooltip = _tooltipNumber == number;
                          final isDragging = _draggedNumber == number;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _DraggableNumber(
                              number: number,
                              isDisabled: isDisabled,
                              isShaking: isShaking,
                              showTooltip: showTooltip,
                              isDragging: isDragging,
                              shake: _shakeController,
                              tooltip: _tooltipController,
                              drag: _dragController,
                              onDragStart: () {
                                setState(() {
                                  _draggedNumber = number;
                                });
                                _dragController.forward();
                              },
                              onDragEnd: () {
                                setState(() {
                                  _draggedNumber = null;
                                });
                                _dragController.reverse();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // XP text at bottom - centered like other games
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              color: Colors.black.withAlpha(102), // 0.4 alpha
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
                      color: JuniorTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(128), // 0.5 alpha
                          blurRadius: 16,
                          offset: const Offset(0.0, 8.0),
                        ),
                      ],
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
          ),
      ],
    );
  }

  Widget _buildEquation(Map<String, String> parts, String operator) {
    final left1 = parts['left1'] ?? '';
    final left2 = parts['left2'] ?? '';
    final right = parts['right'] ?? '';
    final hasAnswer = _selectedAnswer != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left part 1
        if (left1.isNotEmpty)
          _buildEquationPart(left1)
        else
          _buildBlankSpaceWithDragTarget(hasAnswer ? _selectedAnswer! : null),

        const SizedBox(width: 12),
        // Operator
        _buildEquationPart(operator),
        const SizedBox(width: 12),

        // Left part 2
        if (left2.isNotEmpty)
          _buildEquationPart(left2)
        else
          _buildBlankSpaceWithDragTarget(hasAnswer ? _selectedAnswer! : null),

        const SizedBox(width: 12),
        // Equals sign
        _buildEquationPart('='),
        const SizedBox(width: 12),
        // Right part (can also be blank)
        if (right.isNotEmpty)
          _buildEquationPart(right)
        else
          _buildBlankSpaceWithDragTarget(hasAnswer ? _selectedAnswer! : null),
      ],
    );
  }

  Widget _buildEquationPart(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5E2D10), // Brown color
      ),
    );
  }

  Widget _buildBlankSpaceWithDragTarget(String? answer) {
    // Always create a DragTarget, even if answer is locked (for visual consistency)
    return DragTarget<String>(
      onWillAccept: (data) {
        if (!_answerLocked && !_hasAdvanced) {
          setState(() {
            _isHovering = true;
          });
          return true;
        }
        return false;
      },
      onLeave: (data) {
        setState(() {
          _isHovering = false;
        });
      },
      onAccept: (data) {
        setState(() {
          _isHovering = false;
        });
        if (!_answerLocked && !_hasAdvanced) {
          _onNumberDropped(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = (!_answerLocked && !_hasAdvanced) &&
            (candidateData.isNotEmpty || _isHovering);
        return _buildBlankSpace(answer, isHighlighted);
      },
    );
  }

  Widget _buildBlankSpace(String? answer, bool isHighlighted) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = _selectedAnswer != null
            ? _glowController.value
            : (isHighlighted ? 0.3 : 0.0);

        return Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: _selectedAnswer != null
                ? Colors.green.withAlpha((200 + (glowValue * 55)).toInt())
                : (isHighlighted
                    ? Colors.blue.withAlpha(77) // 0.3 alpha
                    : Colors.white.withAlpha(242)), // 0.95 alpha
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedAnswer != null
                  ? Colors.green.shade700
                  : (isHighlighted
                      ? Colors.blue.shade700
                      : const Color(0xFF5E2D10)),
              width: 3,
            ),
            boxShadow: _selectedAnswer != null
                ? [
                    BoxShadow(
                      color: Colors.green
                          .withAlpha((128 + (glowValue * 127)).toInt()),
                      blurRadius: 12 + (glowValue * 8),
                      spreadRadius: 2 + (glowValue * 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: answer != null
                ? Text(
                    answer,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E2D10), // Brown color
                    ),
                  )
                : Text(
                    '___',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          const Color(0xFF5E2D10).withAlpha(153), // 0.6 alpha
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _DraggableNumber extends StatelessWidget {
  final String number;
  final bool isDisabled;
  final bool isShaking;
  final bool showTooltip;
  final bool isDragging;
  final AnimationController shake;
  final AnimationController tooltip;
  final AnimationController drag;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _DraggableNumber({
    required this.number,
    required this.isDisabled,
    required this.isShaking,
    required this.showTooltip,
    required this.isDragging,
    required this.shake,
    required this.tooltip,
    required this.drag,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Don't allow dragging if disabled
    if (isDisabled) {
      return _buildNumberContainer();
    }

    return Draggable<String>(
      data: number,
      onDragStarted: onDragStart,
      onDragEnd: (details) {
        onDragEnd();
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC84C), // Yellow-orange
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFC84C),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(128), // 0.5 alpha
                  blurRadius: 16,
                  offset: const Offset(0.0, 8.0),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E2D10), // Brown color
                ),
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildNumberContainer(),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([shake, tooltip, drag]),
        builder: (context, child) {
          double shakeOffset = 0.0;
          if (isShaking) {
            shakeOffset = (shake.value - 0.5) * 20.0;
          }

          double scale = 1.0;
          if (isDragging) {
            scale = 1.0 + (drag.value * 0.05); // Scale up to 1.05x
          }

          return Transform.translate(
            offset: Offset(shakeOffset, 0.0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: _buildNumberContainer(),
      ),
    );
  }

  Widget _buildNumberContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey.shade400
                : const Color(0xFFFFC84C), // Yellow-orange
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDisabled ? Colors.grey.shade600 : const Color(0xFFFFC84C),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51), // 0.2 alpha
                blurRadius: 8,
                offset: const Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDisabled
                    ? Colors.grey.shade700
                    : const Color(0xFF5E2D10), // Brown color
              ),
            ),
          ),
        ),
        // Tooltip overlay
        if (showTooltip)
          Positioned(
            top: -40,
            child: FadeTransition(
              opacity: tooltip,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Try again!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CoinFlyOverlay extends StatelessWidget {
  final Offset startPosition;
  final Offset targetPosition;
  final int coinCount;

  const _CoinFlyOverlay({
    required this.startPosition,
    required this.targetPosition,
    required this.coinCount,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(
          coinCount,
          (index) => _FlyingCoin(
            startPosition: startPosition,
            targetPosition: targetPosition,
            delay: Duration(milliseconds: index * 100),
          ),
        ),
      ),
    );
  }
}

class _FlyingCoin extends StatefulWidget {
  final Offset startPosition;
  final Offset targetPosition;
  final Duration delay;

  const _FlyingCoin({
    required this.startPosition,
    required this.targetPosition,
    required this.delay,
  });

  @override
  State<_FlyingCoin> createState() => _FlyingCoinState();
}

class _FlyingCoinState extends State<_FlyingCoin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final curve = Curves.easeOutCubic;
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.targetPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.5,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 0.2,
      ),
    ]).animate(_controller);

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - 15,
          top: _positionAnimation.value.dy - 15,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: JuniorTheme.accentGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77), // 0.3 alpha
                      blurRadius: 4,
                      offset: const Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
