import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

/// Junior progress bar component for daily tasks
class JuniorProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;

  const JuniorProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.backgroundColor,
    this.progressColor,
    this.height = JuniorTheme.progressBarHeight,
    this.showPercentage = true,
    this.animated = true,
    this.animationDuration = JuniorTheme.animationMedium,
  });

  @override
  State<JuniorProgressBar> createState() => _JuniorProgressBarState();
}

class _JuniorProgressBarState extends State<JuniorProgressBar>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final Animation<double> _progressAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: JuniorTheme.smoothCurve,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated) {
      _progressController.forward();
    }

    // Start pulse animation if progress is complete
    if (widget.progress >= 1.0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(JuniorProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: JuniorTheme.smoothCurve,
      ));

      if (widget.animated) {
        _progressController.forward(from: 0.0);
      }

      // Update pulse animation based on completion
      if (widget.progress >= 1.0) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _buildLabel(),
        if (widget.label != null)
          const SizedBox(height: JuniorTheme.spacingXSmall),
        _buildProgressBar(),
        if (widget.showPercentage) _buildPercentage(),
      ],
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.label!,
      style: JuniorTheme.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.progress >= 1.0 ? _pulseAnimation.value : 1.0,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? JuniorTheme.backgroundLight,
              borderRadius:
                  BorderRadius.circular(JuniorTheme.progressBarRadius),
              boxShadow: JuniorTheme.shadowLight,
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(JuniorTheme.progressBarRadius),
              child: Stack(
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    height: widget.height,
                    color:
                        widget.backgroundColor ?? JuniorTheme.backgroundLight,
                  ),

                  // Progress fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.animated
                        ? _progressAnimation.value
                        : widget.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: widget.progressColor != null
                              ? [
                                  widget.progressColor!,
                                  widget.progressColor!.withOpacity(0.8)
                                ]
                              : [
                                  JuniorTheme.primaryGreen,
                                  JuniorTheme.primaryYellow
                                ],
                        ),
                        borderRadius: BorderRadius.circular(
                            JuniorTheme.progressBarRadius),
                      ),
                    ),
                  ),

                  // Shine effect for completed progress
                  if (widget.progress >= 1.0) _buildShineEffect(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShineEffect() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: [
                0.0,
                _pulseController.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPercentage() {
    return Padding(
      padding: const EdgeInsets.only(top: JuniorTheme.spacingXSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Progress',
            style: JuniorTheme.bodySmall,
          ),
          Text(
            '${(widget.progress * 100).toInt()}%',
            style: JuniorTheme.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.progress >= 1.0
                  ? JuniorTheme.primaryGreen
                  : JuniorTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Junior daily tasks progress bar with specific styling
class JuniorDailyTasksProgressBar extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final String? label;
  final bool showStatusMessages;

  const JuniorDailyTasksProgressBar({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    this.label,
    this.showStatusMessages = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        gradient: JuniorTheme.cardGradient,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: Column(
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: JuniorTheme.spacingSmall),
              Expanded(
                child: Text(
                  label ?? 'Daily Tasks',
                  style: JuniorTheme.headingSmall,
                ),
              ),
              // Completion indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuniorTheme.spacingSmall,
                  vertical: JuniorTheme.spacingXSmall,
                ),
                decoration: BoxDecoration(
                  color: progress >= 1.0
                      ? JuniorTheme.success
                      : JuniorTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                ),
                child: Text(
                  '$completedTasks/$totalTasks',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: JuniorTheme.spacingMedium),

          // Progress bar
          JuniorProgressBar(
            progress: progress,
            height: 20.0,
            showPercentage: false,
            animated: true,
          ),

          if (showStatusMessages) ...[
            // Motivational message
            if (progress >= 1.0) ...[
              const SizedBox(height: JuniorTheme.spacingSmall),
              _buildCompletionMessage(),
            ] else if (progress > 0) ...[
              const SizedBox(height: JuniorTheme.spacingSmall),
              _buildProgressMessage(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
      decoration: BoxDecoration(
        color: JuniorTheme.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            color: JuniorTheme.primaryGreen,
            size: 20.0,
          ),
          const SizedBox(width: JuniorTheme.spacingXSmall),
          Text(
            'Great job! All tasks completed! 🎉',
            style: JuniorTheme.bodyMedium.copyWith(
              color: JuniorTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMessage() {
    final remaining = totalTasks - completedTasks;
    return Text(
      remaining == 1
          ? 'Just 1 more task to go!'
          : '$remaining more tasks to complete!',
      style: JuniorTheme.bodySmall.copyWith(
        color: JuniorTheme.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Junior XP/Coins progress bar
class JuniorXPProgressBar extends StatelessWidget {
  final int currentXP;
  final int maxXP;
  final String? label;

  const JuniorXPProgressBar({
    super.key,
    required this.currentXP,
    required this.maxXP,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxXP > 0 ? currentXP / maxXP : 0.0;

    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [JuniorTheme.accentGold, JuniorTheme.accentSilver],
        ),
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: Column(
        children: [
          // Header with XP icon and current amount
          Row(
            children: [
              const Icon(
                Icons.stars,
                color: Colors.white,
                size: 28.0,
              ),
              const SizedBox(width: JuniorTheme.spacingSmall),
              Expanded(
                child: Text(
                  label ?? 'XP Progress',
                  style: JuniorTheme.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$currentXP XP',
                style: JuniorTheme.coinText.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: JuniorTheme.spacingMedium),

          // Progress bar
          JuniorProgressBar(
            progress: progress,
            height: 16.0,
            backgroundColor: Colors.white.withOpacity(0.3),
            progressColor: Colors.white,
            showPercentage: false,
            animated: true,
          ),

          // Level indicator
          const SizedBox(height: JuniorTheme.spacingSmall),
          Text(
            'Level ${(currentXP / 100).floor() + 1}',
            style: JuniorTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


