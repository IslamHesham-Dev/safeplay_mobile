import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../widgets/parent/child_list_item.dart';
import '../../widgets/parent/parent_settings_menu.dart';

/// Parent dashboard screen
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  ChildProvider? _childProvider;
  ActivityProvider? _activityProvider;
  String? _lastLoadedChildId;
  bool _isSyncingChild = false;
  int _currentNavIndex = 0;

  // Parental controls state (UI only)
  bool _safeSearchEnabled = true;
  bool _blockSocialMedia = true;
  bool _blockGambling = true;
  bool _blockViolence = true;
  final List<String> _blockedKeywords = ['violence', 'gambling', 'adult'];
  final List<String> _allowedSites = ['wikipedia.org', 'nationalgeographic.com', 'nasa.gov'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _childProvider = context.read<ChildProvider>();
      _activityProvider = context.read<ActivityProvider>();
      _childProvider?.addListener(_handleChildProviderChange);
      unawaited(_initializeDashboardState());
    });
  }

  @override
  void dispose() {
    _childProvider?.removeListener(_handleChildProviderChange);
    super.dispose();
  }

  Future<void> _initializeDashboardState() async {
    final authProvider = context.read<AuthProvider>();
    final childProvider = _childProvider;
    if (authProvider.currentUser != null && childProvider != null) {
      await childProvider.loadChildren(authProvider.currentUser!.id);
    }
    await _syncSelectedChild();
  }

  void _handleChildProviderChange() {
    unawaited(_syncSelectedChild());
  }

  Future<void> _syncSelectedChild() async {
    if (_isSyncingChild) return;
    final childProvider = _childProvider;
    final activityProvider = _activityProvider;
    if (childProvider == null || activityProvider == null) {
      return;
    }

    final selected = childProvider.selectedChild;
    _isSyncingChild = true;
    try {
      if (selected == null) {
        _lastLoadedChildId = null;
        activityProvider.clearActivities();
        return;
      }

      if (_lastLoadedChildId == selected.id &&
          activityProvider.activities.isNotEmpty) {
        return;
      }

      _lastLoadedChildId = selected.id;
      await activityProvider.loadActivitiesForChild(selected);
    } finally {
      _isSyncingChild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          const ParentSettingsMenu(),
        ],
      ),
      body: SafeArea(
        child: Consumer3<AuthProvider, ChildProvider, ActivityProvider>(
          builder: (context, authProvider, childProvider, activityProvider, _) {
            return _buildCurrentScreen(authProvider, childProvider, activityProvider);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.parentAddChild),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Child'),
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentNavIndex) {
      case 0:
        return 'Parent Dashboard';
      case 1:
        return 'Browser Controls';
      case 2:
        return 'Wellbeing Reports';
      case 3:
        return 'Messaging Safety';
      default:
        return 'Parent Dashboard';
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.shield_rounded, 'Controls'),
              _buildNavItem(2, Icons.favorite_rounded, 'Wellbeing'),
              _buildNavItem(3, Icons.security_rounded, 'Alerts'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    final color = isSelected ? SafePlayColors.brandTeal500 : SafePlayColors.neutral400;
    
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? SafePlayColors.brandTeal500.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(AuthProvider authProvider, ChildProvider childProvider, ActivityProvider activityProvider) {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeScreen(authProvider, childProvider, activityProvider);
      case 1:
        return _buildParentalControlsScreen(childProvider);
      case 2:
        return _buildWellbeingScreen(childProvider);
      case 3:
        return _buildMessagingAlertsScreen(childProvider);
      default:
        return _buildHomeScreen(authProvider, childProvider, activityProvider);
    }
  }

  // ============ HOME SCREEN ============
  Widget _buildHomeScreen(AuthProvider authProvider, ChildProvider childProvider, ActivityProvider activityProvider) {
    final user = authProvider.currentUser;
    final children = childProvider.children;
    final selectedChild = childProvider.selectedChild;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _buildWelcomeSection(context, user, children.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildChildSelectorCard(context, childProvider),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: _buildStatsRow(context, children.length, selectedChild),
          ),
        ),
                // Recent Activities Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildRecentActivitiesCard(context, childProvider, activityProvider),
                  ),
                ),
                SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: ChildrenListWidget(
              children: children,
              onChildTap: (child) {
                unawaited(childProvider.selectChild(child));
              },
              onChildEdit: (child) {
                context.push(RouteNames.parentEditChild, extra: child);
              },
              onChildSetupLogin: (child) {
                if (child.ageGroup == AgeGroup.junior) {
                  context.push(RouteNames.juniorAuthSetup, extra: child);
                } else {
                  context.push(RouteNames.brightAuthSetup, extra: child);
                }
              },
              onChildDelete: (child) async {
                final success = await childProvider.deleteChild(child.id);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${child.name}\'s profile deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(childProvider.error ?? 'Failed to delete child profile'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, UserProfile? user, int childCount) {
    final greeting = _greetingForNow();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SafePlayColors.brandTeal500,
            SafePlayColors.brandTeal600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SafePlayColors.brandTeal500.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Parent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  childCount == 0
                      ? "Let's add your children to get started."
                      : "Managing ${childCount == 1 ? '1 child' : '$childCount children'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.family_restroom, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelectorCard(BuildContext context, ChildProvider childProvider) {
    if (childProvider.children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SafePlayColors.brandOrange50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SafePlayColors.brandOrange500.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SafePlayColors.brandOrange500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.child_care, color: SafePlayColors.brandOrange500, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No children added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a child to start monitoring their safety.',
                    style: TextStyle(color: SafePlayColors.neutral600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final selectedChild = childProvider.selectedChild;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_circle, color: SafePlayColors.brandTeal500, size: 20),
              const SizedBox(width: 8),
              Text(
                'Active Child',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (selectedChild != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: SafePlayColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Selected',
                        style: TextStyle(
                          color: SafePlayColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: SafePlayColors.neutral50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SafePlayColors.neutral200),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedChild?.id,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Select a child',
                hintStyle: TextStyle(color: SafePlayColors.neutral400),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
              selectedItemBuilder: (context) {
                return childProvider.children.map((child) {
                  return Row(
                    children: [
                      _buildChildAvatar(child.gender, 28),
                      const SizedBox(width: 12),
                      Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }).toList();
              },
              items: childProvider.children
                  .map((child) => DropdownMenuItem(
                        value: child.id,
                        child: Row(
                          children: [
                            _buildChildAvatar(child.gender, 28),
                            const SizedBox(width: 12),
                            Text(
                              child.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: child.ageGroup == AgeGroup.junior
                                    ? SafePlayColors.brandTeal500.withOpacity(0.1)
                                    : SafePlayColors.brightIndigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                child.ageGroup == AgeGroup.junior ? 'Junior' : 'Bright',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: child.ageGroup == AgeGroup.junior
                                      ? SafePlayColors.brandTeal500
                                      : SafePlayColors.brightIndigo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  unawaited(childProvider.deselectChild());
                  return;
                }
                final child = childProvider.children.firstWhere((c) => c.id == value);
                unawaited(childProvider.selectChild(child));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildAvatar(String? gender, double size) {
    final g = gender?.toLowerCase();
    final imagePath = (g == 'female' || g == 'girl')
        ? 'assets/images/avatars/girl_img.png'
        : 'assets/images/avatars/boy_img.png';
    final emoji = (g == 'female' || g == 'girl') ? '👧' : '👦';
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 3),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: SafePlayColors.brandTeal500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(size / 3),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: size * 0.6)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int childCount, ChildProfile? activeChild) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Children',
            value: childCount.toString(),
            icon: Icons.people_alt_rounded,
            color: SafePlayColors.brandTeal500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'Streak',
            value: activeChild == null ? '-' : '${activeChild.streakDays}d',
            icon: Icons.local_fire_department_rounded,
            color: SafePlayColors.brandOrange500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'Safety',
            value: '100%',
            icon: Icons.verified_user_rounded,
            color: SafePlayColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: SafePlayColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  // ============ RECENT ACTIVITIES CARD ============
  Widget _buildRecentActivitiesCard(BuildContext context, ChildProvider childProvider, ActivityProvider activityProvider) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    
    List<Map<String, dynamic>> activities = [];
    if (selectedChild != null) {
      activities = [
        {
          'title': 'Letter Sound Adventure',
          'score': 85,
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'subject': 'English',
        },
        {
          'title': 'Number Counting Fun',
          'score': 100,
          'time': DateTime.now().subtract(const Duration(hours: 5)),
          'subject': 'Math',
        },
        {
          'title': 'Animal Discovery',
          'score': 90,
          'time': DateTime.now().subtract(const Duration(days: 1)),
          'subject': 'Science',
        },
      ];
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SafePlayColors.brightIndigo.withOpacity(0.15),
                      SafePlayColors.brightIndigo.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded, color: SafePlayColors.brightIndigo, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activities',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (selectedChild != null)
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: SafePlayColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${selectedChild.name}\'s activity',
                            style: TextStyle(color: SafePlayColors.success, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    else
                      Text(
                        hasChild ? 'Select a child above' : 'Add a child first',
                        style: TextStyle(color: SafePlayColors.neutral400, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (selectedChild != null && activities.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: SafePlayColors.brightIndigo,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasChild)
            _buildEmptyStateMessage(
              'Add a child to see their recent activities.',
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildEmptyStateMessage(
              'Select a child from the dropdown to view their activities.',
              Icons.touch_app_rounded,
              SafePlayColors.brandTeal500,
            )
          else if (activities.isEmpty)
            _buildEmptyStateMessage(
              'No activities yet for ${selectedChild.name}.',
              Icons.hourglass_empty_rounded,
              SafePlayColors.neutral400,
            )
          else
            ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final score = activity['score'] as int;
    final color = score >= 80
        ? SafePlayColors.success
        : score >= 60
            ? SafePlayColors.brandOrange500
            : SafePlayColors.error;
    
    final subjectColors = {
      'English': SafePlayColors.juniorPurple,
      'Math': SafePlayColors.brandOrange500,
      'Science': SafePlayColors.brandTeal500,
    };
    final subjectColor = subjectColors[activity['subject']] ?? SafePlayColors.brightIndigo;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: subjectColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school_rounded, color: subjectColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity['subject'] as String,
                        style: TextStyle(
                          color: subjectColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(activity['time'] as DateTime),
                      style: TextStyle(color: SafePlayColors.neutral400, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$score%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildEmptyStateMessage(String message, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: SafePlayColors.neutral600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ============ PARENTAL CONTROLS SCREEN ============
  Widget _buildParentalControlsScreen(ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Selector
          _buildChildSelectorCard(context, childProvider),
          const SizedBox(height: 20),
          
          if (!hasChild)
            _buildFullEmptyState(
              'Add a child first',
              'You need to add a child before configuring browser controls.',
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildFullEmptyState(
              'Select a child',
              'Choose a child from the dropdown above to configure their browser settings.',
              Icons.touch_app_rounded,
              SafePlayColors.brandTeal500,
            )
          else ...[
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SafePlayColors.brightIndigo, SafePlayColors.brightDeepPurple],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SafePlayColors.brightIndigo.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedChild.name}\'s Browser',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Configure safe browsing settings',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Safe Search Toggle
            _buildControlCard(
              title: 'Safe Search',
              subtitle: 'Filter inappropriate content from search results',
              icon: Icons.search_rounded,
              color: SafePlayColors.brandTeal500,
              trailing: Switch(
                value: _safeSearchEnabled,
                onChanged: (v) => setState(() => _safeSearchEnabled = v),
                activeColor: SafePlayColors.brandTeal500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Content Filters
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.brightIndigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.filter_alt_rounded, color: SafePlayColors.brightIndigo, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Content Filters',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFilterToggle('Block Social Media', _blockSocialMedia, (v) => setState(() => _blockSocialMedia = v)),
                  _buildFilterToggle('Block Gambling Sites', _blockGambling, (v) => setState(() => _blockGambling = v)),
                  _buildFilterToggle('Block Violence', _blockViolence, (v) => setState(() => _blockViolence = v)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Blocked Keywords
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.block_rounded, color: SafePlayColors.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Blocked Keywords',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: _showAddKeywordDialog,
                        icon: const Icon(Icons.add_circle_rounded),
                        color: SafePlayColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _blockedKeywords.map((keyword) => Chip(
                      label: Text(keyword),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => setState(() => _blockedKeywords.remove(keyword)),
                      backgroundColor: SafePlayColors.error.withOpacity(0.1),
                      deleteIconColor: SafePlayColors.error,
                      labelStyle: TextStyle(color: SafePlayColors.error),
                    )).toList(),
                  ),
                  if (_blockedKeywords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No keywords blocked yet. Tap + to add.',
                        style: TextStyle(color: SafePlayColors.neutral500, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Allowed Sites
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_rounded, color: SafePlayColors.success, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Allowed Websites',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: _showAddSiteDialog,
                        icon: const Icon(Icons.add_circle_rounded),
                        color: SafePlayColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._allowedSites.map((site) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: SafePlayColors.success.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SafePlayColors.success.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: SafePlayColors.success, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(site)),
                        IconButton(
                          onPressed: () => setState(() => _allowedSites.remove(site)),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: SafePlayColors.error,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )),
                  if (_allowedSites.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No allowed websites added yet. Tap + to add.',
                        style: TextStyle(color: SafePlayColors.neutral500, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text('Settings saved for ${selectedChild.name}'),
                        ],
                      ),
                      backgroundColor: SafePlayColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafePlayColors.brandTeal500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: SafePlayColors.neutral500, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildFilterToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SafePlayColors.brightIndigo,
          ),
        ],
      ),
    );
  }

  Widget _buildFullEmptyState(String title, String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: SafePlayColors.neutral500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddKeywordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.block_rounded, color: SafePlayColors.error, size: 24),
            const SizedBox(width: 10),
            const Text('Add Blocked Keyword'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter keyword to block',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SafePlayColors.error, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: SafePlayColors.neutral500)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _blockedKeywords.add(controller.text));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSiteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.verified_rounded, color: SafePlayColors.success, size: 24),
            const SizedBox(width: 10),
            const Text('Add Allowed Site'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., example.com',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SafePlayColors.success, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: SafePlayColors.neutral500)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _allowedSites.add(controller.text));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============ WELLBEING SCREEN ============
  Widget _buildWellbeingScreen(ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Selector
          _buildChildSelectorCard(context, childProvider),
          const SizedBox(height: 20),
          
          if (!hasChild)
            _buildFullEmptyState(
              'Add a child first',
              'You need to add a child before viewing wellbeing reports.',
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildFullEmptyState(
              'Select a child',
              'Choose a child from the dropdown above to view their wellbeing data.',
              Icons.touch_app_rounded,
              SafePlayColors.brandTeal500,
            )
          else ...[
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SafePlayColors.juniorPink, SafePlayColors.juniorPurple],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SafePlayColors.juniorPink.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedChild.name}\'s Wellbeing',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Track emotional health & mood',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Overall Score - Wide Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SafePlayColors.success, SafePlayColors.success.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SafePlayColors.success.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('😊', style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Wellbeing',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Good',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '85%',
                          style: TextStyle(
                            color: SafePlayColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'Score',
                          style: TextStyle(
                            color: SafePlayColors.success.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Weekly Mood
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.juniorPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: SafePlayColors.juniorPink, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'This Week\'s Mood',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMoodDay('Mon', '🤩', SafePlayColors.success),
                      _buildMoodDay('Tue', '🙂', SafePlayColors.brandTeal500),
                      _buildMoodDay('Wed', '🙂', SafePlayColors.brandTeal500),
                      _buildMoodDay('Thu', '😐', SafePlayColors.warning),
                      _buildMoodDay('Fri', '🤩', SafePlayColors.success),
                      _buildMoodDay('Sat', '—', SafePlayColors.neutral200),
                      _buildMoodDay('Sun', '—', SafePlayColors.neutral200),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Recent Check-ins
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.brightIndigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.history_rounded, color: SafePlayColors.brightIndigo, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recent Check-ins',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCheckinItem('Today', '🤩', 'Awesome', 'Had a great day at school!'),
                  _buildCheckinItem('Yesterday', '🙂', 'Good', 'Played with friends'),
                  _buildCheckinItem('2 days ago', '😐', 'Okay', 'Felt a bit tired'),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodDay(String day, String emoji, Color color) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: SafePlayColors.neutral400,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckinItem(String date, String emoji, String mood, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(mood, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(date, style: TextStyle(color: SafePlayColors.neutral400, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: TextStyle(color: SafePlayColors.neutral600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ MESSAGING ALERTS SCREEN ============
  Widget _buildMessagingAlertsScreen(ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    
    // Detailed mock alerts data
    final List<Map<String, dynamic>> alerts = selectedChild != null ? [
      {
        'id': '1',
        'type': 'profanity',
        'severity': 'medium',
        'title': 'Inappropriate Language Detected',
        'message': 'A mild inappropriate word was used in the conversation.',
        'contact': 'Teacher Sarah',
        'contactRole': 'Math Teacher',
        'time': DateTime.now().subtract(const Duration(hours: 3)),
        'reviewed': false,
        'flaggedText': '"I hate this stupid homework"',
        'context': 'During a homework help conversation about math problems.',
        'aiConfidence': 87,
      },
      {
        'id': '2',
        'type': 'bullying',
        'severity': 'high',
        'title': 'Potential Bullying Language',
        'message': 'Language that could be considered bullying was detected.',
        'contact': 'Student Mike',
        'contactRole': 'Classmate',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'reviewed': true,
        'flaggedText': '"You\'re so dumb, nobody likes you"',
        'context': 'Message received from another student during group chat.',
        'aiConfidence': 94,
      },
      {
        'id': '3',
        'type': 'sensitive',
        'severity': 'low',
        'title': 'Sensitive Topic Mentioned',
        'message': 'A potentially sensitive topic was discussed.',
        'contact': 'Counselor Amy',
        'contactRole': 'School Counselor',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'reviewed': true,
        'flaggedText': '"I\'ve been feeling really sad lately"',
        'context': 'During a scheduled check-in with the school counselor.',
        'aiConfidence': 72,
      },
    ] : [];
    
    final unreviewedCount = alerts.where((a) => a['reviewed'] == false).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Selector
          _buildChildSelectorCard(context, childProvider),
          const SizedBox(height: 20),
          
          if (!hasChild)
            _buildFullEmptyState(
              'Add a child first',
              'You need to add a child before viewing messaging alerts.',
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildFullEmptyState(
              'Select a child',
              'Choose a child from the dropdown above to view their messaging safety alerts.',
              Icons.touch_app_rounded,
              SafePlayColors.brandTeal500,
            )
          else ...[
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SafePlayColors.error, SafePlayColors.error.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SafePlayColors.error.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.security_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedChild.name}\'s Messages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI-powered safety monitoring',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (unreviewedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            unreviewedCount.toString(),
                            style: TextStyle(
                              color: SafePlayColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'New',
                            style: TextStyle(
                              color: SafePlayColors.error.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // AI Safety Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SafePlayColors.brightIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: SafePlayColors.brightIndigo, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Safety Guard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Monitoring all messages in real-time', style: TextStyle(color: SafePlayColors.neutral500, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SafePlayColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // What We Monitor
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.juniorPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.visibility_rounded, color: SafePlayColors.juniorPurple, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'What We Monitor',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildMonitorItem('Profanity', Icons.report_rounded, SafePlayColors.error)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMonitorItem('Bullying', Icons.warning_rounded, SafePlayColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMonitorItem('Sensitive Topics', Icons.psychology_rounded, SafePlayColors.juniorPurple)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMonitorItem('Stranger Danger', Icons.person_off_rounded, SafePlayColors.brandOrange500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Alerts List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: SafePlayColors.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Safety Alerts',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SafePlayColors.neutral100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alerts.length} total',
                          style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (alerts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: SafePlayColors.success.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SafePlayColors.success.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded, color: SafePlayColors.success, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'All Clear!',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No safety concerns detected in ${selectedChild.name}\'s recent messages.',
                                  style: TextStyle(color: SafePlayColors.neutral600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...alerts.map((alert) => _buildDetailedAlertItem(alert)),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildMonitorItem(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAlertItem(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String;
    final reviewed = alert['reviewed'] as bool;
    final time = alert['time'] as DateTime;
    final aiConfidence = alert['aiConfidence'] as int;
    
    Color severityColor;
    IconData severityIcon;
    String severityLabel;
    switch (severity) {
      case 'high':
        severityColor = SafePlayColors.error;
        severityIcon = Icons.error_rounded;
        severityLabel = 'High Priority';
        break;
      case 'medium':
        severityColor = SafePlayColors.warning;
        severityIcon = Icons.warning_rounded;
        severityLabel = 'Medium Priority';
        break;
      default:
        severityColor = SafePlayColors.brandOrange500;
        severityIcon = Icons.info_rounded;
        severityLabel = 'Low Priority';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: reviewed ? SafePlayColors.neutral50 : severityColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reviewed ? SafePlayColors.neutral200 : severityColor.withOpacity(0.3),
          width: reviewed ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: reviewed ? SafePlayColors.neutral100 : severityColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(severityIcon, color: severityColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: reviewed ? SafePlayColors.neutral600 : SafePlayColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              severityLabel,
                              style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(time),
                            style: TextStyle(color: SafePlayColors.neutral500, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!reviewed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Icon(Icons.check_circle_rounded, color: SafePlayColors.success, size: 24),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Info
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 16, color: SafePlayColors.neutral500),
                    const SizedBox(width: 6),
                    Text(
                      '${alert['contact']}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SafePlayColors.brightIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alert['contactRole'] as String,
                        style: TextStyle(color: SafePlayColors.brightIndigo, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Flagged Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: severityColor.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_quote_rounded, size: 14, color: severityColor),
                          const SizedBox(width: 6),
                          Text(
                            'Flagged Message',
                            style: TextStyle(color: severityColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert['flaggedText'] as String,
                        style: TextStyle(
                          color: SafePlayColors.neutral900,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Context
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: SafePlayColors.neutral500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        alert['context'] as String,
                        style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // AI Confidence
                Row(
                  children: [
                    Icon(Icons.smart_toy_rounded, size: 16, color: SafePlayColors.brightIndigo),
                    const SizedBox(width: 6),
                    Text(
                      'AI Confidence: ',
                      style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SafePlayColors.brightIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$aiConfidence%',
                        style: TextStyle(
                          color: SafePlayColors.brightIndigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (!reviewed) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: const Text('View Full Chat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SafePlayColors.brightIndigo,
                            side: BorderSide(color: SafePlayColors.brightIndigo.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Mark Reviewed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SafePlayColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
