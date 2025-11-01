import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

/// Junior character avatar widget with fixed boy/girl images
class JuniorAvatarWidget extends StatefulWidget {
  final String childId;
  final double size;
  final VoidCallback? onTap;
  final bool isInteractive;
  final String? gender; // 'male' or 'female'

  const JuniorAvatarWidget({
    super.key,
    required this.childId,
    this.size = JuniorTheme.avatarSizeLarge,
    this.onTap,
    this.isInteractive = true,
    this.gender,
  });

  @override
  State<JuniorAvatarWidget> createState() => _JuniorAvatarWidgetState();
}

class _JuniorAvatarWidgetState extends State<JuniorAvatarWidget>
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
      duration: const Duration(milliseconds: 1000),
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
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger bounce animation when widget is built
    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCustomAvatar();
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundLight,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: JuniorTheme.primaryGreen,
          strokeWidth: 3.0,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return GestureDetector(
      onTap: widget.isInteractive ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: JuniorTheme.primaryGradient,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
                boxShadow: JuniorTheme.shadowHeavy,
              ),
              child: const Icon(
                Icons.person,
                size: 64.0,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomAvatar() {
    return GestureDetector(
      onTap: widget.isInteractive ? _handleTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value * _pulseAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: _buildAvatarImage(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartoonBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              JuniorTheme.primaryBlue,
              JuniorTheme.primaryGreen,
            ],
          ),
        ),
        child: CustomPaint(
          painter: CartoonBackgroundPainter(),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    return Center(
      child: Container(
        width: widget.size * 0.8,
        height: widget.size * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
          boxShadow: JuniorTheme.shadowLight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
          child: _buildFixedAvatar(),
        ),
      ),
    );
  }

  Widget _buildFixedAvatar() {
    // Use fixed boy/girl images based on gender
    final imagePath = _getGenderImagePath();
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackAvatar();
      },
    );
  }

  String _getGenderImagePath() {
    // Use the gender passed to the widget, or default to female
    return widget.gender == 'male'
        ? 'assets/images/avatars/boy_img.png'
        : 'assets/images/avatars/girl_img.png';
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
      ),
      child: Center(
        child: Text(
          widget.gender == 'male' ? '👦' : '👧',
          style: TextStyle(fontSize: widget.size * 0.4),
        ),
      ),
    );
  }

  Widget _buildCustomizationButton() {
    return Positioned(
      top: 8.0,
      right: 8.0,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: JuniorTheme.primaryOrange,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
          boxShadow: JuniorTheme.shadowLight,
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
    );
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
}

/// Custom painter for cartoon background elements
class CartoonBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = JuniorTheme.primaryYellow.withOpacity(0.3);

    // Draw simple cloud shapes
    _drawCloud(canvas, paint, Offset(size.width * 0.2, size.height * 0.1),
        size.width * 0.15);
    _drawCloud(canvas, paint, Offset(size.width * 0.7, size.height * 0.15),
        size.width * 0.12);

    // Draw simple star shapes
    _drawStar(canvas, paint, Offset(size.width * 0.1, size.height * 0.3),
        size.width * 0.08);
    _drawStar(canvas, paint, Offset(size.width * 0.85, size.height * 0.25),
        size.width * 0.06);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.addOval(
        Rect.fromCenter(center: center, width: size, height: size * 0.6));
    path.addOval(Rect.fromCenter(
        center: Offset(center.dx - size * 0.3, center.dy),
        width: size * 0.8,
        height: size * 0.8));
    path.addOval(Rect.fromCenter(
        center: Offset(center.dx + size * 0.3, center.dy),
        width: size * 0.8,
        height: size * 0.8));
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final x = center.dx +
          size *
              0.5 *
              (i % 2 == 0 ? 1 : 0.5) *
              (i % 2 == 0 ? 1 : -1) *
              (i % 2 == 0 ? 1 : 0.5);
      final y = center.dy +
          size *
              0.5 *
              (i % 2 == 0 ? 1 : 0.5) *
              (i % 2 == 0 ? 1 : -1) *
              (i % 2 == 0 ? 1 : 0.5);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
