import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';
import '../../models/lesson.dart';
import '../../models/game_activity.dart';

/// Junior task card component with tile-style design
/// Matches the soft pastel tile aesthetic with rounded corners and subtle shadows
class JuniorTaskCard extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onPlay;
  final bool isCompleted;
  final bool isLocked;
  final double? progress; // 0.0 to 1.0

  const JuniorTaskCard({
    super.key,
    required this.lesson,
    this.onPlay,
    this.isCompleted = false,
    this.isLocked = false,
    this.progress,
  });

  @override
  State<JuniorTaskCard> createState() => _JuniorTaskCardState();
}

class _JuniorTaskCardState extends State<JuniorTaskCard>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLocked ? null : _handleTap,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isLocked ? 1.0 : _bounceAnimation.value,
            child: Container(
              width: double.infinity,
              height: 160.0, // Fixed height for consistent tiles
              margin: const EdgeInsets.only(bottom: JuniorTheme.spacingMedium),
              decoration: BoxDecoration(
                color: _getTileBackgroundColor(),
                borderRadius:
                    BorderRadius.circular(24.0), // Significant border-radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), // Subtle shadow
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Content: Title and description in top-left
                  Positioned(
                    left: 20.0,
                    top: 20.0,
                    right: 120.0, // Leave space for icon
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (large, bold, dark text)
                        Text(
                          widget.lesson.title,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: JuniorTheme.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8.0),
                        // Description/Game count (smaller, muted text)
                        Row(
                          children: [
                            if (widget.lesson.content['templateCount'] != null)
                              Text(
                                '${widget.lesson.content['templateCount']} Games',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: _getTileTextColor().withOpacity(0.7),
                                  height: 1.3,
                                ),
                              )
                            else
                              Text(
                                widget.lesson.description ??
                                    'Fun learning games',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  color: _getTileTextColor().withOpacity(0.7),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        if (widget.lesson.rewardPoints > 0) ...[
                          const SizedBox(height: 8.0),
                          // Reward points indicator
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                size: 16.0,
                                color: _getTileTextColor().withOpacity(0.6),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                '${widget.lesson.rewardPoints} points',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  color: _getTileTextColor().withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Icon/Illustration in bottom-right (possibly overlapping)
                  Positioned(
                    right: -10.0, // Slightly overlapping for playful effect
                    bottom: -10.0,
                    child: _buildTileIcon(),
                  ),
                  // Status indicator (top-right corner)
                  if (widget.isCompleted || widget.isLocked)
                    Positioned(
                      top: 12.0,
                      right: 12.0,
                      child: _buildStatusIndicator(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get pastel background color based on game type or exercise type
  Color _getTileBackgroundColor() {
    if (widget.isLocked) {
      return JuniorTheme.textLight.withOpacity(0.2);
    }

    if (widget.isCompleted) {
      return JuniorTheme.success.withOpacity(0.6);
    }

    // Try to get game type from lesson
    final gameTypeName = widget.lesson.content['gameType'] as String? ??
        widget.lesson.metadata['gameType'] as String?;

    if (gameTypeName != null) {
      try {
        final gameType = GameType.values.firstWhere(
          (e) => e.name == gameTypeName,
        );
        return _getColorForGameType(gameType);
      } catch (e) {
        // Fall back to exercise type
      }
    }

    // Fall back to exercise type
    return _getColorForExerciseType(widget.lesson.exerciseType);
  }

  /// Get color for specific game type
  Color _getColorForGameType(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
      case GameType.koalaCounterAdventure:
        return const Color(0xFFFFF8DC); // Soft pastel yellow
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
        return const Color(0xFFFFE4E1); // Light pink/orange
      case GameType.bubblePopGrammar:
        return const Color(0xFFB3E5FC); // Underwater blue
      case GameType.seashellQuiz:
        return const Color(0xFFFFF3E0); // Sandy shell tone
      case GameType.fishTankQuiz:
        return const Color(0xFFE1F5FE); // Ocean teal
      case GameType.memoryMatch:
      case GameType.wordBuilder:
      case GameType.storySequencer:
        return const Color(0xFFE0F2F1); // Light green/teal
      default:
        return const Color(0xFFF0F8FF); // Light blue
    }
  }

  /// Get color for exercise type
  Color _getColorForExerciseType(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.multipleChoice:
        return const Color(0xFFFFF8DC); // Soft pastel yellow
      case ExerciseType.flashcard:
        return const Color(0xFFFFE4E1); // Light pink/orange
      case ExerciseType.puzzle:
        return const Color(0xFFE0F2F1); // Light green/teal
    }
  }

  /// Get text color that contrasts with background
  Color _getTileTextColor() {
    if (widget.isLocked) {
      return JuniorTheme.textLight;
    }
    return JuniorTheme.textPrimary;
  }

  /// Build icon/illustration for the tile
  Widget _buildTileIcon() {
    // Get game type for specific icon
    final gameTypeName = widget.lesson.content['gameType'] as String? ??
        widget.lesson.metadata['gameType'] as String?;

    if (gameTypeName != null) {
      try {
        final gameType = GameType.values.firstWhere(
          (e) => e.name == gameTypeName,
        );
        return _getIconForGameType(gameType);
      } catch (e) {
        // Fall back to exercise type icon
      }
    }

    // Fall back to exercise type icon
    return _getIconForExerciseType(widget.lesson.exerciseType);
  }

  /// Get icon for specific game type
  Widget _getIconForGameType(GameType gameType) {
    final iconColor = _getTileTextColor().withOpacity(0.4);

    switch (gameType) {
      case GameType.numberGridRace:
        // Magnifying glass with numbers icon
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.search, size: 60.0, color: iconColor),
            Positioned(
              top: 8,
              child: Text(
                '123',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
          ],
        );
      case GameType.koalaCounterAdventure:
        // Koala character
        return Icon(Icons.pets, size: 64.0, color: iconColor);
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
        // Geometric shapes
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.circle, size: 40.0, color: iconColor),
            Positioned(
              right: 20,
              child: Icon(Icons.square, size: 30.0, color: iconColor),
            ),
            Positioned(
              left: 20,
              top: 10,
              child: Icon(Icons.change_history,
                  size: 25.0, color: iconColor), // Triangle icon
            ),
          ],
        );
      case GameType.bubblePopGrammar:
        return Icon(Icons.bubble_chart, size: 64.0, color: iconColor);
      case GameType.seashellQuiz:
        return Icon(Icons.water_damage, size: 64.0, color: iconColor);
      case GameType.fishTankQuiz:
        return Icon(Icons.set_meal, size: 64.0, color: iconColor);
      case GameType.memoryMatch:
        // Cards/memory icon
        return Icon(Icons.style, size: 64.0, color: iconColor);
      case GameType.wordBuilder:
        // Letters/word icon
        return Icon(Icons.text_fields, size: 64.0, color: iconColor);
      case GameType.storySequencer:
        // Book/story icon
        return Icon(Icons.menu_book, size: 64.0, color: iconColor);
      default:
        return Icon(Icons.games, size: 64.0, color: iconColor);
    }
  }

  /// Get icon for exercise type
  Widget _getIconForExerciseType(ExerciseType exerciseType) {
    final iconColor = _getTileTextColor().withOpacity(0.4);

    switch (exerciseType) {
      case ExerciseType.multipleChoice:
        return Icon(Icons.quiz, size: 64.0, color: iconColor);
      case ExerciseType.flashcard:
        return Icon(Icons.style, size: 64.0, color: iconColor);
      case ExerciseType.puzzle:
        return Icon(Icons.extension, size: 64.0, color: iconColor);
    }
  }

  /// Build status indicator (completed or locked)
  Widget _buildStatusIndicator() {
    if (widget.isLocked) {
      return Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock,
          size: 18.0,
          color: JuniorTheme.textLight,
        ),
      );
    }

    if (widget.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(6.0),
        decoration: const BoxDecoration(
          color: JuniorTheme.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 18.0,
          color: Colors.white,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _handleTap() {
    if (widget.isLocked) return;

    // Bounce animation on tap
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Call onPlay callback after short delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (widget.onPlay != null) {
        widget.onPlay!();
      }
    });
  }
}

/// Junior task card with progress indicator
class JuniorTaskCardWithProgress extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onPlay;
  final bool isCompleted;
  final bool isLocked;
  final double progress; // 0.0 to 1.0

  const JuniorTaskCardWithProgress({
    super.key,
    required this.lesson,
    this.onPlay,
    this.isCompleted = false,
    this.isLocked = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        JuniorTaskCard(
          lesson: lesson,
          onPlay: onPlay,
          isCompleted: isCompleted,
          isLocked: isLocked,
          progress: progress,
        ),
        // Progress bar
        if (!isCompleted && !isLocked && progress > 0)
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 8.0,
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                JuniorTheme.primaryGreen,
              ),
              minHeight: 4.0,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
      ],
    );
  }
}
