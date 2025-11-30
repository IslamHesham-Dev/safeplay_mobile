import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/activities/question_widget.dart';
import '../../widgets/activities/progress_tracker_widget.dart';
import '../../widgets/activities/completion_celebration_widget.dart';
import '../../services/activity_session_service.dart';

/// Activity player screen for interactive learning
class ActivityPlayerScreen extends StatefulWidget {
  final Activity activity;

  const ActivityPlayerScreen({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityPlayerScreen> createState() => _ActivityPlayerScreenState();
}

class _ActivityPlayerScreenState extends State<ActivityPlayerScreen> {
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  int _score = 0;
  bool _showingFeedback = false;
  bool _isComplete = false;
  late ConfettiController _confettiController;
  final ActivitySessionService _activitySessionService =
      ActivitySessionService();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _startActivity();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _startActivity() async {
    final authProvider = context.read<AuthProvider>();
    final activityProvider = context.read<ActivityProvider>();

    final currentChild = authProvider.currentChild;
    if (currentChild != null) {
      await activityProvider.startActivity(
        currentChild.id,
        widget.activity.id,
      );
      unawaited(
        _activitySessionService.logSession(
          childId: currentChild.id,
          activityId: widget.activity.id,
          title: widget.activity.title,
          subject: widget.activity.subject.name,
          durationMinutes: widget.activity.durationMinutes,
        ),
      );
    }
  }

  Future<void> _submitAnswer(dynamic answer) async {
    setState(() {
      _showingFeedback = true;
    });

    final activityProvider = context.read<ActivityProvider>();
    final currentQuestion = widget.activity.questions[_currentQuestionIndex];

    // Submit answer and check if correct
    final isCorrect = await activityProvider.submitAnswer(
      currentQuestion.id,
      answer,
    );

    // Store answer
    setState(() {
      _answers[currentQuestion.id] = {
        'answer': answer,
        'isCorrect': isCorrect,
      };

      if (isCorrect) {
        _score += currentQuestion.points;
      }
    });

    // Show feedback for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Move to next question or complete
    if (_currentQuestionIndex < widget.activity.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showingFeedback = false;
      });
      await activityProvider.nextQuestion();
    } else {
      await _completeActivity();
    }
  }

  Future<void> _completeActivity() async {
    final activityProvider = context.read<ActivityProvider>();
    final childProvider = context.read<ChildProvider>();
    final authProvider = context.read<AuthProvider>();

    // Complete the activity
    await activityProvider.completeActivity();

    // Award XP to child
    if (authProvider.currentChild != null) {
      await childProvider.addXP(authProvider.currentChild!.id, _score);

      // Check for achievements
      final percentage = (_score / _calculateTotalPoints()) * 100;
      if (percentage == 100) {
        await childProvider.addAchievement(
          authProvider.currentChild!.id,
          'perfect_score',
        );
      }
    }

    // Show celebration
    _confettiController.play();
    setState(() {
      _isComplete = true;
    });
  }

  int _calculateTotalPoints() {
    return widget.activity.questions.fold<int>(
      0,
      (sum, q) => sum + q.points,
    );
  }

  void _exitActivity() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return CompletionCelebrationWidget(
        score: _score,
        totalPoints: _calculateTotalPoints(),
        confettiController: _confettiController,
        onContinue: _exitActivity,
      );
    }

    final currentQuestion = widget.activity.questions[_currentQuestionIndex];
    final isCorrect = _answers[currentQuestion.id]?['isCorrect'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit Activity?'),
                  content: const Text(
                    'Your progress will be saved, but you\'ll need to start over.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress tracker
            ProgressTrackerWidget(
              currentQuestion: _currentQuestionIndex + 1,
              totalQuestions: widget.activity.questions.length,
              score: _score,
            ),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionWidget(
                  question: currentQuestion,
                  onAnswerSelected: _showingFeedback ? null : _submitAnswer,
                  showFeedback: _showingFeedback,
                  isCorrect: isCorrect,
                  selectedAnswer: _answers[currentQuestion.id]?['answer'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
