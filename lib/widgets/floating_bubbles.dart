import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingBubbles extends StatefulWidget {
  final int bubbleCount;
  final double minSize;
  final double maxSize;
  final Color bubbleColor;
  final double opacity;

  const FloatingBubbles({
    super.key,
    this.bubbleCount = 15,
    this.minSize = 8.0,
    this.maxSize = 20.0,
    this.bubbleColor = Colors.white,
    this.opacity = 0.3,
  });

  @override
  State<FloatingBubbles> createState() => _FloatingBubblesState();
}

class _FloatingBubblesState extends State<FloatingBubbles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _xAnimations;
  late List<Animation<double>> _yAnimations;
  late List<Animation<double>> _opacityAnimations;
  late List<double> _bubbleSizes;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Generate random sizes for each bubble
    _bubbleSizes = List.generate(
      widget.bubbleCount,
      (index) =>
          widget.minSize +
          _random.nextDouble() * (widget.maxSize - widget.minSize),
    );

    _controllers = List.generate(
      widget.bubbleCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 3000 + _random.nextInt(4000), // 3-7 seconds
        ),
      ),
    );

    _xAnimations = _controllers.map((controller) {
      // Random starting X position
      final startX = _random.nextDouble();
      // Random ending X position (can drift left or right)
      final endX =
          (startX + (_random.nextDouble() - 0.5) * 0.3).clamp(0.0, 1.0);

      return Tween<double>(
        begin: startX,
        end: endX,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.linear,
        ),
      );
    }).toList();

    _yAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0, // Start from bottom
        end: -0.2, // Move to top (slightly above screen)
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.linear,
        ),
      );
    }).toList();

    _opacityAnimations = _controllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: widget.opacity)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 0.2,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: widget.opacity, end: widget.opacity),
          weight: 0.6,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: widget.opacity, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 0.2,
        ),
      ]).animate(controller);
    }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      // Stagger the start times
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: List.generate(widget.bubbleCount, (index) {
          final size = _bubbleSizes[index];

          return AnimatedBuilder(
            animation: Listenable.merge([
              _xAnimations[index],
              _yAnimations[index],
              _opacityAnimations[index],
            ]),
            builder: (context, child) {
              return Positioned(
                left: _xAnimations[index].value * screenSize.width,
                top: _yAnimations[index].value * screenSize.height,
                child: Opacity(
                  opacity: _opacityAnimations[index].value,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.bubbleColor.withValues(
                        alpha: _opacityAnimations[index].value,
                      ),
                      border: Border.all(
                        color: widget.bubbleColor.withValues(
                          alpha: _opacityAnimations[index].value * 0.5,
                        ),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.bubbleColor.withValues(
                            alpha: _opacityAnimations[index].value * 0.3,
                          ),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
