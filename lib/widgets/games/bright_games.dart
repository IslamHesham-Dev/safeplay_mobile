import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../design_system/colors.dart';
import '../../models/game_activity.dart';
import '../../models/activity.dart';

/// Fraction Navigator Game for Bright Minds
class FractionNavigatorGame extends StatefulWidget {
  final GameConfig gameConfig;
  final List<ActivityQuestion> questions;
  final Function(GameResponse) onResponse;
  final VoidCallback? onComplete;

  const FractionNavigatorGame({
    super.key,
    required this.gameConfig,
    required this.questions,
    required this.onResponse,
    this.onComplete,
  });

  @override
  State<FractionNavigatorGame> createState() => _FractionNavigatorGameState();
}

class _FractionNavigatorGameState extends State<FractionNavigatorGame>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<FractionValue> _values = [];
  List<FractionValue> _sortedValues = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _gameCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    if (_currentQuestionIndex >= widget.questions.length) return;

    final question = widget.questions[_currentQuestionIndex];
    _values = _generateFractionValues(question);
    _sortedValues = List.from(_values);
  }

  List<FractionValue> _generateFractionValues(ActivityQuestion question) {
    final values = <FractionValue>[];
    final random = Random();

    // Generate 5-7 mixed values (fractions, decimals, percentages)
    for (int i = 0; i < 6; i++) {
      final type = random.nextInt(3);
      switch (type) {
        case 0: // Fraction
          final numerator = random.nextInt(8) + 1;
          final denominator = random.nextInt(8) + 2;
          values.add(FractionValue.fraction(numerator, denominator));
          break;
        case 1: // Decimal
          final decimal = (random.nextDouble() * 2).toStringAsFixed(2);
          values.add(FractionValue.decimal(double.parse(decimal)));
          break;
        case 2: // Percentage
          final percentage = random.nextInt(200);
          values.add(FractionValue.percentage(percentage));
          break;
      }
    }

    return values;
  }

  void _onValueTap(int index) {
    if (_gameCompleted) return;

    setState(() {
      final value = _values[index];
      _values.removeAt(index);
      _sortedValues.add(value);
    });

    HapticFeedback.lightImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    _checkOrdering();
  }

  void _checkOrdering() {
    if (_values.isEmpty) {
      final isCorrect = _isCorrectlyOrdered();

      if (isCorrect) {
        setState(() {
          _score += 30;
        });
        HapticFeedback.lightImpact();
        _nextQuestion();
      } else {
        HapticFeedback.heavyImpact();
        _showIncorrectOrdering();
      }
    }
  }

  bool _isCorrectlyOrdered() {
    for (int i = 0; i < _sortedValues.length - 1; i++) {
      if (_sortedValues[i].decimalValue > _sortedValues[i + 1].decimalValue) {
        return false;
      }
    }
    return true;
  }

  void _showIncorrectOrdering() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Not quite right! Try ordering from smallest to largest.'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Reset',
          onPressed: _resetCurrentQuestion,
        ),
      ),
    );
  }

  void _resetCurrentQuestion() {
    setState(() {
      _values = List.from(_sortedValues);
      _sortedValues.clear();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _initializeGame();
    } else {
      _endGame();
    }
  }

  void _endGame() {
    setState(() {
      _gameCompleted = true;
    });
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePlayColors.brightIndigo.withValues(alpha: 0.1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Question display
            _buildQuestionDisplay(),

            // Values to sort
            _buildValuesToSort(),

            // Sorted values
            _buildSortedValues(),

            // Progress
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score: $_score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SafePlayColors.brightIndigo,
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay() {
    if (_currentQuestionIndex >= widget.questions.length)
      return const SizedBox();

    final question = widget.questions[_currentQuestionIndex];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SafePlayColors.brightIndigo.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SafePlayColors.brightIndigo,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildValuesToSort() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap to sort (smallest to largest):',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SafePlayColors.brightIndigo,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _values.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              return ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () => _onValueTap(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: SafePlayColors.brightIndigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value.displayString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortedValues() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your order:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SafePlayColors.brightIndigo,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SafePlayColors.brightIndigo, width: 2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortedValues.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brightIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SafePlayColors.brightIndigo),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${index + 1}.',
                        style: TextStyle(
                          color: SafePlayColors.brightIndigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        value.displayString,
                        style: TextStyle(
                          color: SafePlayColors.brightIndigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: _currentQuestionIndex / widget.questions.length,
        backgroundColor: SafePlayColors.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(SafePlayColors.brightIndigo),
      ),
    );
  }
}

/// Inverse Operation Chain Game for Bright Minds
class InverseOperationChainGame extends StatefulWidget {
  final GameConfig gameConfig;
  final List<ActivityQuestion> questions;
  final Function(GameResponse) onResponse;
  final VoidCallback? onComplete;

  const InverseOperationChainGame({
    super.key,
    required this.gameConfig,
    required this.questions,
    required this.onResponse,
    this.onComplete,
  });

  @override
  State<InverseOperationChainGame> createState() =>
      _InverseOperationChainGameState();
}

class _InverseOperationChainGameState extends State<InverseOperationChainGame> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String _userAnswer = '';
  bool _showScratchpad = false;
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final question = widget.questions[_currentQuestionIndex];
    final correctAnswer = question.correctAnswer?.toString() ?? '';
    final isCorrect = _userAnswer.trim() == correctAnswer;

    if (isCorrect) {
      setState(() {
        _score += 25;
      });
      HapticFeedback.lightImpact();
      _nextQuestion();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try again! The correct answer is $correctAnswer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _userAnswer = '';
        _answerController.clear();
      });
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= widget.questions.length) {
      return _buildCompletionScreen();
    }

    final question = widget.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: SafePlayColors.brightIndigo.withValues(alpha: 0.1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Question display
            _buildQuestionDisplay(question),

            // Scratchpad toggle
            _buildScratchpadToggle(),

            // Scratchpad (if enabled)
            if (_showScratchpad) _buildScratchpad(),

            // Answer input
            _buildAnswerInput(),

            // Progress
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score: $_score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SafePlayColors.brightIndigo,
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay(ActivityQuestion question) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SafePlayColors.brightIndigo.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SafePlayColors.brightIndigo,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          if (question.hint != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SafePlayColors.brightIndigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 ${question.hint}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.brightIndigo,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScratchpadToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.edit_note,
            color: SafePlayColors.brightIndigo,
          ),
          const SizedBox(width: 8),
          Text(
            'Use scratchpad to work out your answer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SafePlayColors.brightIndigo,
                ),
          ),
          const Spacer(),
          Switch(
            value: _showScratchpad,
            onChanged: (value) {
              setState(() {
                _showScratchpad = value;
              });
            },
            activeColor: SafePlayColors.brightIndigo,
          ),
        ],
      ),
    );
  }

  Widget _buildScratchpad() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafePlayColors.brightIndigo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Work:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SafePlayColors.brightIndigo,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Write your calculations here...',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calculate),
            ),
            onChanged: (value) {
              setState(() {
                _userAnswer = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _userAnswer.isNotEmpty ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SafePlayColors.brightIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Answer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: _currentQuestionIndex / widget.questions.length,
        backgroundColor: SafePlayColors.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(SafePlayColors.brightIndigo),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: SafePlayColors.brightIndigo.withValues(alpha: 0.1),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: SafePlayColors.brightIndigo.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration,
                size: 80,
                color: SafePlayColors.brightIndigo,
              ),
              const SizedBox(height: 24),
              Text(
                'Congratulations!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: SafePlayColors.brightIndigo,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'You completed the Inverse Operation Chain!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Final Score: $_score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: SafePlayColors.brightIndigo,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafePlayColors.brightIndigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fraction value model for the fraction navigator game
class FractionValue {
  final double decimalValue;
  final String displayString;
  final FractionType type;

  FractionValue._(this.decimalValue, this.displayString, this.type);

  factory FractionValue.fraction(int numerator, int denominator) {
    final decimal = numerator / denominator;
    return FractionValue._(
      decimal,
      '$numerator/$denominator',
      FractionType.fraction,
    );
  }

  factory FractionValue.decimal(double value) {
    return FractionValue._(
      value,
      value.toStringAsFixed(2),
      FractionType.decimal,
    );
  }

  factory FractionValue.percentage(int value) {
    final decimal = value / 100.0;
    return FractionValue._(
      decimal,
      '$value%',
      FractionType.percentage,
    );
  }
}

enum FractionType { fraction, decimal, percentage }
