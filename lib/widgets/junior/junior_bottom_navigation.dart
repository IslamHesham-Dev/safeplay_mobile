import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

/// Junior bottom navigation with large icon-only tabs
class JuniorBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<JuniorNavigationItem> items;

  const JuniorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      JuniorNavigationItem(
        icon: Icons.home,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      JuniorNavigationItem(
        icon: Icons.person,
        activeIcon: Icons.person,
        label: 'Avatar',
      ),
      JuniorNavigationItem(
        icon: Icons.stars,
        activeIcon: Icons.stars,
        label: 'Rewards',
      ),
    ],
  });

  @override
  State<JuniorBottomNavigation> createState() => _JuniorBottomNavigationState();
}

class _JuniorBottomNavigationState extends State<JuniorBottomNavigation>
    with TickerProviderStateMixin {
  late final List<AnimationController> _animationControllers;
  late final List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: JuniorTheme.animationFast,
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: JuniorTheme.bounceCurve,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(40.0), // Deeply rounded pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;

          return _buildNavigationItem(
            index: index,
            item: item,
            isSelected: isSelected,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required JuniorNavigationItem item,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: Container(
              width: 56.0,
              height: 56.0,
              decoration: isSelected
                  ? BoxDecoration(
                      color: JuniorTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(
                          16.0), // Rounded-square/squircle
                      boxShadow: [
                        BoxShadow(
                          color: JuniorTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28.0,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(int index) {
    // Animate the tapped item
    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });

    // Call the onTap callback
    widget.onTap(index);
  }
}

/// Navigation item model for Junior bottom navigation
class JuniorNavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badgeText;
  final Color? badgeColor;

  const JuniorNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeText,
    this.badgeColor,
  });
}

/// Junior bottom navigation with floating action button
class JuniorBottomNavigationWithFAB extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<JuniorNavigationItem> items;
  final VoidCallback? onFABTap;
  final IconData? fabIcon;

  const JuniorBottomNavigationWithFAB({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      JuniorNavigationItem(
        icon: Icons.home,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      JuniorNavigationItem(
        icon: Icons.person,
        activeIcon: Icons.person,
        label: 'Avatar',
      ),
      JuniorNavigationItem(
        icon: Icons.stars,
        activeIcon: Icons.stars,
        label: 'Rewards',
      ),
    ],
    this.onFABTap,
    this.fabIcon,
  });

  @override
  State<JuniorBottomNavigationWithFAB> createState() =>
      _JuniorBottomNavigationWithFABState();
}

class _JuniorBottomNavigationWithFABState
    extends State<JuniorBottomNavigationWithFAB> with TickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _setupFABAnimation();
  }

  void _setupFABAnimation() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    // Start continuous animation
    _fabController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bottom navigation
        JuniorBottomNavigation(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          items: widget.items,
        ),

        // Floating Action Button
        if (widget.onFABTap != null)
          Positioned(
            top: -20.0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fabAnimation.value,
                    child: GestureDetector(
                      onTap: widget.onFABTap,
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          gradient: JuniorTheme.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(JuniorTheme.radiusCircular),
                          boxShadow: JuniorTheme.shadowHeavy,
                        ),
                        child: Icon(
                          widget.fabIcon ?? Icons.add,
                          color: Colors.white,
                          size: 28.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Junior bottom navigation with badge indicators
class JuniorBottomNavigationWithBadges extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<JuniorNavigationItem> items;
  final Map<int, String> badges; // index -> badge text

  const JuniorBottomNavigationWithBadges({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      JuniorNavigationItem(
        icon: Icons.home,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      JuniorNavigationItem(
        icon: Icons.person,
        activeIcon: Icons.person,
        label: 'Avatar',
      ),
      JuniorNavigationItem(
        icon: Icons.stars,
        activeIcon: Icons.stars,
        label: 'Rewards',
      ),
    ],
    this.badges = const {},
  });

  @override
  State<JuniorBottomNavigationWithBadges> createState() =>
      _JuniorBottomNavigationWithBadgesState();
}

class _JuniorBottomNavigationWithBadgesState
    extends State<JuniorBottomNavigationWithBadges> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        JuniorBottomNavigation(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          items: widget.items,
        ),

        // Badge indicators
        ...widget.badges.entries.map((entry) {
          final index = entry.key;
          final badgeText = entry.value;

          return Positioned(
            top: 8.0,
            left: (MediaQuery.of(context).size.width / widget.items.length) *
                    index +
                (MediaQuery.of(context).size.width / widget.items.length) / 2 +
                20.0,
            child: _buildBadge(badgeText),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        color: JuniorTheme.primaryOrange,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
        boxShadow: JuniorTheme.shadowLight,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
