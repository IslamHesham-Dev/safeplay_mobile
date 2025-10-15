import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../models/activity.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    this.onAnswerSelected,
    required this.showFeedback,
    required this.isCorrect,
    this.selectedAnswer,
  });

  final ActivityQuestion question;
  final Function(dynamic)? onAnswerSelected;
  final bool showFeedback;
  final bool isCorrect;
  final dynamic selectedAnswer;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late final AudioPlayer _audioPlayer;
  bool _isPlayingAudio = false;
  bool _hintVisible = false;
  late List<String> _ordering;
  List<String> _matchingSelections = <String>[];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeInteractiveState();
  }

  @override
  void didUpdateWidget(covariant QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldAnswer = oldWidget.selectedAnswer;
    final newAnswer = widget.selectedAnswer;
    final answersChanged = oldAnswer is List && newAnswer is List
        ? !listEquals(oldAnswer.cast<dynamic>(), newAnswer.cast<dynamic>())
        : oldAnswer != newAnswer;
    if (oldWidget.question.id != widget.question.id || answersChanged) {
      _initializeInteractiveState();
    }
  }

  void _initializeInteractiveState() {
    final baseOptions = _optionsForQuestion();
    if (baseOptions.isNotEmpty) {
      _ordering = List<String>.from(baseOptions);
    } else if (widget.question.correctAnswer is List) {
      _ordering = (widget.question.correctAnswer as List)
          .map((e) => e.toString())
          .toList();
    } else {
      _ordering = <String>[];
    }

    final availableOptions =
        _ordering.isNotEmpty ? _ordering.toSet() : baseOptions.toSet();

    _matchingSelections = <String>[];

    final selected = widget.selectedAnswer;
    if (selected is List) {
      final selectedStrings = selected.map((e) => e.toString()).toList();
      if (widget.question.type == QuestionType.matching) {
        _matchingSelections = selectedStrings
            .where((value) => availableOptions.contains(value))
            .toList();
      } else if (widget.question.type == QuestionType.dragDrop ||
          widget.question.type == QuestionType.sequencing) {
        if (selectedStrings.isNotEmpty) {
          _ordering = List<String>.from(selectedStrings);
        }
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _optionsForQuestion();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.question.imageUrl != null)
          _buildImage(context, widget.question.imageUrl!),
        if (widget.question.audioUrl != null)
          _buildAudioButton(context, widget.question.audioUrl!),
        if (widget.question.videoUrl != null)
          _buildVideoButton(context, widget.question.videoUrl!),
        if (widget.question.imageUrl != null ||
            widget.question.audioUrl != null ||
            widget.question.videoUrl != null)
          const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.question.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildAnswerOptions(context, options),
        if (widget.question.hint != null &&
            widget.question.hint!.trim().isNotEmpty)
          _buildHintToggle(context),
        if (widget.showFeedback &&
            widget.question.explanation != null &&
            widget.question.explanation!.trim().isNotEmpty)
          _buildExplanation(context),
      ],
    );
  }

  Widget _buildImage(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: SafePlayColors.neutral200,
            child: const Icon(Icons.broken_image, size: 48),
          );
        },
      ),
    );
  }

  Widget _buildAudioButton(BuildContext context, String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: widget.showFeedback ? null : () => _toggleAudio(url),
        icon: Icon(_isPlayingAudio ? Icons.pause : Icons.volume_up),
        label: Text(_isPlayingAudio ? 'Pause audio hint' : 'Play audio hint'),
      ),
    );
  }

  Widget _buildVideoButton(BuildContext context, String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Video hint'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video hints are not embedded in this build. '
                    'Use the link below to view the clip.',
                  ),
                  const SizedBox(height: 12),
                  SelectableText(url),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.play_circle_fill),
        label: const Text('View video hint'),
      ),
    );
  }

  Widget _buildAnswerOptions(BuildContext context, List<String> options) {
    switch (widget.question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return options.isEmpty
            ? const Text('Options not available for this question yet.')
            : Column(
                children: List.generate(options.length, (index) {
                  final option = options[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOptionButton(context, option, index),
                  );
                }),
              );
      case QuestionType.textInput:
        return _buildTextInput(context);
      case QuestionType.dragDrop:
      case QuestionType.sequencing:
        return _buildOrderingInteraction(context);
      case QuestionType.matching:
        return _buildMatchingInteraction(context, options);
    }
  }

  Widget _buildOptionButton(BuildContext context, String option, int index) {
    final isSelected = _isSelected(option);
    final isCorrectOption = _isCorrectOption(option);

    Color borderColor = SafePlayColors.neutral300;
    Color backgroundColor = Colors.white;

    if (widget.showFeedback) {
      if (isCorrectOption) {
        borderColor = SafePlayColors.success;
        backgroundColor = SafePlayColors.success.withValues(alpha: 0.12);
      } else if (isSelected) {
        borderColor = SafePlayColors.error;
        backgroundColor = SafePlayColors.error.withValues(alpha: 0.12);
      }
    } else if (isSelected) {
      borderColor = SafePlayColors.brandTeal500;
    }

    return InkWell(
      onTap: widget.showFeedback
          ? null
          : () => widget.onAnswerSelected?.call(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: borderColor == SafePlayColors.neutral300
                    ? SafePlayColors.neutral200
                    : borderColor.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: borderColor == SafePlayColors.neutral300
                        ? SafePlayColors.neutral700
                        : borderColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            if (widget.showFeedback && isCorrectOption)
              const Icon(
                Icons.check_circle,
                color: SafePlayColors.success,
                size: 28,
              )
            else if (widget.showFeedback && isSelected && !isCorrectOption)
              const Icon(
                Icons.cancel,
                color: SafePlayColors.error,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(BuildContext context) {
    final controller = TextEditingController(
      text: widget.selectedAnswer?.toString(),
    );
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      enabled: widget.onAnswerSelected != null && !widget.showFeedback,
      textInputAction: TextInputAction.done,
      onSubmitted: (value) {
        if (widget.onAnswerSelected != null && value.trim().isNotEmpty) {
          widget.onAnswerSelected!(value.trim());
        }
      },
    );
  }

  Widget _buildHintToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _hintVisible = !_hintVisible;
              });
            },
            icon: Icon(_hintVisible ? Icons.visibility_off : Icons.visibility),
            label: Text(_hintVisible ? 'Hide hint' : 'Show hint'),
          ),
          if (_hintVisible)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SafePlayColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SafePlayColors.info.withValues(alpha: 0.4)),
              ),
              child: Text(
                widget.question.hint ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: SafePlayColors.info),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExplanation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isCorrect
            ? SafePlayColors.success.withValues(alpha: 0.12)
            : SafePlayColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              widget.isCorrect ? SafePlayColors.success : SafePlayColors.error,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            widget.isCorrect ? Icons.check_circle : Icons.cancel,
            color: widget.isCorrect
                ? SafePlayColors.success
                : SafePlayColors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCorrect ? 'Correct answer' : 'Not quite',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isCorrect
                            ? SafePlayColors.success
                            : SafePlayColors.error,
                      ),
                ),
                const SizedBox(height: 4),
                Text(widget.question.explanation ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SafePlayColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafePlayColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.upcoming, color: SafePlayColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This interactive question type will be available in a future build.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderingInteraction(BuildContext context) {
    if (_ordering.isEmpty) {
      return const Text('This interactive question is awaiting content.');
    }

    final correctAnswer = widget.question.correctAnswer;
    final correctList = correctAnswer is List ? correctAnswer : null;
    final isFeedback = widget.showFeedback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.type == QuestionType.sequencing
              ? 'Drag the steps into the correct sequence using the arrows.'
              : 'Arrange the items into the best order.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ...List.generate(_ordering.length, (index) {
          final option = _ordering[index];
          final isCorrectPosition = isFeedback &&
              correctList != null &&
              index < correctList.length &&
              option.trim().toLowerCase() ==
                  correctList[index].toString().trim().toLowerCase();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isFeedback
                ? (isCorrectPosition
                    ? SafePlayColors.success.withValues(alpha: 0.12)
                    : SafePlayColors.error.withValues(alpha: 0.08))
                : Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: SafePlayColors.brandTeal50,
                child: Text(''),
              ),
              title: Text(option),
              trailing: isFeedback
                  ? Icon(
                      isCorrectPosition ? Icons.check_circle : Icons.error,
                      color: isCorrectPosition
                          ? SafePlayColors.success
                          : SafePlayColors.error,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          tooltip: 'Move up',
                          onPressed: index == 0
                              ? null
                              : () => _moveOption(index, index - 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          tooltip: 'Move down',
                          onPressed: index == _ordering.length - 1
                              ? null
                              : () => _moveOption(index, index + 1),
                        ),
                      ],
                    ),
            ),
          );
        }),
        if (!isFeedback) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: widget.onAnswerSelected == null
                  ? null
                  : () => widget.onAnswerSelected?.call(
                        List<String>.from(_ordering),
                      ),
              icon: const Icon(Icons.check),
              label: const Text('Submit order'),
            ),
          ),
        ],
      ],
    );
  }

  void _moveOption(int oldIndex, int newIndex) {
    if (widget.showFeedback) return;
    setState(() {
      final item = _ordering.removeAt(oldIndex);
      _ordering.insert(newIndex, item);
    });
  }

  Widget _buildMatchingInteraction(BuildContext context, List<String> options) {
    if (options.isEmpty) {
      return const Text('This matching question is awaiting options.');
    }

    final correctAnswer = widget.question.correctAnswer;
    final Set<String> correctValues = correctAnswer is List
        ? correctAnswer
            .map((value) => value.toString().trim().toLowerCase())
            .toSet()
        : <String>{};
    final isFeedback = widget.showFeedback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap each option to select the matches.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final normalized = option.trim().toLowerCase();
            final shouldBeSelected = correctValues.contains(normalized);
            final isChosen = _matchingSelections.contains(option);
            final showSelected =
                isFeedback ? (shouldBeSelected || isChosen) : isChosen;

            Color selectedColor;
            Color borderColor;
            Color textColor;

            if (!isFeedback) {
              selectedColor = SafePlayColors.brandTeal50;
              borderColor = isChosen
                  ? SafePlayColors.brandTeal500
                  : SafePlayColors.neutral300;
              textColor = isChosen
                  ? SafePlayColors.brandTeal600
                  : SafePlayColors.neutral700;
            } else if (shouldBeSelected) {
              selectedColor = SafePlayColors.success.withValues(alpha: 0.12);
              borderColor = SafePlayColors.success;
              textColor = SafePlayColors.success;
            } else if (isChosen) {
              selectedColor = SafePlayColors.error.withValues(alpha: 0.12);
              borderColor = SafePlayColors.error;
              textColor = SafePlayColors.error;
            } else {
              selectedColor = Colors.transparent;
              borderColor = SafePlayColors.neutral300;
              textColor = SafePlayColors.neutral700;
            }

            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  color: showSelected ? textColor : SafePlayColors.neutral700,
                ),
              ),
              selected: showSelected,
              onSelected: isFeedback
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected) {
                          if (!_matchingSelections.contains(option)) {
                            _matchingSelections.add(option);
                          }
                        } else {
                          _matchingSelections.remove(option);
                        }
                      });
                      widget.onAnswerSelected?.call(
                        List<String>.from(_matchingSelections),
                      );
                    },
              selectedColor: selectedColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: showSelected ? borderColor : SafePlayColors.neutral300,
              ),
              avatar: isFeedback && (shouldBeSelected || isChosen)
                  ? Icon(
                      shouldBeSelected
                          ? Icons.check_circle
                          : Icons.error_outline,
                      size: 18,
                      color: shouldBeSelected
                          ? SafePlayColors.success
                          : SafePlayColors.error,
                    )
                  : null,
            );
          }).toList(),
        ),
        if (!isFeedback)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _matchingSelections.isEmpty
                  ? 'Select every pair you believe is correct.'
                  : 'Selections recorded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SafePlayColors.neutral700,
                  ),
            ),
          ),
      ],
    );
  }

  List<String> _optionsForQuestion() {
    if (widget.question.options.isNotEmpty) {
      return widget.question.options;
    }
    if (widget.question.type == QuestionType.trueFalse) {
      return const ['True', 'False'];
    }
    return const [];
  }

  bool _isSelected(String option) {
    final answer = widget.selectedAnswer;
    if (answer is List) {
      return answer.contains(option);
    }
    return answer != null &&
        answer.toString().trim().toLowerCase() == option.trim().toLowerCase();
  }

  bool _isCorrectOption(String option) {
    final correct = widget.question.correctAnswer;
    if (correct is List) {
      return correct
          .map((e) => e.toString().trim().toLowerCase())
          .contains(option.trim().toLowerCase());
    }
    if (correct is bool) {
      final normalized = option.trim().toLowerCase();
      return (correct && normalized == 'true') ||
          (!correct && normalized == 'false');
    }
    return correct != null &&
        correct.toString().trim().toLowerCase() == option.trim().toLowerCase();
  }

  Future<void> _toggleAudio(String url) async {
    if (_isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() {
        _isPlayingAudio = false;
      });
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _isPlayingAudio = true;
      });
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
      });
    } catch (error) {
      debugPrint('Error playing audio hint: $error');
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }
}
