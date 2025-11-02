import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Ordinal Drag Order Game Widget
/// For questions about ordinal numbers and ordering
class OrdinalDragOrderGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const OrdinalDragOrderGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<OrdinalDragOrderGame> createState() => _OrdinalDragOrderGameState();
}

class _OrdinalDragOrderGameState extends State<OrdinalDragOrderGame> {
  List<String> _selectedOrder = [];
  List<String> _availableOptions = [];
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _availableOptions = List.from(widget.question.options);
  }

  void _checkAnswer() {
    if (_selectedOrder.length != widget.question.options.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please arrange all items!'),
          backgroundColor: JuniorTheme.primaryYellow,
        ),
      );
      return;
    }

    setState(() {
      _hasSubmitted = true;
    });

    final correctAnswer = widget.question.correctAnswer;
    final isCorrect = _isAnswerCorrect(_selectedOrder, correctAnswer);

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: _selectedOrder,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.question.points : 0,
    );
  }

  bool _isAnswerCorrect(List<String> userAnswer, dynamic correctAnswer) {
    if (correctAnswer is List) {
      return userAnswer.toString() == correctAnswer.toString();
    }
    return userAnswer.toString() == correctAnswer.toString();
  }

  void _removeFromOrder(int index) {
    setState(() {
      final item = _selectedOrder.removeAt(index);
      _availableOptions.add(item);
    });
  }

  void _addToOrder(String item) {
    setState(() {
      _availableOptions.remove(item);
      _selectedOrder.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowMedium,
            ),
            child: Text(
              widget.question.question,
              style: JuniorTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          Text('Drag items to arrange them:'),
          const SizedBox(height: JuniorTheme.spacingMedium),
          // Answer area
          SizedBox(
            height: 200,
            child: Container(
              padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                color: JuniorTheme.backgroundLight,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                border: Border.all(color: JuniorTheme.primaryGreen, width: 2),
              ),
              child: _selectedOrder.isEmpty
                  ? Center(
                      child: Text(
                        'Drag items here to order them',
                        style: JuniorTheme.bodyMedium.copyWith(
                          color: JuniorTheme.textSecondary,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: JuniorTheme.spacingSmall,
                      runSpacing: JuniorTheme.spacingSmall,
                      children: _selectedOrder.asMap().entries.map((entry) {
                        return _buildOrderedItem(entry.value, entry.key);
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          // Available options
          if (_availableOptions.isNotEmpty) ...[
            Text('Available items:'),
            const SizedBox(height: JuniorTheme.spacingMedium),
            Wrap(
              spacing: JuniorTheme.spacingSmall,
              runSpacing: JuniorTheme.spacingSmall,
              children: _availableOptions.map((option) {
                return _buildAvailableItem(option);
              }).toList(),
            ),
          ],
          const SizedBox(height: JuniorTheme.spacingLarge),
          GestureDetector(
            onTap: _hasSubmitted ? null : _checkAnswer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: _hasSubmitted
                    ? LinearGradient(
                        colors: [JuniorTheme.textLight, JuniorTheme.textLight])
                    : JuniorTheme.primaryGradient,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
                boxShadow: JuniorTheme.shadowMedium,
              ),
              child: Text(
                _hasSubmitted ? 'Answer Submitted!' : 'Check Answer',
                style: JuniorTheme.buttonText.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderedItem(String item, int index) {
    return GestureDetector(
      onTap: () => _removeFromOrder(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingMedium,
          vertical: JuniorTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: JuniorTheme.primaryGreen,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}.',
              style: JuniorTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item,
              style: JuniorTheme.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableItem(String item) {
    return GestureDetector(
      onTap: () => _addToOrder(item),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingMedium,
          vertical: JuniorTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: JuniorTheme.primaryBlue,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
          border: Border.all(color: JuniorTheme.primaryBlue, width: 2),
        ),
        child: Text(
          item,
          style: JuniorTheme.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
