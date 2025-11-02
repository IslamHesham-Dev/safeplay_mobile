import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';
import '../../../models/game_activity.dart';
import '../../../models/lesson.dart';
import '../../../widgets/junior/junior_confetti.dart';
import 'number_grid_race_game.dart';
import 'koala_counter_adventure_game.dart';
import 'ordinal_drag_order_game.dart';
import 'pattern_builder_game.dart';
import 'memory_match_game.dart';
import 'word_builder_game.dart';
import 'story_sequencer_game.dart';

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

  @override
  void initState() {
    super.initState();
    _totalPoints = widget.questions.fold<int>(
      0,
      (sum, question) => sum + question.points,
    );
  }

  void _onAnswerSubmitted({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) {
    setState(() {
      _answers[questionId] = {
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
        'pointsEarned': pointsEarned,
      };

      if (isCorrect) {
        _score += pointsEarned;
      }
    });

    // Show feedback
    if (isCorrect) {
      HapticFeedback.lightImpact();
      _showSuccessFeedback();
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

  void _completeGame() {
    setState(() {
      _gameCompleted = true;
    });
    HapticFeedback.mediumImpact();
    _showCompletionCelebration();
  }

  void _showSuccessFeedback() {
    final question = widget.questions[_currentQuestionIndex];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JuniorCelebrationOverlay(
        isVisible: true,
        message: 'Great Job!',
        subMessage: 'You earned ${question.points} coins!',
        points: question.points,
        onDismiss: () {
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 300), () {
            _nextQuestion();
          });
        },
      ),
    );
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: JuniorTheme.spacingMedium),
            Text(
              'Congratulations!',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingSmall),
            Text(
              'You completed ${widget.gameTitle}!',
              style: JuniorTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: JuniorTheme.primaryGradient,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Score',
                    style: JuniorTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_score / $_totalPoints',
                    style: JuniorTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close game screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: JuniorTheme.primaryGreen,
                minimumSize: const Size(double.infinity, 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: JuniorTheme.spacingLarge,
                  vertical: JuniorTheme.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Back to Dashboard',
                style: JuniorTheme.buttonText.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Progress indicator
            _buildProgressIndicator(),

            // Game content
            Expanded(
              child: _buildGameWidget(question),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        gradient: JuniorTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(JuniorTheme.radiusLarge),
          bottomRight: Radius.circular(JuniorTheme.radiusLarge),
        ),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: JuniorTheme.spacingMedium),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.gameTitle,
                  style: JuniorTheme.headingMedium.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                  style: JuniorTheme.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Score display
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: JuniorTheme.spacingSmall,
              vertical: JuniorTheme.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: JuniorTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: JuniorTheme.bodySmall,
              ),
              Text(
                '${(_currentQuestionIndex + 1)}/${widget.questions.length}',
                style: JuniorTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: JuniorTheme.spacingXSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: JuniorTheme.backgroundCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                JuniorTheme.primaryGreen,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
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
