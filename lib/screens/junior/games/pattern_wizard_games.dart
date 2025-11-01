import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../widgets/junior/junior_confetti.dart';

/// Pattern Wizard games category
class PatternWizardGamesScreen extends StatefulWidget {
  const PatternWizardGamesScreen({super.key});

  @override
  State<PatternWizardGamesScreen> createState() =>
      _PatternWizardGamesScreenState();
}

class _PatternWizardGamesScreenState extends State<PatternWizardGamesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _magicController;
  late final Animation<double> _fadeAnimation;

  int _currentGameIndex = 0;
  int _totalCoins = 0;

  final List<Map<String, dynamic>> _games = [
    {
      'title': 'Skip Counting by 5s',
      'points': 10,
      'description':
          'Finish the following number pattern: 105, 110, 115, __, __, __, 140.',
      'type': 'skip_counting',
      'pattern': [105, 110, 115, null, null, null, 140],
      'answers': [120, 125, 130],
    },
    {
      'title': 'Ordinal Order',
      'points': 10,
      'description': 'If six dogs are lined up, which dog is 4th?',
      'type': 'ordinal',
      'total': 6,
      'position': 4,
    },
    {
      'title': 'Equal Share Division',
      'points': 15,
      'description': '8 items shared equally between 2 groups is ___.',
      'type': 'division',
      'total': 8,
      'groups': 2,
      'answer': 4,
    },
    {
      'title': 'Halves & Quarters',
      'points': 20,
      'description':
          'For a group of 24 items, colour half red and one quarter blue. How many items did you colour blue?',
      'type': 'fractions',
      'total': 24,
      'half': 12,
      'quarter': 6,
    },
    {
      'title': 'Error Detector',
      'points': 10,
      'description':
          'A pattern is shown as: Red, Green, Red, Green, Blue, Green. Circle the error. What should the colour be?',
      'type': 'pattern_error',
      'pattern': ['Red', 'Green', 'Red', 'Green', 'Blue', 'Green'],
      'error_index': 4,
      'correct_color': 'Red',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: JuniorTheme.animationMedium,
      vsync: this,
    );
    _magicController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    _magicController.dispose();
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
              'Pattern Wizard',
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
                    color: JuniorTheme.primaryPink.withOpacity(0.2),
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
      case 'skip_counting':
        return _buildSkipCountingGame(game);
      case 'ordinal':
        return _buildOrdinalGame(game);
      case 'division':
        return _buildDivisionGame(game);
      case 'fractions':
        return _buildFractionsGame(game);
      case 'pattern_error':
        return _buildPatternErrorGame(game);
      default:
        return const Center(child: Text('Game not found'));
    }
  }

  Widget _buildSkipCountingGame(Map<String, dynamic> game) {
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
            'Finish the following number pattern: 105, 110, 115, __, __, __, 140.',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Pattern display
          _buildSkipCountingPattern(game['pattern']),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer inputs
          _buildSkipCountingInputs(game['answers']),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSkipCountingPattern(List<dynamic> pattern) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryPink, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pattern.asMap().entries.map((entry) {
          final number = entry.value;

          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: number == null
                  ? JuniorTheme.backgroundCard
                  : JuniorTheme.primaryPink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
              border: Border.all(
                color: JuniorTheme.primaryPink,
                width: 2,
              ),
            ),
            child: Center(
              child: number == null
                  ? const Text('?',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                  : Text(
                      '$number',
                      style: JuniorTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkipCountingInputs(List<int> answers) {
    return Column(
      children: [
        Text(
          'Fill in the missing numbers:',
          style: JuniorTheme.bodyMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: answers.asMap().entries.map((entry) {
            return SizedBox(
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                style: JuniorTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '?',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                    borderSide: BorderSide(color: JuniorTheme.primaryPink),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                    borderSide:
                        BorderSide(color: JuniorTheme.primaryPink, width: 2),
                  ),
                ),
                onChanged: (value) {
                  // Check answer logic would go here
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrdinalGame(Map<String, dynamic> game) {
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
            'If six dogs are lined up, which dog is 4th?',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Dogs display
          _buildDogsLineup(game['total'], game['position']),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildDogsLineup(int total, int position) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryPink, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(total, (index) {
          final isFourth = index + 1 == position;

          return GestureDetector(
            onTap: () => _handleDogSelection(index + 1, isFourth),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isFourth
                    ? JuniorTheme.primaryYellow.withOpacity(0.3)
                    : JuniorTheme.primaryPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
                border: Border.all(
                  color: isFourth
                      ? JuniorTheme.primaryYellow
                      : JuniorTheme.primaryPink,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '🐕',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDivisionGame(Map<String, dynamic> game) {
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
            '8 items shared equally between 2 groups is ___.',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Items and groups
          _buildDivisionVisualization(game['total'], game['groups']),

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

  Widget _buildDivisionVisualization(int total, int groups) {
    return Column(
      children: [
        // Items to be divided
        Text(
          'Items to share:',
          style: JuniorTheme.bodyMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Wrap(
          spacing: JuniorTheme.spacingXSmall,
          children: List.generate(
            total,
            (index) => Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: JuniorTheme.primaryPink.withOpacity(0.3),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusSmall),
                border: Border.all(color: JuniorTheme.primaryPink),
              ),
              child: const Center(
                child: Text('🍎', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ),

        const SizedBox(height: JuniorTheme.spacingLarge),

        // Groups
        Text(
          'Groups:',
          style: JuniorTheme.bodyMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            groups,
            (index) => Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: JuniorTheme.backgroundLight,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(color: JuniorTheme.primaryPink, width: 2),
              ),
              child: Center(
                child: Text(
                  'Group ${index + 1}',
                  style: JuniorTheme.bodySmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFractionsGame(Map<String, dynamic> game) {
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
            'For a group of 24 items, colour half red and one quarter blue. How many items did you colour blue?',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Items grid
          _buildFractionsGrid(game['total']),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Color buttons
          _buildColorButtons(),

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

  Widget _buildFractionsGrid(int total) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryPink, width: 2),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: total,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _handleItemColor(index),
            child: Container(
              decoration: BoxDecoration(
                color: JuniorTheme.primaryPink.withOpacity(0.3),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusSmall),
                border: Border.all(color: JuniorTheme.primaryPink),
              ),
              child: const Center(
                child: Text('⭐', style: TextStyle(fontSize: 16)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildColorButton('Red', Colors.red),
        _buildColorButton('Blue', Colors.blue),
        _buildColorButton('Clear', Colors.grey),
      ],
    );
  }

  Widget _buildColorButton(String label, Color color) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingMedium,
          vertical: JuniorTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          style: JuniorTheme.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPatternErrorGame(Map<String, dynamic> game) {
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
            'A pattern is shown as: Red, Green, Red, Green, Blue, Green. Circle the error. What should the colour be?',
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Pattern display
          _buildPatternDisplay(game['pattern'], game['error_index']),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Color selection
          _buildColorSelection(),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildPatternDisplay(List<String> pattern, int errorIndex) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryPink, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pattern.asMap().entries.map((entry) {
          final index = entry.key;
          final color = entry.value;
          final isError = index == errorIndex;

          return GestureDetector(
            onTap: () => _handlePatternError(index, isError),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getColorFromName(color).withOpacity(0.3),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(
                  color: isError ? JuniorTheme.error : _getColorFromName(color),
                  width: isError ? 3 : 2,
                ),
              ),
              child: Center(
                child: Text(
                  color[0].toUpperCase(),
                  style: JuniorTheme.bodyLarge.copyWith(
                    color: _getColorFromName(color),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorSelection() {
    return Column(
      children: [
        Text(
          'What should the colour be?',
          style: JuniorTheme.bodyMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColorOption('Red', Colors.red),
            _buildColorOption('Green', Colors.green),
            _buildColorOption('Blue', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(String label, Color color) {
    return GestureDetector(
      onTap: () => _selectCorrectColor(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingMedium,
          vertical: JuniorTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          style: JuniorTheme.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryPink),
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
              '🎉 Amazing!',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            Text(
              'You completed all Pattern Wizard games!',
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
                  color: JuniorTheme.primaryPink,
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

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handleDogSelection(int position, bool isCorrect) {
    if (isCorrect) {
      _showSuccessFeedback();
    } else {
      _showTryAgainFeedback();
    }
  }

  void _handleItemColor(int index) {
    // Handle item coloring logic
  }

  void _selectColor(Color color) {
    // Handle color selection logic
  }

  void _handlePatternError(int index, bool isError) {
    if (isError) {
      _showSuccessFeedback();
    } else {
      _showTryAgainFeedback();
    }
  }

  void _selectCorrectColor(String color) {
    // Handle correct color selection
    _showSuccessFeedback();
  }

  void _handleSubmit() {
    // Check answer and show feedback
    _showSuccessFeedback();
  }

  void _showSuccessFeedback() {
    setState(() {
      _totalCoins += _games[_currentGameIndex]['points'] as int;
    });

    // Start magic animation
    _magicController.forward();

    // Show confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JuniorCelebrationOverlay(
        isVisible: true,
        message: 'Fantastic!',
        subMessage: 'You earned ${_games[_currentGameIndex]['points']} coins!',
        points: _games[_currentGameIndex]['points'] as int,
        onDismiss: () {
          Navigator.of(context).pop(); // Close confetti
          setState(() {
            _currentGameIndex++;
            _magicController.reset();
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
