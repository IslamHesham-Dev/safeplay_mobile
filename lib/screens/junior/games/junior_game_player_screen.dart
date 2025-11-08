import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';
import '../../../models/game_activity.dart';
import '../../../models/lesson.dart';
import '../../../widgets/junior/junior_confetti.dart';
import '../../../widgets/junior/junior_coin_animation.dart';
import '../../../services/junior_activity_progress_service.dart';
import '../../../providers/auth_provider.dart';

import 'number_grid_race_game.dart';
import 'koala_counter_adventure_game.dart';
import 'ordinal_drag_order_game.dart';
import 'pattern_builder_game.dart';
import 'memory_match_game.dart';
import 'word_builder_game.dart';
import 'story_sequencer_game.dart';
import 'bubble_pop_grammar_game.dart';
import 'seashell_quiz_game.dart';
import 'fish_tank_quiz_game.dart';

/// Main game player screen that routes to specific game implementations
class JuniorGamePlayerScreen extends StatefulWidget {
  final GameType gameType;
  final String gameTitle;
  final List<ActivityQuestion> questions;
  final Lesson lesson;

  const JuniorGamePlayerScreen({
    super.key,
    required this.gameType,
    required this.gameTitle,
    required this.questions,
    required this.lesson,
  });

  @override
  State<JuniorGamePlayerScreen> createState() => _JuniorGamePlayerScreenState();
}

