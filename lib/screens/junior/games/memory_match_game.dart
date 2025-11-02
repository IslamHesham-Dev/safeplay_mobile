import 'package:flutter/material.dart';
import '../../../design_system/junior_theme.dart';
import '../../../models/activity.dart';

/// Memory Match Game Widget
/// For matching questions (rhyming words, synonyms, etc.)
class MemoryMatchGame extends StatefulWidget {
  final ActivityQuestion question;
  final Function({
    required String questionId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int pointsEarned,
  }) onAnswerSubmitted;

  const MemoryMatchGame({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  List<String>? _selectedItem1;
  List<String>? _selectedItem2;
  List<List<String>> _matches = [];
  List<String> _availableItems = [];
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _availableItems = List.from(widget.question.options);
  }

  void _selectItem(String item) {
    if (_selectedItem1 == null) {
      setState(() {
        _selectedItem1 = [item];
      });
    } else if (_selectedItem1!.contains(item)) {
      // Deselect
      setState(() {
        _selectedItem1 = null;
      });
    } else {
      // Second selection
      setState(() {
        _selectedItem2 = [item];
        // Check if they match
        final correctAnswer = widget.question.correctAnswer as List;
        final isMatch = correctAnswer.any((pair) =>
            (pair[0] == _selectedItem1!.first && pair[1] == item) ||
            (pair[0] == item && pair[1] == _selectedItem1!.first));

        if (isMatch) {
          _matches.add([_selectedItem1!.first, item]);
          _availableItems.remove(_selectedItem1!.first);
          _availableItems.remove(item);
          _selectedItem1 = null;
          _selectedItem2 = null;
        } else {
          // Reset after a delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _selectedItem1 = null;
                _selectedItem2 = null;
              });
            }
          });
        }
      });
    }
  }

  void _checkAnswer() {
    final correctAnswer = widget.question.correctAnswer as List;
    final allMatched =
        _matches.length == correctAnswer.length && _availableItems.isEmpty;

    setState(() {
      _hasSubmitted = true;
    });

    widget.onAnswerSubmitted(
      questionId: widget.question.id,
      userAnswer: _matches,
      isCorrect: allMatched,
      pointsEarned: allMatched ? widget.question.points : 0,
    );
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
          if (_matches.isNotEmpty) ...[
            Text('Matched pairs:'),
            const SizedBox(height: JuniorTheme.spacingSmall),
            Wrap(
              spacing: JuniorTheme.spacingSmall,
              children: _matches.map((pair) {
                return Container(
                  padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryGreen,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                  ),
                  child: Text(
                    '${pair[0]} - ${pair[1]}',
                    style: JuniorTheme.bodySmall.copyWith(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),
          ],
          Text('Tap to match:'),
          const SizedBox(height: JuniorTheme.spacingMedium),
          Wrap(
            spacing: JuniorTheme.spacingSmall,
            runSpacing: JuniorTheme.spacingSmall,
            children: _availableItems.map((item) {
              final isSelected1 = _selectedItem1?.contains(item) ?? false;
              final isSelected2 = _selectedItem2?.contains(item) ?? false;
              return GestureDetector(
                onTap: () => _selectItem(item),
                child: Container(
                  padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: isSelected1 || isSelected2
                        ? JuniorTheme.primaryYellow
                        : JuniorTheme.primaryBlue,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusMedium),
                    border: Border.all(
                      color: isSelected1 || isSelected2
                          ? JuniorTheme.primaryOrange
                          : JuniorTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    item,
                    style: JuniorTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: isSelected1 || isSelected2
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: JuniorTheme.spacingLarge),
          if (_availableItems.isEmpty && _matches.isNotEmpty) ...[
            GestureDetector(
              onTap: _hasSubmitted ? null : _checkAnswer,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: JuniorTheme.spacingMedium),
                decoration: BoxDecoration(
                  gradient: _hasSubmitted
                      ? LinearGradient(colors: [
                          JuniorTheme.textLight,
                          JuniorTheme.textLight
                        ])
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
        ],
      ),
    );
  }
}
