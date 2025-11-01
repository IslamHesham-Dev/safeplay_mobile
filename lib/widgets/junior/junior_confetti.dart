import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../design_system/junior_theme.dart';

/// Junior confetti animation component for celebrations
class JuniorConfetti extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final Color? color;
  final int particleCount;
  final VoidCallback? onComplete;

  const JuniorConfetti({
    super.key,
    required this.isActive,
    this.duration = const Duration(seconds: 3),
    this.color,
    this.particleCount = 50,
    this.onComplete,
  });

  @override
  State<JuniorConfetti> createState() => _JuniorConfettiState();
}

class _JuniorConfettiState extends State<JuniorConfetti>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _particles = _generateParticles();
  }

  @override
  void didUpdateWidget(JuniorConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ConfettiParticle> _generateParticles() {
    final particles = <ConfettiParticle>[];
    final colors = [
      JuniorTheme.primaryGreen,
      JuniorTheme.primaryYellow,
      JuniorTheme.primaryOrange,
      JuniorTheme.primaryPink,
      JuniorTheme.primaryBlue,
      JuniorTheme.primaryPurple,
      JuniorTheme.accentGold,
    ];

    for (int i = 0; i < widget.particleCount; i++) {
      particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.2,
        size: 4.0 + _random.nextDouble() * 8.0,
        color: widget.color ?? colors[_random.nextInt(colors.length)],
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        fallSpeed: 0.5 + _random.nextDouble() * 1.0,
        driftSpeed: (_random.nextDouble() - 0.5) * 0.1,
        shape:
            ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)],
      ));
    }

    return particles;
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Confetti particle model
class ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double fallSpeed;
  final double driftSpeed;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.fallSpeed,
    required this.driftSpeed,
    required this.shape,
  });
}

/// Confetti shape enum
enum ConfettiShape {
  circle,
  square,
  triangle,
  star,
  heart,
}

/// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = particle.y + (particle.fallSpeed * progress);
      final currentX = particle.x + (particle.driftSpeed * progress);
      final currentRotation =
          particle.rotation + (particle.rotationSpeed * progress * 100);

      if (currentY > 1.2) continue; // Particle is off screen

      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - (progress * 0.8))
        ..style = PaintingStyle.fill;

      final center = Offset(
        currentX * size.width,
        currentY * size.height,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(currentRotation);

      _drawShape(canvas, paint, particle.shape, particle.size);

      canvas.restore();
    }
  }

  void _drawShape(
      Canvas canvas, Paint paint, ConfettiShape shape, double size) {
    switch (shape) {
      case ConfettiShape.circle:
        canvas.drawCircle(Offset.zero, size / 2, paint);
        break;
      case ConfettiShape.square:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: size, height: size),
          paint,
        );
        break;
      case ConfettiShape.triangle:
        final path = Path();
        path.moveTo(0, -size / 2);
        path.lineTo(-size / 2, size / 2);
        path.lineTo(size / 2, size / 2);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ConfettiShape.star:
        _drawStar(canvas, paint, size);
        break;
      case ConfettiShape.heart:
        _drawHeart(canvas, paint, size);
        break;
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;
    final angle = math.pi / 5;

    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = radius * math.cos(i * angle - math.pi / 2);
      final y = radius * math.sin(i * angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final scale = size / 20;

    path.moveTo(0, 5 * scale);
    path.cubicTo(-5 * scale, 0, -10 * scale, 0, -10 * scale, 5 * scale);
    path.cubicTo(-10 * scale, 10 * scale, 0, 15 * scale, 0, 20 * scale);
    path.cubicTo(0, 15 * scale, 10 * scale, 10 * scale, 10 * scale, 5 * scale);
    path.cubicTo(10 * scale, 0, 5 * scale, 0, 0, 5 * scale);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Junior celebration overlay with confetti and message
class JuniorCelebrationOverlay extends StatefulWidget {
  final bool isVisible;
  final String message;
  final String? subMessage;
  final VoidCallback? onDismiss;
  final Duration duration;
  final int? points;

  const JuniorCelebrationOverlay({
    super.key,
    required this.isVisible,
    required this.message,
    this.subMessage,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
    this.points,
  });

  @override
  State<JuniorCelebrationOverlay> createState() =>
      _JuniorCelebrationOverlayState();
}

class _JuniorCelebrationOverlayState extends State<JuniorCelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: JuniorTheme.bounceCurve,
    ));
  }

  @override
  void didUpdateWidget(JuniorCelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _showCelebration();
    }
  }

  void _showCelebration() {
    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _hideCelebration();
      }
    });
  }

  void _hideCelebration() {
    _fadeController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
    _scaleController.reverse();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            children: [
              // Confetti background
              JuniorConfetti(
                isActive: widget.isVisible,
                duration: widget.duration,
                particleCount: 100,
              ),

              // Celebration content
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(JuniorTheme.spacingLarge),
                    padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: JuniorTheme.backgroundCard,
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusLarge),
                      boxShadow: JuniorTheme.shadowHeavy,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Celebration icon
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            gradient: JuniorTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                                JuniorTheme.radiusCircular),
                            boxShadow: JuniorTheme.shadowMedium,
                          ),
                          child: const Icon(
                            Icons.celebration,
                            color: Colors.white,
                            size: 40.0,
                          ),
                        ),

                        const SizedBox(height: JuniorTheme.spacingMedium),

                        // Main message
                        Text(
                          widget.message,
                          style: JuniorTheme.headingMedium,
                          textAlign: TextAlign.center,
                        ),

                        // Sub message
                        if (widget.subMessage != null) ...[
                          const SizedBox(height: JuniorTheme.spacingSmall),
                          Text(
                            widget.subMessage!,
                            style: JuniorTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: JuniorTheme.spacingMedium),

                        // Dismiss button
                        GestureDetector(
                          onTap: _hideCelebration,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: JuniorTheme.spacingMedium,
                              vertical: JuniorTheme.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: JuniorTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(
                                  JuniorTheme.radiusMedium),
                              boxShadow: JuniorTheme.shadowLight,
                            ),
                            child: const Text(
                              'Awesome!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Random number generator
class Random {
  final math.Random _random = math.Random();

  double nextDouble() => _random.nextDouble();
  int nextInt(int max) => _random.nextInt(max);
}
