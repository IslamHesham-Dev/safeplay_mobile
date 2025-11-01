import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../design_system/colors.dart';
import '../../models/game_activity.dart';
import '../../models/activity.dart';

/// Number Grid Race Game for Junior Explorers
class NumberGridRaceGame extends StatefulWidget {
  final GameConfig gameConfig;
  final List<ActivityQuestion> questions;
  final Function(GameResponse) onResponse;
  final VoidCallback? onComplete;

  const NumberGridRaceGame({
    super.key,
    required this.gameConfig,
    required this.questions,
    required this.onResponse,
    this.onComplete,
  });

  @override
  State<NumberGridRaceGame> createState() => _NumberGridRaceGameState();
}

class _NumberGridRaceGameState extends State<NumberGridRaceGame>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<List<int?>> _grid = [];
  List<int> _missingNumbers = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeRemaining = 300; // 5 minutes default
  bool _gameCompleted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Create 10x10 grid (1-100)
    _grid = List.generate(
        10, (row) => List.generate(10, (col) => row * 10 + col + 1));

    // Randomly hide some numbers based on current question
    if (_currentQuestionIndex < widget.questions.length) {
      final question = widget.questions[_currentQuestionIndex];
      _hideNumbersForQuestion(question);
    }
  }

  void _hideNumbersForQuestion(ActivityQuestion question) {
    // Parse the question to determine which numbers to hide
    final prompt = question.question.toLowerCase();

    if (prompt.contains('skip counting') || prompt.contains('counting by')) {
      // Hide every 2nd, 5th, or 10th number
      final skipBy = _extractSkipCount(prompt);
      for (int i = 0; i < 100; i += skipBy) {
        if (i < 100) {
          final row = i ~/ 10;
          final col = i % 10;
          _grid[row][col] = null;
          _missingNumbers.add(i + 1);
        }
      }
    } else {
      // Hide random numbers for sequence completion
      final random = Random();
      for (int i = 0; i < 10; i++) {
        final number = random.nextInt(100) + 1;
        final row = (number - 1) ~/ 10;
        final col = (number - 1) % 10;
        if (_grid[row][col] != null) {
          _grid[row][col] = null;
          _missingNumbers.add(number);
        }
      }
    }
  }

  int _extractSkipCount(String prompt) {
    if (prompt.contains('by 2')) return 2;
    if (prompt.contains('by 5')) return 5;
    if (prompt.contains('by 10')) return 10;
    return 2; // default
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _onNumberTap(int row, int col) {
    if (_grid[row][col] != null || _gameCompleted) return;

    // Show number input dialog
    _showNumberInputDialog(row, col);
  }

  void _showNumberInputDialog(int row, int col) {
    showDialog(
      context: context,
      builder: (context) => NumberInputDialog(
        onNumberEntered: (number) => _checkAnswer(row, col, number),
        maxNumber: 100,
        hint: 'Enter the missing number',
      ),
    );
  }

  void _checkAnswer(int row, int col, int answer) {
    final expectedNumber = row * 10 + col + 1;
    final isCorrect = answer == expectedNumber;

    if (isCorrect) {
      setState(() {
        _grid[row][col] = answer;
        _missingNumbers.remove(answer);
        _score += 10;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Animate correct answer
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Check if all numbers filled
      if (_missingNumbers.isEmpty) {
        _nextQuestion();
      }
    } else {
      // Show error feedback
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try again! The correct number is $expectedNumber'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _initializeGame();
      });
    } else {
      _endGame();
    }
  }

  void _endGame() {
    setState(() {
      _gameCompleted = true;
    });
    _timer?.cancel();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePlayColors.juniorPurple.withValues(alpha: 0.1),
      body: SafeArea(
        child: Column(
          children: [
            // Header with score and timer
            _buildHeader(),

            // Current question
            _buildQuestionDisplay(),

            // Number grid
            Expanded(
              child: _buildNumberGrid(),
            ),

            // Progress indicator
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SafePlayColors.juniorPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Time: ${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: SafePlayColors.juniorPurple,
            ),
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
            color: SafePlayColors.juniorPurple.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SafePlayColors.juniorPurple,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNumberGrid() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          final row = index ~/ 10;
          final col = index % 10;
          final number = _grid[row][col];

          return ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () => _onNumberTap(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: number == null
                      ? SafePlayColors.juniorPurple.withValues(alpha: 0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SafePlayColors.juniorPurple,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: number == null
                      ? Icon(
                          Icons.edit,
                          color: SafePlayColors.juniorPurple,
                          size: 16,
                        )
                      : Text(
                          number.toString(),
                          style: TextStyle(
                            color: SafePlayColors.juniorPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: _currentQuestionIndex / widget.questions.length,
        backgroundColor: SafePlayColors.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(SafePlayColors.juniorPurple),
      ),
    );
  }
}

/// Koala Counter's Adventure Game for Junior Explorers
class KoalaCounterAdventureGame extends StatefulWidget {
  final GameConfig gameConfig;
  final List<ActivityQuestion> questions;
  final Function(GameResponse) onResponse;
  final VoidCallback? onComplete;

  const KoalaCounterAdventureGame({
    super.key,
    required this.gameConfig,
    required this.questions,
    required this.onResponse,
    this.onComplete,
  });

  @override
  State<KoalaCounterAdventureGame> createState() =>
      _KoalaCounterAdventureGameState();
}

class _KoalaCounterAdventureGameState extends State<KoalaCounterAdventureGame>
    with TickerProviderStateMixin {
  late AnimationController _koalaController;

  int _currentQuestionIndex = 0;
  int _score = 0;
  double _koalaPositionValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _koalaController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _koalaController.dispose();
    super.dispose();
  }

  void _onKoalaDrag(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _koalaPositionValue =
            (_koalaPositionValue + details.delta.dx / 300).clamp(0.0, 1.0);
      });
    }
  }

  void _onKoalaDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onKoalaDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _checkAnswer();
  }

  void _checkAnswer() {
    // Calculate the expected position based on the question
    final question = widget.questions[_currentQuestionIndex];
    final expectedPosition = _calculateExpectedPosition(question);

    final isCorrect = (_koalaPositionValue - expectedPosition).abs() < 0.1;

    if (isCorrect) {
      setState(() {
        _score += 20;
      });
      HapticFeedback.lightImpact();
      _nextQuestion();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again! Use the number line to help you.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateExpectedPosition(ActivityQuestion question) {
    // Parse the question to determine the correct position
    final prompt = question.question.toLowerCase();

    if (prompt.contains('addition') || prompt.contains('+')) {
      // For addition, move forward
      return 0.7; // Example position
    } else if (prompt.contains('subtraction') || prompt.contains('-')) {
      // For subtraction, move backward
      return 0.3; // Example position
    }

    return 0.5; // Default middle position
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _koalaPositionValue = 0.0;
      });
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePlayColors.juniorPurple.withValues(alpha: 0.1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Question display
            _buildQuestionDisplay(),

            // Number line with koala
            Expanded(
              child: _buildNumberLine(),
            ),

            // Answer input
            _buildAnswerInput(),
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
                  color: SafePlayColors.juniorPurple,
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
            color: SafePlayColors.juniorPurple.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SafePlayColors.juniorPurple,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNumberLine() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Number line
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: SafePlayColors.juniorPurple, width: 3),
            ),
            child: Stack(
              children: [
                // Number line markers
                Row(
                  children: List.generate(11, (index) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          '${index * 10}',
                          style: TextStyle(
                            color: SafePlayColors.juniorPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Koala character
                Positioned(
                  left: _koalaPositionValue *
                      (MediaQuery.of(context).size.width - 32 - 40),
                  top: 10,
                  child: GestureDetector(
                    onPanStart: _onKoalaDragStart,
                    onPanUpdate: _onKoalaDrag,
                    onPanEnd: _onKoalaDragEnd,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: SafePlayColors.juniorPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SafePlayColors.juniorPurple
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Instructions
          Text(
            'Drag the koala along the number line to solve the problem!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SafePlayColors.neutral600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _checkAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: SafePlayColors.juniorPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: const Text('Check Answer'),
      ),
    );
  }
}

/// Number input dialog for grid game
class NumberInputDialog extends StatefulWidget {
  final Function(int) onNumberEntered;
  final int maxNumber;
  final String hint;

  const NumberInputDialog({
    super.key,
    required this.onNumberEntered,
    required this.maxNumber,
    required this.hint,
  });

  @override
  State<NumberInputDialog> createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<NumberInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Number'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number';
            }
            final number = int.tryParse(value);
            if (number == null || number < 1 || number > widget.maxNumber) {
              return 'Please enter a number between 1 and ${widget.maxNumber}';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final number = int.parse(_controller.text);
              widget.onNumberEntered(number);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
