import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';
import '../../models/lesson.dart';

/// Junior task card component with illustrations and simple text
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
  late final AnimationController _pulseController;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: JuniorTheme.animationMedium,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: JuniorTheme.bounceCurve,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation for incomplete tasks
    if (!widget.isCompleted && !widget.isLocked) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLocked ? null : _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isLocked
                ? 1.0
                : _bounceAnimation.value * _pulseAnimation.value,
            child: Container(
              width: JuniorTheme.cardWidth,
              height: JuniorTheme.cardMinHeight,
              margin: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingSmall,
                vertical: JuniorTheme.spacingXSmall,
              ),
              decoration: _getCardDecoration(),
              child: _buildCardContent(),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _getCardDecoration() {
    if (widget.isLocked) {
      return BoxDecoration(
        color: JuniorTheme.textLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowLight,
        border: Border.all(
          color: JuniorTheme.textLight,
          width: 2.0,
        ),
      );
    }

    if (widget.isCompleted) {
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [JuniorTheme.success, JuniorTheme.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowMedium,
      );
    }

    return JuniorTheme.getCardDecoration();
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: Illustration and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIllustration(),
              _buildStatusIndicator(),
            ],
          ),

          // Middle row: Task title (max 3-4 words)
          _buildTaskTitle(),

          // Bottom row: Reward coins and play button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRewardCoins(),
              _buildPlayButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: _getIllustrationBackgroundColor(),
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: _getIllustrationIcon(),
    );
  }

  Color _getIllustrationBackgroundColor() {
    if (widget.isLocked) return JuniorTheme.textLight;
    if (widget.isCompleted) return Colors.white;

    switch (widget.lesson.exerciseType) {
      case ExerciseType.multipleChoice:
        return JuniorTheme.primaryBlue;
      case ExerciseType.flashcard:
        return JuniorTheme.primaryYellow;
      case ExerciseType.puzzle:
        return JuniorTheme.primaryPurple;
    }
  }

  Widget _getIllustrationIcon() {
    if (widget.isLocked) {
      return const Icon(
        Icons.lock,
        color: Colors.white,
        size: 24.0,
      );
    }

    if (widget.isCompleted) {
      return const Icon(
        Icons.check_circle,
        color: JuniorTheme.primaryGreen,
        size: 32.0,
      );
    }

    switch (widget.lesson.exerciseType) {
      case ExerciseType.multipleChoice:
        return const Icon(
          Icons.quiz,
          color: Colors.white,
          size: 28.0,
        );
      case ExerciseType.flashcard:
        return const Icon(
          Icons.style,
          color: Colors.white,
          size: 28.0,
        );
      case ExerciseType.puzzle:
        return const Icon(
          Icons.extension,
          color: Colors.white,
          size: 28.0,
        );
    }
  }

  Widget _buildStatusIndicator() {
    if (widget.isLocked) {
      return const Icon(
        Icons.lock_outline,
        color: JuniorTheme.textLight,
        size: 20.0,
      );
    }

    if (widget.isCompleted) {
      return const Icon(
        Icons.star,
        color: JuniorTheme.accentGold,
        size: 24.0,
      );
    }

    if (widget.progress != null && widget.progress! > 0) {
      return Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          color: JuniorTheme.primaryOrange,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
        ),
        child: Center(
          child: Text(
            '${(widget.progress! * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTaskTitle() {
    // Limit title to 3-4 words for Junior users
    final words = widget.lesson.title.split(' ');
    final shortTitle = words.length > 4
        ? '${words.take(4).join(' ')}...'
        : widget.lesson.title;

    return Text(
      shortTitle,
      style: JuniorTheme.taskTitle.copyWith(
        color:
            widget.isLocked ? JuniorTheme.textLight : JuniorTheme.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRewardCoins() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.monetization_on,
          color: JuniorTheme.accentGold,
          size: 20.0,
        ),
        const SizedBox(width: 4.0),
        Text(
          '${widget.lesson.rewardPoints}',
          style: JuniorTheme.coinText.copyWith(
            fontSize: 18.0,
            color: widget.isLocked
                ? JuniorTheme.textLight
                : JuniorTheme.accentGold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    if (widget.isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingSmall,
          vertical: JuniorTheme.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: JuniorTheme.textLight,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        ),
        child: const Text(
          'Locked',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (widget.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingSmall,
          vertical: JuniorTheme.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: JuniorTheme.primaryGreen,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.replay,
              color: Colors.white,
              size: 16.0,
            ),
            SizedBox(width: 4.0),
            Text(
              'Replay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onPlay,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuniorTheme.spacingMedium,
          vertical: JuniorTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          gradient: JuniorTheme.primaryGradient,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
          boxShadow: JuniorTheme.shadowLight,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 20.0,
            ),
            SizedBox(width: 4.0),
            Text(
              'Play',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap() {
    if (widget.isLocked) return;

    // Trigger bounce animation
    _bounceController.forward().then((_) {
      _bounceController.reset();
    });

    // Call onPlay callback
    if (widget.onPlay != null) {
      widget.onPlay!();
    }
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
          Container(
            width: JuniorTheme.cardWidth,
            margin: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingSmall),
            child: Column(
              children: [
                const SizedBox(height: JuniorTheme.spacingXSmall),
                _buildProgressBar(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: JuniorTheme.progressBarHeight,
      decoration: JuniorTheme.getProgressBarDecoration(),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: JuniorTheme.getProgressFillDecoration(),
        ),
      ),
    );
  }
}


