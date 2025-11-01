import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../widgets/junior/junior_confetti.dart';

/// Number Hunt games category
class NumberHuntGamesScreen extends StatefulWidget {
  const NumberHuntGamesScreen({super.key});

  @override
  State<NumberHuntGamesScreen> createState() => _NumberHuntGamesScreenState();
}

class _NumberHuntGamesScreenState extends State<NumberHuntGamesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  int _currentGameIndex = 0;
  int _totalCoins = 0;

  final List<Map<String, dynamic>> _games = [
    {
      'title': 'Stick Bundle Count',
      'points': 15,
      'description':
          'Look at the picture of sticks. If there are 2 bundles of sticks and 4 single sticks, how many tens and ones are there? What is the number altogether?',
      'type': 'stick_bundle',
    },
    {
      'title': 'Number Order Sort',
      'points': 20,
      'description':
          'Write the following numbers from smallest to largest: 13, 67, 113, 48, 37, 52, 84.',
      'type': 'number_sort',
    },
    {
      'title': 'Neighbors Challenge',
      'points': 10,
      'description': 'Circle the number that is between 49 and 51.',
      'type': 'neighbors',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: JuniorTheme.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: JuniorTheme.smoothCurve),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              'Number Hunt',
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
                    color: JuniorTheme.primaryYellow.withOpacity(0.2),
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
      case 'stick_bundle':
        return _buildStickBundleGame();
      case 'number_sort':
        return _buildNumberSortGame();
      case 'neighbors':
        return _buildNeighborsGame();
      default:
        return const Center(child: Text('Game not found'));
    }
  }

  Widget _buildStickBundleGame() {
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
            'Look at the picture of sticks. If there are 2 bundles of sticks and 4 single sticks, how many tens and ones are there? What is the number altogether?',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Visual representation
          _buildStickVisualization(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer inputs
          _buildStickBundleInputs(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildStickVisualization() {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
      ),
      child: Column(
        children: [
          // Two bundles of 10 sticks each
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStickBundle(10, 'Bundle 1'),
              _buildStickBundle(10, 'Bundle 2'),
            ],
          ),

          const SizedBox(height: JuniorTheme.spacingMedium),

          // Four single sticks
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildSingleStick()),
          ),

          const SizedBox(height: JuniorTheme.spacingSmall),

          Text(
            '4 single sticks',
            style: JuniorTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStickBundle(int count, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: JuniorTheme.primaryBrown,
            borderRadius: BorderRadius.circular(JuniorTheme.radiusSmall),
            border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
          ),
          child: Center(
            child: Text(
              '$count',
              style: JuniorTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingXSmall),
        Text(
          label,
          style: JuniorTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSingleStick() {
    return Container(
      width: 4,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: JuniorTheme.primaryBrown,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStickBundleInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberInput('Tens', '2'),
            ),
            const SizedBox(width: JuniorTheme.spacingMedium),
            Expanded(
              child: _buildNumberInput('Ones', '4'),
            ),
          ],
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        _buildNumberInput('Altogether', '24'),
      ],
    );
  }

  Widget _buildNumberInput(String label, String correctAnswer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: JuniorTheme.bodyMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingXSmall),
        Container(
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
              hintText: 'Enter number',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingMedium,
              ),
            ),
            onChanged: (value) {
              // Check answer logic would go here
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSortGame() {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: Column(
        children: [
          Text(
            'Write the following numbers from smallest to largest: 13, 67, 113, 48, 37, 52, 84.',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Draggable number cards
          _buildDraggableNumbers(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer area
          _buildAnswerArea(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildDraggableNumbers() {
    final numbers = [13, 67, 113, 48, 37, 52, 84];

    return Wrap(
      spacing: JuniorTheme.spacingSmall,
      runSpacing: JuniorTheme.spacingSmall,
      children: numbers.map((number) => _buildNumberCard(number)).toList(),
    );
  }

  Widget _buildNumberCard(int number) {
    return Draggable<int>(
      data: number,
      feedback: _buildNumberCardContent(number, true),
      childWhenDragging: _buildNumberCardContent(number, false),
      child: _buildNumberCardContent(number, true),
    );
  }

  Widget _buildNumberCardContent(int number, bool isVisible) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color:
            isVisible ? JuniorTheme.primaryGreen : JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(
          color: JuniorTheme.primaryGreen,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: JuniorTheme.bodyLarge.copyWith(
            color: isVisible ? Colors.white : JuniorTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerArea() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
      ),
      child: DragTarget<int>(
        onWillAccept: (data) => true,
        onAccept: (data) {
          // Handle dropped number
        },
        builder: (context, candidateData, rejectedData) {
          return Center(
            child: Text(
              'Drop numbers here in order',
              style: JuniorTheme.bodyMedium.copyWith(
                color: JuniorTheme.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNeighborsGame() {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: Column(
        children: [
          Text(
            'Circle the number that is between 49 and 51.',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Number options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberOption(49, false),
              _buildNumberOption(50, true), // Correct answer
              _buildNumberOption(51, false),
            ],
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNumberOption(int number, bool isCorrect) {
    return GestureDetector(
      onTap: () => _handleNumberSelection(number, isCorrect),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: JuniorTheme.primaryGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
          border: Border.all(
            color: JuniorTheme.primaryGreen,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: JuniorTheme.headingLarge.copyWith(
              color: JuniorTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              '🎉 Congratulations!',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            Text(
              'You completed all Number Hunt games!',
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

  void _handleNumberSelection(int number, bool isCorrect) {
    if (isCorrect) {
      _showSuccessFeedback();
    } else {
      _showTryAgainFeedback();
    }
  }

  void _handleSubmit() {
    // Check answer and show feedback
    _showSuccessFeedback();
  }

  void _showSuccessFeedback() {
    setState(() {
      _totalCoins += _games[_currentGameIndex]['points'] as int;
    });

    // Show confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JuniorCelebrationOverlay(
        isVisible: true,
        message: 'Great job!',
        subMessage: 'You earned ${_games[_currentGameIndex]['points']} coins!',
        points: _games[_currentGameIndex]['points'] as int,
        onDismiss: () {
          Navigator.of(context).pop(); // Close confetti
          setState(() {
            _currentGameIndex++;
          });
        },
      ),
    );
  }

  void _showTryAgainFeedback() {
    // Show gentle feedback for incorrect answer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Try again! You can do it!'),
        backgroundColor: JuniorTheme.primaryYellow,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
