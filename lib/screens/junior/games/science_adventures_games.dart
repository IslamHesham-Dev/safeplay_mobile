import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../widgets/junior/junior_confetti.dart';
import '../../../models/question_template.dart';
import '../../../models/activity.dart';
import '../../../models/user_type.dart';
import '../../../services/question_template_service.dart';

/// Science Adventures games category using Firestore question templates
class ScienceAdventuresGamesScreen extends StatefulWidget {
  const ScienceAdventuresGamesScreen({super.key});

  @override
  State<ScienceAdventuresGamesScreen> createState() =>
      _ScienceAdventuresGamesScreenState();
}

class _ScienceAdventuresGamesScreenState
    extends State<ScienceAdventuresGamesScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _scienceController;
  late final Animation<double> _fadeAnimation;

  int _currentGameIndex = 0;
  int _totalCoins = 0;
  List<QuestionTemplate> _scienceTemplates = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: JuniorTheme.animationMedium,
      vsync: this,
    );
    _scienceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: JuniorTheme.smoothCurve),
    );

    _loadScienceTemplates();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scienceController.dispose();
    super.dispose();
  }

  Future<void> _loadScienceTemplates() async {
    try {
      final service = QuestionTemplateService();
      final templates = await service.getTemplatesByAgeAndSubject(
        ageGroup: AgeGroup.junior,
        subject: ActivitySubject.science,
      );

      setState(() {
        _scienceTemplates =
            templates.take(5).toList(); // Take first 5 for games
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
                child: _loading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _buildGameContent(),
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
              'Science Adventures',
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: JuniorTheme.primaryGreen,
            strokeWidth: 3.0,
          ),
          const SizedBox(height: JuniorTheme.spacingMedium),
          Text(
            'Loading science adventures...',
            style: JuniorTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: JuniorTheme.primaryPink,
            ),
            const SizedBox(height: JuniorTheme.spacingMedium),
            Text(
              'Oops! Something went wrong',
              style: JuniorTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingSmall),
            Text(
              _error ?? 'Unknown error',
              style: JuniorTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            GestureDetector(
              onTap: _loadScienceTemplates,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuniorTheme.spacingLarge,
                  vertical: JuniorTheme.spacingMedium,
                ),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                  boxShadow: JuniorTheme.shadowLight,
                ),
                child: Text(
                  'Try Again',
                  style: JuniorTheme.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    if (_currentGameIndex >= _scienceTemplates.length) {
      return _buildCompletionScreen();
    }

    final template = _scienceTemplates[_currentGameIndex];

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
                  template.title,
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
                    color: JuniorTheme.primaryOrange.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                  ),
                  child: Text(
                    'Earn ${template.defaultPoints} Coins!',
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
            child: _buildGameWidget(template),
          ),
        ],
      ),
    );
  }

  Widget _buildGameWidget(QuestionTemplate template) {
    switch (template.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceGame(template);
      case QuestionType.matching:
        return _buildMatchingGame(template);
      case QuestionType.textInput:
        return _buildTextInputGame(template);
      default:
        return _buildMultipleChoiceGame(template);
    }
  }

  Widget _buildMultipleChoiceGame(QuestionTemplate template) {
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
            template.prompt,
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          if (template.hint != null) ...[
            const SizedBox(height: JuniorTheme.spacingMedium),
            Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(color: JuniorTheme.primaryYellow),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: JuniorTheme.primaryOrange,
                    size: 20,
                  ),
                  const SizedBox(width: JuniorTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      template.hint!,
                      style: JuniorTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Answer options
          _buildMultipleChoiceOptions(template),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(QuestionTemplate template) {
    return Column(
      children: template.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isCorrect = option == template.correctAnswer;

        return Padding(
          padding: const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
          child: GestureDetector(
            onTap: () => _handleAnswerSelection(option, isCorrect),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(
                  color: JuniorTheme.primaryOrange,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryOrange.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusCircular),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: JuniorTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: JuniorTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: JuniorTheme.spacingMedium),
                  Expanded(
                    child: Text(
                      option,
                      style: JuniorTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatchingGame(QuestionTemplate template) {
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
            template.prompt,
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Matching pairs
          _buildMatchingPairs(template),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildMatchingPairs(QuestionTemplate template) {
    return Column(
      children: [
        // Left side (options)
        Text(
          'Match the items:',
          style: JuniorTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),

        // Options
        Wrap(
          spacing: JuniorTheme.spacingSmall,
          runSpacing: JuniorTheme.spacingSmall,
          children: template.options
              .map((option) => _buildDraggableItem(option))
              .toList(),
        ),

        const SizedBox(height: JuniorTheme.spacingLarge),

        // Right side (answers)
        Text(
          'To their matches:',
          style: JuniorTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),

        // Answer area
        Container(
          height: 200,
          padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
          decoration: BoxDecoration(
            color: JuniorTheme.backgroundLight,
            borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
            border: Border.all(color: JuniorTheme.primaryOrange, width: 2),
          ),
          child: DragTarget<String>(
            onWillAccept: (data) => true,
            onAccept: (data) {
              // Handle dropped item
            },
            builder: (context, candidateData, rejectedData) {
              return Center(
                child: Text(
                  'Drop items here to match',
                  style: JuniorTheme.bodyMedium.copyWith(
                    color: JuniorTheme.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableItem(String text) {
    return Draggable<String>(
      data: text,
      feedback: _buildItemContent(text, true),
      childWhenDragging: _buildItemContent(text, false),
      child: _buildItemContent(text, true),
    );
  }

  Widget _buildItemContent(String text, bool isVisible) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: JuniorTheme.spacingMedium,
        vertical: JuniorTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color:
            isVisible ? JuniorTheme.primaryOrange : JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(
          color: JuniorTheme.primaryOrange,
          width: 2,
        ),
      ),
      child: Text(
        text,
        style: JuniorTheme.bodyMedium.copyWith(
          color: isVisible ? Colors.white : JuniorTheme.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextInputGame(QuestionTemplate template) {
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
            template.prompt,
            style: JuniorTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          if (template.hint != null) ...[
            const SizedBox(height: JuniorTheme.spacingMedium),
            Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(color: JuniorTheme.primaryYellow),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: JuniorTheme.primaryOrange,
                    size: 20,
                  ),
                  const SizedBox(width: JuniorTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      template.hint!,
                      style: JuniorTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],

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

  Widget _buildAnswerInput() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(color: JuniorTheme.primaryOrange),
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
              '🔬 Science Explorer!',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
            Text(
              'You completed all Science Adventures!',
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
                  color: JuniorTheme.primaryOrange,
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

  void _handleAnswerSelection(String answer, bool isCorrect) {
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
      _totalCoins += _scienceTemplates[_currentGameIndex].defaultPoints;
    });

    // Start science animation
    _scienceController.forward();

    // Show confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JuniorCelebrationOverlay(
        isVisible: true,
        message: 'Brilliant!',
        subMessage:
            'You earned ${_scienceTemplates[_currentGameIndex].defaultPoints} coins!',
        points: _scienceTemplates[_currentGameIndex].defaultPoints,
        onDismiss: () {
          Navigator.of(context).pop(); // Close confetti
          setState(() {
            _currentGameIndex++;
            _scienceController.reset();
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
