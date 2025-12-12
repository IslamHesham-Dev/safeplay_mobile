import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../navigation/route_names.dart';
import '../../design_system/colors.dart';
import '../../localization/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/language_selector_dialog.dart';

/// New SafePlay Portal login screen with modern design
class SafePlayPortalLoginScreen extends StatefulWidget {
  const SafePlayPortalLoginScreen({super.key});

  @override
  State<SafePlayPortalLoginScreen> createState() =>
      _SafePlayPortalLoginScreenState();
}

class _SafePlayPortalLoginScreenState extends State<SafePlayPortalLoginScreen> {
  Future<void> _handleParentPortalTap(BuildContext context) async {
    final localeProvider = context.read<LocaleProvider>();
    final selected = await showDialog<Locale>(
      context: context,
      useRootNavigator: true,
      builder: (_) => const LanguageSelectorDialog(),
    );

    if (selected != null) {
      await localeProvider.setLocale(selected);
    }

    if (!mounted) return;
    // Replace the stack entry to avoid bouncing back after splash/login rebuilds
    context.go(RouteNames.parentOnboarding);
  }

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
          // Content - no scrolling, fits on screen
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom;
                return SizedBox(
                  height: screenHeight,
                  child: isTablet
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child:
                                _buildContent(context, isNarrow, screenHeight),
                          ),
                        )
                      : _buildContent(context, isNarrow, screenHeight),
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
    final loc = context.loc;
    // Calculate responsive spacing based on screen height
    // On smaller screens, reduce top padding significantly
    final topPadding = screenHeight < 700
        ? screenHeight * 0.08 // 8% of screen height on small screens
        : screenHeight < 900
            ? screenHeight * 0.10 // 10% on medium screens
            : screenHeight * 0.12; // 12% on large screens

    // Calculate approximate content heights
    final titleHeight = (isNarrow ? 32.0 : 38.0) * 1.2; // fontSize * lineHeight
    final subtitleHeight = 15.0 * 1.4;
    final cardHeight = 150.0;
    final cardSpacing = isNarrow ? 16.0 : 18.0;
    final footerHeight = 60.0; // Approximate footer height
    final bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom + 16
        : 32.0;

    // Calculate total fixed content height
    final totalFixedHeight = topPadding +
        titleHeight +
        8 + // spacing between title and subtitle
        subtitleHeight +
        (cardHeight * 3) + // 3 cards
        (cardSpacing * 2) + // 2 spacings between cards
        footerHeight +
        bottomPadding;

    // Calculate available space for flexible spacing
    final availableSpace = screenHeight - totalFixedHeight;
    // Use minimum spacing between tiles and footer, but ensure it's visible
    final minSpacingBetweenTilesAndFooter = 40.0;
    final spacingBetweenTitleAndTiles =
        availableSpace > minSpacingBetweenTilesAndFooter * 2
            ? (availableSpace - minSpacingBetweenTilesAndFooter) *
                0.4 // 40% for top spacing
            : availableSpace * 0.3; // On very small screens, use less
    final spacingBetweenTilesAndFooter = availableSpace >
            minSpacingBetweenTilesAndFooter * 2
        ? (availableSpace - minSpacingBetweenTilesAndFooter) *
            0.6 // 60% for bottom spacing
        : availableSpace * 0.7; // On very small screens, use more for bottom

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 16.0 : 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top padding - responsive based on screen height
          SizedBox(
              height: topPadding.clamp(40.0, 120.0)), // Clamp between 40-120px
          // Title - larger and moved downwards
          Semantics(
            label: 'SafePlay Portal',
            header: true,
            child: Text(
              loc.t('label.safeplay_portal'),
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
            label: loc.t('label.parent_subtitle'),
            child: Text(
              loc.t('label.parent_subtitle'),
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
          // Responsive spacing between title and tiles
          SizedBox(height: spacingBetweenTitleAndTiles.clamp(20.0, 100.0)),
          // Login Cards - positioned from bottom
          _buildLoginCard(
            context: context,
            stripeColor: const Color(0xFFFFA726), // Orange
            icon: Icons.sports_esports_rounded,
            iconColor: const Color(0xFFFFA726),
            title: "I'm Ready to Play!",
            subtitle: 'Tap to find your profile and explore!',
            onTap: () => context.push(RouteNames.childOnboarding),
            isNarrow: isNarrow,
            heroTag: 'child_login',
          ),
          SizedBox(height: cardSpacing),
          _buildLoginCard(
            context: context,
            stripeColor: SafePlayColors.brandTeal500, // Match title color
            icon: Icons.family_restroom_rounded,
            iconColor: SafePlayColors.brandTeal500,
            title: loc.t('label.parent_portal'),
            subtitle: loc.t('label.parent_subtitle'),
            onTap: () => _handleParentPortalTap(context),
            isNarrow: isNarrow,
            heroTag: 'parent_login',
          ),
          SizedBox(height: cardSpacing),
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
          // Responsive spacing between tiles and footer - ensures visibility on all devices
          SizedBox(
              height: spacingBetweenTilesAndFooter.clamp(
                  minSpacingBetweenTilesAndFooter, 200.0)),
          // Footer Section - positioned from bottom, always visible
          _buildFooter(context),
          // Bottom padding to ensure footer and sign-up buttons are visible at bottom
          SizedBox(height: bottomPadding),
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
