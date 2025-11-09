import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/route_names.dart';
import '../../design_system/colors.dart';

/// New SafePlay Portal login screen with modern design
class SafePlayPortalLoginScreen extends StatefulWidget {
  const SafePlayPortalLoginScreen({super.key});

  @override
  State<SafePlayPortalLoginScreen> createState() =>
      _SafePlayPortalLoginScreenState();
}

class _SafePlayPortalLoginScreenState extends State<SafePlayPortalLoginScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 350;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background image - fixed behind scroll content
          Positioned.fill(
            child: Image.asset(
              'assets/images/default.JPG',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image fails to load
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFB3E5FC), // Light sky blue
                        const Color(0xFFC8E6C9), // Light mint green
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
          // Scrollable content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom;
                return SingleChildScrollView(
                  child: SizedBox(
                    height: screenHeight,
                    child: isTablet
                        ? Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: _buildContent(
                                  context, isNarrow, screenHeight),
                            ),
                          )
                        : _buildContent(context, isNarrow, screenHeight),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, bool isNarrow, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 16.0 : 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top padding - simulating shield icon space
          const SizedBox(height: 100), // Increased to simulate shield icon
          // Title - larger and moved downwards
          Semantics(
            label: 'SafePlay Portal',
            header: true,
            child: Text(
              'SafePlay Portal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isNarrow ? 32.0 : 38.0, // Increased from 24/28
                fontWeight: FontWeight.w700,
                color: SafePlayColors.brandTeal500, // Green/cyan from theme
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle - black color
          Semantics(
            label: 'Your Gateway to Safe Learning & Play',
            child: Text(
              'Your Gateway to Safe Learning & Play',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.0,
                fontWeight: FontWeight.w400, // Changed to unbold
                color: Colors.black, // Changed to black
                height: 1.4,
              ),
            ),
          ),
          // Spacer to add breathing room while keeping tiles near mid-screen
          SizedBox(height: isNarrow ? 64.0 : 96.0),
          // Login Cards - positioned from bottom
          _buildLoginCard(
            context: context,
            stripeColor: const Color(0xFFFFA726), // Orange
            icon: Icons.sports_esports_rounded,
            iconColor: const Color(0xFFFFA726),
            title: "I'm Ready to Play!",
            subtitle: 'Tap to find your profile and explore!',
            onTap: () => context.push(RouteNames.unifiedChildLogin),
            isNarrow: isNarrow,
            heroTag: 'child_login',
          ),
          SizedBox(height: isNarrow ? 16.0 : 18.0),
          _buildLoginCard(
            context: context,
            stripeColor: SafePlayColors.brandTeal500, // Match title color
            icon: Icons.family_restroom_rounded,
            iconColor: SafePlayColors.brandTeal500,
            title: 'Parent Portal',
            subtitle: 'Manage child profiles & progress',
            onTap: () => context.push(RouteNames.parentLogin),
            isNarrow: isNarrow,
            heroTag: 'parent_login',
          ),
          SizedBox(height: isNarrow ? 16.0 : 18.0),
          _buildLoginCard(
            context: context,
            stripeColor: const Color(0xFF7E57C2), // Purple
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF7E57C2),
            title: 'Teacher Hub',
            subtitle: 'Access classroom tools & reports',
            onTap: () => context.push(RouteNames.teacherLogin),
            isNarrow: isNarrow,
            heroTag: 'teacher_login',
          ),
          const SizedBox(height: 20),
          // Footer Section - positioned from bottom, always visible
          _buildFooter(context),
          // Bottom padding to ensure footer and sign-up buttons are visible at bottom
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLoginCard({
    required BuildContext context,
    required Color stripeColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isNarrow,
    required String heroTag,
  }) {
    return Semantics(
      label: '$title. $subtitle',
      button: true,
      child: _AnimatedLoginCard(
        onTap: onTap,
        child: Container(
          height: 150, // Increased from 130 to make tiles bigger
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Left padding to indent the stripe
              const SizedBox(width: 12), // Indentation from left edge
              // Left stripe - indented
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: stripeColor,
                  borderRadius: BorderRadius.circular(
                      4), // Rounded corners for indented stripe
                ),
              ),
              // Icon and text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Icon - much bigger
                      Hero(
                        tag: heroTag,
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 48, // Increased from 36 to make much bigger
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text content
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title - bigger
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isNarrow
                                    ? 20.0
                                    : 22.0, // Increased from 16/17
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E2E2E),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Subtitle
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF555555),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Left aligned
      children: [
        // First line - smaller and unbold
        Semantics(
          label: 'New to SafePlay Portal?',
          child: Text(
            'New to SafePlay Portal?',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.0, // Reduced from 16.0
              fontWeight: FontWeight.w400, // Changed to unbold
              color: SafePlayColors.brandTeal500, // Match title color
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Second line with links - left aligned, smaller and unbold
        Wrap(
          spacing: 8,
          children: [
            Semantics(
              label: 'Sign Up as a Parent',
              button: true,
              child: GestureDetector(
                onTap: () => context.push(RouteNames.parentSignup),
                child: Text(
                  'Sign Up as a Parent',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.0, // Reduced from 16.0
                    fontWeight: FontWeight.w400, // Changed to unbold
                    color: SafePlayColors.brandTeal500, // Match title color
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.0, // Reduced from 16.0
                fontWeight: FontWeight.w400, // Changed to unbold
                color: SafePlayColors.brandTeal500,
              ),
            ),
            Semantics(
              label: 'Sign Up as a Teacher',
              button: true,
              child: GestureDetector(
                onTap: () => context.push(RouteNames.teacherSignup),
                child: Text(
                  'Sign Up as a Teacher',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.0, // Reduced from 16.0
                    fontWeight: FontWeight.w400, // Changed to unbold
                    color: SafePlayColors.brandTeal500, // Match title color
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated login card with tap feedback
class _AnimatedLoginCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedLoginCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedLoginCard> createState() => _AnimatedLoginCardState();
}

class _AnimatedLoginCardState extends State<_AnimatedLoginCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