class _JuniorGamePlayerScreenState extends State<JuniorGamePlayerScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalPoints = 0;
  bool _gameCompleted = false;
  Map<String, dynamic> _answers = {};
  String? _sessionId;
  final JuniorActivityProgressService _progressService =
      JuniorActivityProgressService();
  List<GameResponse> _allResponses = [];
  DateTime _sessionStartTime = DateTime.now();
  int _totalCorrectAnswers = 0;
  final GlobalKey _coinCounterKey = GlobalKey();
  bool _completionDialogShown = false;

  @override
  void initState() {
    super.initState();
    _totalPoints = widget.questions.fold<int>(
      0,
      (sum, question) => sum + question.points,
    );
    _sessionStartTime = DateTime.now();
    _startSession();
  }

  Future<void> _startSession() async {
    try {
      final auth = context.read<AuthProvider>();
      final child = auth.currentChild ?? auth.currentUser;

      if (child == null) {
        debugPrint('⚠️ No child logged in for session tracking');
        return;
      }

      final activityId = widget.lesson.content['activityId'] as String? ??
          widget.lesson.metadata['activityId'] as String? ??
          widget.lesson.id;

      _sessionId = await _progressService.startActivitySession(
        childId: child.id,
        activityId: activityId,
        gameType: widget.gameType,
      );
      debugPrint('✅ Started game session: $_sessionId');
    } catch (e) {
      debugPrint('❌ Error starting session: $e');
    }
  }

  void _onAnswerSubmitted({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) async {
    final question = widget.questions[_currentQuestionIndex];
    final timeSpent = DateTime.now().difference(_sessionStartTime).inSeconds;

    // Track the answer
    final response = GameResponse(
      id: 'response_${questionId}_${DateTime.now().millisecondsSinceEpoch}',
      questionId: questionId,
      questionTemplateId: question.id,
      userAnswer: userAnswer,
      correctAnswer: question.correctAnswer,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? pointsEarned : 0,
      timeSpentSeconds: timeSpent,
      answeredAt: DateTime.now(),
      responseMetadata: {
        'questionIndex': _currentQuestionIndex,
        'totalQuestions': widget.questions.length,
      },
    );

    _allResponses.add(response);

    // Record in database if session is active
    if (_sessionId != null) {
      try {
        await _progressService.recordQuestionAnswer(
          sessionId: _sessionId!,
          questionId: questionId,
          questionTemplateId: question.id,
          userAnswer: userAnswer,
          correctAnswer: question.correctAnswer,
          isCorrect: isCorrect,
          pointsEarned: pointsEarned,
          timeSpentSeconds: timeSpent,
        );
      } catch (e) {
        debugPrint('❌ Error recording answer: $e');
      }
    }

    setState(() {
      _answers[questionId] = {
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
        'pointsEarned': pointsEarned,
      };

      if (isCorrect) {
        _score += pointsEarned;
        _totalCorrectAnswers++;
      }
    });

    // Show feedback and auto-advance for correct answers
    if (isCorrect) {
      HapticFeedback.lightImpact();
      _showSuccessFeedback(pointsEarned);
      // Auto-advance to next question after a delay
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      _showTryAgainFeedback();
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeGame();
    }
  }

  Future<void> _completeGame() async {
    // Prevent multiple calls
    if (_gameCompleted || _completionDialogShown) return;

    setState(() {
      _gameCompleted = true;
      _completionDialogShown = true;
    });
    HapticFeedback.mediumImpact();

    // Complete the session in database
    if (_sessionId != null) {
      try {
        final auth = context.read<AuthProvider>();
        final child = auth.currentChild ?? auth.currentUser;

        if (child != null) {
          final activityId = widget.lesson.content['activityId'] as String? ??
              widget.lesson.metadata['activityId'] as String? ??
              widget.lesson.id;

          final totalTime =
              DateTime.now().difference(_sessionStartTime).inSeconds;

          await _progressService.completeActivitySession(
            sessionId: _sessionId!,
            childId: child.id,
            activityId: activityId,
            totalScore: _totalCorrectAnswers,
            totalPoints: widget.questions.length,
            totalPointsEarned: _score,
            totalTimeSeconds: totalTime,
            allResponses: _allResponses,
          );

          debugPrint('✅ Activity session completed and saved to database');
        }
      } catch (e) {
        debugPrint('❌ Error completing session: $e');
      }
    }

    _showCompletionCelebration();
  }

  void _showSuccessFeedback(int pointsEarned) {
    // For bubble pop grammar game, coin animation is handled in the game widget itself
    // So we skip the dialog animation here to avoid duplicate animations
    if (widget.gameType == GameType.bubblePopGrammar) {
      // No message needed - coin animation handles the feedback
      return;
    } else {
      // For other games, show the full celebration dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (context) => Stack(
          children: [
            // Floating coins effect
            FloatingCoinsAnimation(
              coinCount: math.min(pointsEarned, 10),
              duration: const Duration(milliseconds: 2000),
              onComplete: () {},
            ),
            // Celebration overlay
            JuniorCelebrationOverlay(
              isVisible: true,
              message: 'Great Job! 🌟',
              subMessage: 'You earned coins! 💰',
              points: pointsEarned,
              onDismiss: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  _nextQuestion();
                });
              },
            ),
          ],
        ),
      );
    }
  }

  void _showTryAgainFeedback() {
    final question = widget.questions[_currentQuestionIndex];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question.hint ?? 'Try again! You can do it!',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: JuniorTheme.primaryYellow,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCompletionCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Confetti background
          JuniorConfetti(
            isActive: true,
            duration: const Duration(seconds: 4),
            particleCount: 150,
          ),
          // Completion dialog
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JuniorTheme.backgroundCard,
                    JuniorTheme.backgroundCard.withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
                boxShadow: JuniorTheme.shadowHeavy,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated celebration icon
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                JuniorTheme.primaryGreen,
                                JuniorTheme.primaryYellow,
                                JuniorTheme.primaryOrange,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    JuniorTheme.primaryGreen.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.celebration,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: JuniorTheme.spacingLarge),
                  // Congratulations text
                  Text(
                    'Congratulations!',
                    style: JuniorTheme.headingLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: JuniorTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: JuniorTheme.spacingSmall),
                  Text(
                    'You completed ${widget.gameTitle}!',
                    style: JuniorTheme.bodyLarge.copyWith(
                      fontSize: 18,
                      color: JuniorTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: JuniorTheme.spacingLarge),
                  // Score and coins section
                  Container(
                    padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          JuniorTheme.primaryGreen.withOpacity(0.2),
                          JuniorTheme.primaryYellow.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusMedium),
                      border: Border.all(
                        color: JuniorTheme.primaryGreen.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: JuniorTheme.accentGold,
                              size: 24,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Score: $_score / $_totalPoints',
                                style: JuniorTheme.headingMedium.copyWith(
                                  color: JuniorTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: JuniorTheme.spacingSmall),
                        // Animated coin counter
                        AnimatedCoinCounter(
                          key: const ValueKey('completion_coin_counter'),
                          coins: _score,
                          textStyle: JuniorTheme.headingLarge.copyWith(
                            color: JuniorTheme.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: JuniorTheme.spacingLarge),
                  // Back button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JuniorTheme.primaryGreen,
                      minimumSize: const Size(double.infinity, 64),
                      padding: const EdgeInsets.symmetric(
                        horizontal: JuniorTheme.spacingLarge,
                        vertical: JuniorTheme.spacingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(JuniorTheme.radiusMedium),
                      ),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameCompleted) {
      return Scaffold(
        backgroundColor: JuniorTheme.backgroundLight,
        body: Center(
          child: Text(
            'Game Complete!',
            style: JuniorTheme.headingLarge,
          ),
        ),
      );
    }

    if (_currentQuestionIndex >= widget.questions.length) {
      return Scaffold(
        backgroundColor: JuniorTheme.backgroundLight,
        body: Center(
          child: Text(
            'All questions completed!',
            style: JuniorTheme.headingMedium,
          ),
        ),
      );
    }

    final question = widget.questions[_currentQuestionIndex];

    // Route to appropriate game widget based on game type
    return Scaffold(
      backgroundColor: JuniorTheme.backgroundLight,
      body: _buildGameWidget(question),
    );
  }

  Widget _buildGameWidget(ActivityQuestion question) {
    switch (widget.gameType) {
      case GameType.numberGridRace:
        return NumberGridRaceGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.koalaCounterAdventure:
        return KoalaCounterAdventureGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.ordinalDragOrder:
        return OrdinalDragOrderGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.patternBuilder:
        return PatternBuilderGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.bubblePopGrammar:
        return BubblePopGrammarGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
          currentScore: _score,
          coinCounterKey: _coinCounterKey,
          onComplete: () {
            // When final question is answered, complete the game
            if (_currentQuestionIndex >= widget.questions.length - 1) {
              _completeGame();
            }
          },
        );
      case GameType.seashellQuiz:
        return SeashellQuizGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.fishTankQuiz:
        return FishTankQuizGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.memoryMatch:
        return MemoryMatchGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.wordBuilder:
        return WordBuilderGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      case GameType.storySequencer:
        return StorySequencerGame(
          question: question,
          onAnswerSubmitted: _onAnswerSubmitted,
        );
      default:
        return Center(
          child: Text(
            'Game type ${widget.gameType.name} coming soon!',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        );
    }
  }
}
