import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../design_system/junior_theme.dart';

/// Animated coin widget that floats up when coins are earned
class JuniorCoinAnimation extends StatefulWidget {
  final int coins;
  final Duration duration;
  final VoidCallback? onComplete;

  const JuniorCoinAnimation({
    super.key,
    required this.coins,
    this.duration = const Duration(milliseconds: 2000),
    this.onComplete,
  });

  @override
  State<JuniorCoinAnimation> createState() => _JuniorCoinAnimationState();
}

class _JuniorCoinAnimationState extends State<JuniorCoinAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  final List<CoinParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 0.6,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Create coin particles for visual effect
    _createParticles();

    // Start animation
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  void _createParticles() {
    final random = math.Random();
    for (int i = 0; i < 5; i++) {
      _particles.add(CoinParticle(
        offset: Offset(
          (random.nextDouble() - 0.5) * 0.3,
          (random.nextDouble() - 0.5) * 0.3,
        ),
        delay: random.nextDouble() * 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main coin
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            JuniorTheme.accentGold,
                            JuniorTheme.accentGold.withOpacity(0.8),
                            JuniorTheme.accentGold,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: JuniorTheme.accentGold.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    // Coin particles
                    ..._particles.map((particle) {
                      final progress = math.max(
                          0.0,
                          (_controller.value - particle.delay) /
                              (1.0 - particle.delay));
                      return Transform.translate(
                        offset: Offset(
                          particle.offset.dx * progress * 100,
                          particle.offset.dy * progress * 100,
                        ),
                        child: Opacity(
                          opacity: 1.0 - progress,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: JuniorTheme.accentGold.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Coin particle for visual effects
class CoinParticle {
  final Offset offset;
  final double delay;

  CoinParticle({
    required this.offset,
    required this.delay,
  });
}

/// Animated coin counter widget for displaying earned coins
class AnimatedCoinCounter extends StatefulWidget {
  final int coins;
  final Duration animationDuration;
  final TextStyle? textStyle;
  final Color? coinColor;

  const AnimatedCoinCounter({
    super.key,
    required this.coins,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.textStyle,
    this.coinColor,
  });

  @override
  State<AnimatedCoinCounter> createState() => _AnimatedCoinCounterState();
}

class _AnimatedCoinCounterState extends State<AnimatedCoinCounter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _countAnimation = IntTween(
      begin: 0,
      end: widget.coins,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 0.7,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins) {
      _controller.reset();
      _countAnimation = IntTween(
        begin: oldWidget.coins,
        end: widget.coins,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on,
                color: widget.coinColor ?? JuniorTheme.accentGold,
                size: (widget.textStyle?.fontSize ?? 24) + 4,
              ),
              const SizedBox(width: 8),
              Text(
                '${_countAnimation.value}',
                style: widget.textStyle ??
                    JuniorTheme.headingMedium.copyWith(
                      color: JuniorTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Floating coins effect - multiple coins floating up
class FloatingCoinsAnimation extends StatefulWidget {
  final int coinCount;
  final Duration duration;
  final VoidCallback? onComplete;

  const FloatingCoinsAnimation({
    super.key,
    required this.coinCount,
    this.duration = const Duration(milliseconds: 2500),
    this.onComplete,
  });

  @override
  State<FloatingCoinsAnimation> createState() => _FloatingCoinsAnimationState();
}

class _FloatingCoinsAnimationState extends State<FloatingCoinsAnimation>
    with TickerProviderStateMixin {
  final List<FloatingCoin> _coins = [];
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    for (int i = 0; i < math.min(widget.coinCount, 10); i++) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(controller);

      _coins.add(FloatingCoin(
        delay: random.nextDouble() * 0.3,
        horizontalOffset: (random.nextDouble() - 0.5) * 200,
        rotationSpeed: (random.nextDouble() - 0.5) * 2,
      ));
    }

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: (_coins[i].delay * 1000).round()),
        () {
          if (mounted) {
            _controllers[i].forward().then((_) {
              if (i == _controllers.length - 1 && widget.onComplete != null) {
                widget.onComplete!();
              }
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_coins.length, (index) {
        final coin = _coins[index];
        final controller = _controllers[index];
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final progress = controller.value;
            final verticalOffset = -progress * 300;
            final opacity = 1.0 - progress * 0.8;
            final scale = 1.0 - progress * 0.3;
            final rotation = progress * coin.rotationSpeed * 2 * math.pi;

            return Positioned(
              left: MediaQuery.of(context).size.width / 2 +
                  coin.horizontalOffset * progress,
              top: MediaQuery.of(context).size.height / 2 + verticalOffset,
              child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            JuniorTheme.accentGold,
                            JuniorTheme.accentGold.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: JuniorTheme.accentGold.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class FloatingCoin {
  final double delay;
  final double horizontalOffset;
  final double rotationSpeed;

  FloatingCoin({
    required this.delay,
    required this.horizontalOffset,
    required this.rotationSpeed,
  });
}
