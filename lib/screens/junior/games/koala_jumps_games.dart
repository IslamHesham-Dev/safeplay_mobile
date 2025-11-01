import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../widgets/junior/junior_confetti.dart';

/// Koala Jumps games category
class KoalaJumpsGamesScreen extends StatefulWidget {
  const KoalaJumpsGamesScreen({super.key});

  @override
  State<KoalaJumpsGamesScreen> createState() => _KoalaJumpsGamesScreenState();
}

class _KoalaJumpsGamesScreenState extends State<KoalaJumpsGamesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _koalaController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _koalaAnimation;

  int _currentGameIndex = 0;
  int _totalCoins = 0;

  final List<Map<String, dynamic>> _games = [
    {
      'title': 'Quick Count On',
      'points': 15,
      'description': 'Count on from the bigger number: What is 23 and 9?',
      'type': 'count_on',
      'numbers': [23, 9],
      'answer': 32,
    },
    {
      'title': 'Count Back Subtraction',
      'points': 15,
      'description':
          'Show on the number line and solve: 19 take away 6 is ___.',
      'type': 'count_back',
      'numbers': [19, 6],
      'answer': 13,
    },
    {
      'title': 'Partitioning Pop-Up',
      'points': 20,
      'description': 'Find 4 different ways to partition the number 28.',
      'type': 'partitioning',
      'numbers': [28],
      'answer': 4, // Number of ways needed
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: JuniorTheme.animationMedium,
      vsync: this,
    );
    _koalaController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: JuniorTheme.smoothCurve),
    );
    _koalaAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _koalaController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _koalaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuniorTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Game content
              Expanded(
                child: _buildGameContent(),
              ),
            ],
          ),
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
            child: Text(
              'Koala Jumps',
              style: JuniorTheme.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),

          // Coins display
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
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: JuniorTheme.spacingXSmall),
                Text(
                  '$_totalCoins',
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

  Widget _buildGameContent() {
    if (_currentGameIndex >= _games.length) {
      return _buildCompletionScreen();
    }

    final game = _games[_currentGameIndex];

    return Padding(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        children: [
          // Game title and points
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowLight,
            ),
            child: Column(
              children: [
                Text(
                  game['title'],
                  style: JuniorTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: JuniorTheme.spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuniorTheme.spacingSmall,
                    vertical: JuniorTheme.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryGreen.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                  ),
                  child: Text(
                    'Earn ${game['points']} Coins!',
                    style: JuniorTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Game-specific content
          Expanded(
            child: _buildGameWidget(game),
          ),
        ],
      ),
    );
  }

  Widget _buildGameWidget(Map<String, dynamic> game) {
    switch (game['type']) {
      case 'count_on':
        return _buildCountOnGame(game);
      case 'count_back':
        return _buildCountBackGame(game);
      case 'partitioning':
        return _buildPartitioningGame(game);
      default:
        return const Center(child: Text('Game not found'));
    }
  }

  Widget _buildCountOnGame(Map<String, dynamic> game) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: Column(
        children: [
          // Question
          Text(
            'Count on from the bigger number: What is 23 and 9?',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Number line with koala
          _buildNumberLineWithKoala(23, 9, 32),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer input
          _buildAnswerInput(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildCountBackGame(Map<String, dynamic> game) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: Column(
        children: [
          // Question
          Text(
            'Show on the number line and solve: 19 take away 6 is ___.',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Number line with koala
          _buildSubtractionNumberLine(19, 6, 13),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer input
          _buildAnswerInput(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildPartitioningGame(Map<String, dynamic> game) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: Column(
        children: [
          // Question
          Text(
            'Find 4 different ways to partition the number 28.',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Number display
          Container(
            padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
            decoration: BoxDecoration(
              color: JuniorTheme.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
            ),
            child: Text(
              '28',
              style: JuniorTheme.headingLarge.copyWith(
                color: JuniorTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Partitioning inputs
          _buildPartitioningInputs(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNumberLineWithKoala(int start, int add, int answer) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
      ),
      child: Stack(
        children: [
          // Number line
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                final number = start + index;
                final isStart = number == start;
                final isEnd = number == answer;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isStart || isEnd)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isStart
                              ? JuniorTheme.primaryGreen
                              : JuniorTheme.primaryYellow,
                          borderRadius:
                              BorderRadius.circular(JuniorTheme.radiusCircular),
                        ),
                        child: Center(
                          child: Text(
                            '$number',
                            style: JuniorTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: JuniorTheme.primaryGreen.withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(JuniorTheme.radiusCircular),
                        ),
                        child: Center(
                          child: Text(
                            '$number',
                            style: JuniorTheme.bodySmall.copyWith(
                              color: JuniorTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      width: 2,
                      height: 20,
                      color: JuniorTheme.primaryGreen,
                    ),
                  ],
                );
              }),
            ),
          ),

          // Koala character
          AnimatedBuilder(
            animation: _koalaAnimation,
            builder: (context, child) {
              return Positioned(
                left: 20 + (_koalaAnimation.value * 200),
                top: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryBrown,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusCircular),
                  ),
                  child: const Center(
                    child: Text(
                      '🐨',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubtractionNumberLine(int start, int subtract, int answer) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
      ),
      child: Stack(
        children: [
          // Number line
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                final number = start - index;
                final isStart = number == start;
                final isEnd = number == answer;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isStart || isEnd)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isStart
                              ? JuniorTheme.primaryGreen
                              : JuniorTheme.primaryYellow,
                          borderRadius:
                              BorderRadius.circular(JuniorTheme.radiusCircular),
                        ),
                        child: Center(
                          child: Text(
                            '$number',
                            style: JuniorTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: JuniorTheme.primaryGreen.withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(JuniorTheme.radiusCircular),
                        ),
                        child: Center(
                          child: Text(
                            '$number',
                            style: JuniorTheme.bodySmall.copyWith(
                              color: JuniorTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      width: 2,
                      height: 20,
                      color: JuniorTheme.primaryGreen,
                    ),
                  ],
                );
              }),
            ),
          ),

          // Koala character
          AnimatedBuilder(
            animation: _koalaAnimation,
            builder: (context, child) {
              return Positioned(
                right: 20 + (_koalaAnimation.value * 200),
                top: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryBrown,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusCircular),
                  ),
                  child: const Center(
                    child: Text(
                      '🐨',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartitioningInputs() {
    return Column(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Row(
            children: [
              Expanded(
                child: _buildNumberInput('Number 1'),
              ),
              const SizedBox(width: JuniorTheme.spacingSmall),
              const Text(
                '+',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: JuniorTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: JuniorTheme.spacingSmall),
              Expanded(
                child: _buildNumberInput('Number 2'),
              ),
              const SizedBox(width: JuniorTheme.spacingSmall),
              const Text(
                '= 28',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: JuniorTheme.primaryGreen,
                ),
              ),
            ],
          ),
          if (i < 3) const SizedBox(height: JuniorTheme.spacingMedium),
        ],
      ],
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        style: JuniorTheme.headingMedium,
        decoration: InputDecoration(
          hintText: 'Enter your answer',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: JuniorTheme.spacingMedium,
          ),
        ),
        onChanged: (value) {
          // Check answer logic would go here
        },
      ),
    );
  }

  Widget _buildNumberInput(String label) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        style: JuniorTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: JuniorTheme.spacingSmall,
          ),
        ),
        onChanged: (value) {
          // Check answer logic would go here
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _handleSubmit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: JuniorTheme.spacingMedium,
        ),
        decoration: BoxDecoration(
          gradient: JuniorTheme.primaryGradient,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
          boxShadow: JuniorTheme.shadowMedium,
        ),
        child: Text(
          'Check Answer',
          style: JuniorTheme.buttonText.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎉 Great Job!',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            Text(
              'You completed all Koala Jumps games!',
              style: JuniorTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: JuniorTheme.primaryGradient,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
                boxShadow: JuniorTheme.shadowMedium,
              ),
              child: Text(
                'Total Coins Earned: $_totalCoins',
                style: JuniorTheme.headingMedium.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuniorTheme.spacingLarge,
                  vertical: JuniorTheme.spacingMedium,
                ),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
                  boxShadow: JuniorTheme.shadowMedium,
                ),
                child: Text(
                  'Back to Games',
                  style: JuniorTheme.buttonText.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Check answer and show feedback
    _showSuccessFeedback();
  }

  void _showSuccessFeedback() {
    setState(() {
      _totalCoins += _games[_currentGameIndex]['points'] as int;
    });

    // Start koala animation
    _koalaController.forward();

    // Show confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JuniorCelebrationOverlay(
        isVisible: true,
        message: 'Amazing!',
        subMessage: 'You earned ${_games[_currentGameIndex]['points']} coins!',
        points: _games[_currentGameIndex]['points'] as int,
        onDismiss: () {
          Navigator.of(context).pop(); // Close confetti
          setState(() {
            _currentGameIndex++;
            _koalaController.reset();
          });
        },
      ),
    );
  }
}
