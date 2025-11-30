import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';
import '../../models/activity.dart';
import '../../models/activity_session_entry.dart';
import '../../models/browser_activity_insight.dart';
import '../../models/browser_control_settings.dart';
import '../../models/chat_safety_alert.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_session_provider.dart';
import '../../providers/browser_activity_provider.dart';
import '../../providers/browser_control_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/messaging_safety_provider.dart';
import '../../widgets/parent/child_list_item.dart';
import '../../widgets/parent/parent_settings_menu.dart';
import '../../services/messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Parent dashboard screen
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  ChildProvider? _childProvider;
  ActivityProvider? _activityProvider;
  MessagingSafetyProvider? _messagingSafetyProvider;
  BrowserControlProvider? _browserControlProvider;
  BrowserActivityProvider? _browserActivityProvider;
  ActivitySessionProvider? _activitySessionProvider;
  String? _lastLoadedChildId;
  bool _isSyncingChild = false;
  int _currentNavIndex = 0;
  bool _showAllRecentActivities = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _childProvider = context.read<ChildProvider>();
      _activityProvider = context.read<ActivityProvider>();
      _messagingSafetyProvider = context.read<MessagingSafetyProvider>();
      _browserControlProvider = context.read<BrowserControlProvider>();
      _browserActivityProvider = context.read<BrowserActivityProvider>();
      _activitySessionProvider = context.read<ActivitySessionProvider>();
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
    if (mounted) {
      setState(() {
        _showAllRecentActivities = false;
      });
    }
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

      final shouldReloadActivities = _lastLoadedChildId != selected.id ||
          activityProvider.activities.isEmpty;
      if (shouldReloadActivities) {
        _lastLoadedChildId = selected.id;
        await activityProvider.loadActivitiesForChild(selected);
      }

      final parent = context.read<AuthProvider>().currentUser;
      final safetyProvider = _messagingSafetyProvider;
      final browserProvider = _browserControlProvider;
      final activitySummaryProvider = _browserActivityProvider;
      final sessionProvider = _activitySessionProvider;
      if (parent != null && safetyProvider != null) {
        unawaited(
          safetyProvider.analyzeChild(
            parent: parent,
            child: selected,
          ),
        );
      }
      if (browserProvider != null) {
        unawaited(browserProvider.loadSettings(selected.id));
      }
      if (activitySummaryProvider != null) {
        unawaited(
          activitySummaryProvider.loadActivity(
            selected.id,
            selected.name,
          ),
        );
      }
      if (sessionProvider != null) {
        unawaited(sessionProvider.loadSessions(selected.id));
      }
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
        child: Consumer6<
            AuthProvider,
            ChildProvider,
            ActivityProvider,
            MessagingSafetyProvider,
            BrowserControlProvider,
            BrowserActivityProvider>(
          builder: (context, authProvider, childProvider, activityProvider,
              safetyProvider, browserProvider, activitySummaryProvider, _) {
            return Consumer<ActivitySessionProvider>(
              builder: (context, sessionProvider, __) {
                return _buildCurrentScreen(
                  authProvider,
                  childProvider,
                  activityProvider,
                  safetyProvider,
                  browserProvider,
                  activitySummaryProvider,
                  sessionProvider,
                );
              },
            );
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
    final color =
        isSelected ? SafePlayColors.brandTeal500 : SafePlayColors.neutral400;

    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? SafePlayColors.brandTeal500.withOpacity(0.1)
              : Colors.transparent,
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

  Widget _buildCurrentScreen(
    AuthProvider authProvider,
    ChildProvider childProvider,
    ActivityProvider activityProvider,
    MessagingSafetyProvider safetyProvider,
    BrowserControlProvider browserProvider,
    BrowserActivityProvider activitySummaryProvider,
    ActivitySessionProvider activitySessionProvider,
  ) {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeScreen(
          authProvider,
          childProvider,
          activitySessionProvider,
        );
      case 1:
        return _buildParentalControlsScreen(
          childProvider,
          browserProvider,
          activitySummaryProvider,
        );
      case 2:
        return _buildWellbeingScreen(childProvider);
      case 3:
        return _buildMessagingAlertsScreen(
          authProvider,
          childProvider,
          safetyProvider,
        );
      default:
        return _buildHomeScreen(
          authProvider,
          childProvider,
          activitySessionProvider,
        );
    }
  }

  // ============ HOME SCREEN ============
  Widget _buildHomeScreen(
    AuthProvider authProvider,
    ChildProvider childProvider,
    ActivitySessionProvider sessionProvider,
  ) {
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
            child: _buildRecentActivitiesCard(
                context, childProvider, sessionProvider),
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
                        content: Text(
                            '${child.name}\'s profile deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(childProvider.error ??
                            'Failed to delete child profile'),
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

  Widget _buildWelcomeSection(
      BuildContext context, UserProfile? user, int childCount) {
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
            child: const Icon(Icons.family_restroom,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelectorCard(
      BuildContext context, ChildProvider childProvider) {
    if (childProvider.children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SafePlayColors.brandOrange50,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: SafePlayColors.brandOrange500.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SafePlayColors.brandOrange500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.child_care,
                  color: SafePlayColors.brandOrange500, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No children added yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a child to start monitoring their safety.',
                    style: TextStyle(
                        color: SafePlayColors.neutral600, fontSize: 13),
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
              const Icon(Icons.person_pin_circle,
                  color: SafePlayColors.brandTeal500, size: 20),
              const SizedBox(width: 8),
              Text(
                'Active Child',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (selectedChild != null) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: child.ageGroup == AgeGroup.junior
                                    ? SafePlayColors.brandTeal500
                                        .withOpacity(0.1)
                                    : SafePlayColors.brightIndigo
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                child.ageGroup == AgeGroup.junior
                                    ? 'Junior'
                                    : 'Bright',
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
                final child =
                    childProvider.children.firstWhere((c) => c.id == value);
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

  Widget _buildStatsRow(
      BuildContext context, int childCount, ChildProfile? activeChild) {
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
  Widget _buildRecentActivitiesCard(
    BuildContext context,
    ChildProvider childProvider,
    ActivitySessionProvider sessionProvider,
  ) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    final childId = selectedChild?.id ?? '';
    final sessions = selectedChild == null
        ? const <ActivitySessionEntry>[]
        : sessionProvider.sessionsFor(childId);
    final isLoading =
        selectedChild != null && sessionProvider.isLoading(childId);
    final error =
        selectedChild != null ? sessionProvider.errorFor(childId) : null;
    final hasSessions = sessions.isNotEmpty;
    final canToggle = sessions.length > 3;
    final showAll = _showAllRecentActivities || !canToggle;
    final visibleSessions =
        showAll ? sessions : sessions.take(3).toList(growable: false);
    final recentItems = visibleSessions
        .map(_mapSessionToRecentActivity)
        .toList(growable: false);

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
                child: const Icon(Icons.history_rounded,
                    color: SafePlayColors.brightIndigo, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activities',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                            style: TextStyle(
                                color: SafePlayColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    else
                      Text(
                        hasChild ? 'Select a child above' : 'Add a child first',
                        style: TextStyle(
                            color: SafePlayColors.neutral400, fontSize: 12),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh activity feed',
                onPressed: (selectedChild == null || isLoading)
                    ? null
                    : () {
                        setState(() {
                          _showAllRecentActivities = false;
                        });
                        unawaited(
                          sessionProvider.loadSessions(selectedChild.id),
                        );
                      },
              ),
              if (selectedChild != null && hasSessions && canToggle)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllRecentActivities = !_showAllRecentActivities;
                    });
                  },
                  child: Text(
                    _showAllRecentActivities ? 'Show Less' : 'View All',
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
          else if (isLoading && !hasSessions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (!hasSessions)
            _buildEmptyStateMessage(
              'No activities yet for ${selectedChild.name}.',
              Icons.hourglass_empty_rounded,
              SafePlayColors.neutral400,
            )
          else ...[
            ...recentItems.map(_buildActivityItem),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
          if (error != null && hasSessions)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Showing cached insights. Refresh to try again.',
                style: TextStyle(
                  color: SafePlayColors.warning,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SafePlayColors.neutral50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SafePlayColors.neutral200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: SafePlayColors.neutral600,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This summary respects privacy by showing abstracted activity patterns, not personal details.',
                    style: TextStyle(
                      color: SafePlayColors.neutral600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_RecentActivityItem activity) {
    final accentColor = activity.subjectColor;
    final completionColor = SafePlayColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.videogame_asset_rounded,
                color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity.subjectLabel,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.timeLabel,
                      style: TextStyle(
                        color: SafePlayColors.neutral500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: completionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${activity.completionPercent}%',
              style: TextStyle(
                color: completionColor,
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

  _RecentActivityItem _mapSessionToRecentActivity(
    ActivitySessionEntry entry,
  ) {
    final subjectEnum = _mapRawSubjectToEnum(entry.subject);
    final subjectLabel =
        subjectEnum?.displayName ?? _formatSubjectLabel(entry.subject);
    return _RecentActivityItem(
      title: entry.title,
      subjectLabel: subjectLabel,
      subjectColor: _subjectColor(subjectEnum),
      timeLabel: _formatDurationLabel(entry.durationMinutes),
      completionPercent: 100,
    );
  }

  ActivitySubject? _mapRawSubjectToEnum(String? raw) {
    final normalized = raw?.toLowerCase().trim() ?? '';
    if (normalized.isEmpty) return null;
    if (normalized.contains('english')) {
      return ActivitySubject.reading;
    }
    if (normalized.contains('language')) {
      return ActivitySubject.reading;
    }
    if (normalized.contains('writing')) {
      return ActivitySubject.writing;
    }
    return ActivitySubject.fromString(normalized);
  }

  Color _subjectColor(ActivitySubject? subject) {
    switch (subject) {
      case ActivitySubject.math:
        return SafePlayColors.brandOrange500;
      case ActivitySubject.reading:
      case ActivitySubject.writing:
        return SafePlayColors.brightIndigo;
      case ActivitySubject.science:
        return SafePlayColors.brandTeal500;
      case ActivitySubject.social:
        return SafePlayColors.brightDeepPurple;
      case ActivitySubject.art:
        return SafePlayColors.juniorPink;
      case ActivitySubject.music:
        return SafePlayColors.juniorPurple;
      case ActivitySubject.coding:
        return SafePlayColors.brightTeal;
      default:
        return SafePlayColors.neutral600;
    }
  }

  String _formatDurationLabel(int? minutes) {
    if (minutes == null || minutes <= 0) {
      return 'Teacher-assigned session';
    }
    if (minutes == 1) return '1 min session';
    return '$minutes min session';
  }

  String _formatSubjectLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'Learning';
    final normalized = raw.replaceAll(RegExp(r'[_\\-]+'), ' ').trim();
    if (normalized.isEmpty) return 'Learning';
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  // ============ PARENTAL CONTROLS SCREEN ============
  Widget _buildParentalControlsScreen(
    ChildProvider childProvider,
    BrowserControlProvider browserProvider,
    BrowserActivityProvider activityProvider,
  ) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    final childId = selectedChild?.id ?? '';
    final settings =
        childId.isNotEmpty ? browserProvider.settingsFor(childId) : null;
    final isLoading = childId.isNotEmpty && browserProvider.isLoading(childId);
    final isSaving = childId.isNotEmpty && browserProvider.isSaving(childId);
    final error = childId.isNotEmpty ? browserProvider.errorFor(childId) : null;
    final usingDefaults = settings == null;
    final currentSettings = settings ?? BrowserControlSettings.defaults();
    final controlsDisabled = childId.isEmpty || isLoading || isSaving;
    final blockedKeywords = currentSettings.blockedKeywords;
    final allowedSites = currentSettings.allowedSites;
    final waitingForCloudSnapshot = usingDefaults && isLoading;

    Future<void> handleRefresh() async {
      if (childId.isEmpty) return;
      await browserProvider.refresh(childId);
    }

    return RefreshIndicator(
      onRefresh: handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildSelectorCard(context, childProvider),
            const SizedBox(height: 20),
            if (!hasChild) ...[
              _buildFullEmptyState(
                'Add a child first',
                'You need to add at least one child before configuring browser controls.',
                Icons.child_care_rounded,
                SafePlayColors.brandOrange500,
              ),
            ] else if (selectedChild == null) ...[
              _buildFullEmptyState(
                'Select a child',
                'Choose a child from the dropdown above to configure their browser settings.',
                Icons.touch_app_rounded,
                SafePlayColors.brandTeal500,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SafePlayColors.brightIndigo,
                      SafePlayColors.brightDeepPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: SafePlayColors.brightIndigo.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${selectedChild.name}'s Browser",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Cloud-backed safe browsing rules',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : handleRefresh,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            textStyle: const TextStyle(fontSize: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip(
                          label: currentSettings.safeSearchEnabled
                              ? 'Safe Search On'
                              : 'Safe Search Off',
                          icon: Icons.search_rounded,
                          isActive: currentSettings.safeSearchEnabled,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white70,
                          backgroundColor: Colors.white.withOpacity(
                            currentSettings.safeSearchEnabled ? 0.15 : 0.05,
                          ),
                        ),
                        _buildStatusChip(
                          label: currentSettings.blockSocialMedia
                              ? 'Social Apps Blocked'
                              : 'Social Apps Allowed',
                          icon: Icons.group_off_rounded,
                          isActive: currentSettings.blockSocialMedia,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white70,
                          backgroundColor: Colors.white.withOpacity(
                            currentSettings.blockSocialMedia ? 0.15 : 0.05,
                          ),
                        ),
                        _buildStatusChip(
                          label: currentSettings.blockGambling
                              ? 'Gambling Blocked'
                              : 'Gambling Allowed',
                          icon: Icons.casino_rounded,
                          isActive: currentSettings.blockGambling,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white70,
                          backgroundColor: Colors.white.withOpacity(
                            currentSettings.blockGambling ? 0.15 : 0.05,
                          ),
                        ),
                        _buildStatusChip(
                          label: currentSettings.blockViolence
                              ? 'Violence Blocked'
                              : 'Violence Allowed',
                          icon: Icons.no_crash_rounded,
                          isActive: currentSettings.blockViolence,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white70,
                          backgroundColor: Colors.white.withOpacity(
                            currentSettings.blockViolence ? 0.15 : 0.05,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          isLoading ? Icons.sync : Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isLoading
                                ? 'Syncing latest settings...'
                                : _formatSyncDescription(
                                    currentSettings.updatedAt,
                                  ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (usingDefaults && !isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Using SafePlay defaults until the first cloud sync completes.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SafePlayColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: SafePlayColors.error.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: SafePlayColors.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We could not sync the latest rules: $error',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : handleRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
              if (isSaving) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brandTeal500.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Saving updates securely...',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (waitingForCloudSnapshot) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SafePlayColors.neutral50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.cloud_download_rounded,
                        color: SafePlayColors.brandTeal500,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fetching the latest browser policy for this child...',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildControlCard(
                title: 'AI Safe Search',
                subtitle:
                    'Filters harmful topics directly in the SafePlay browser.',
                icon: Icons.search_rounded,
                color: SafePlayColors.brandTeal500,
                trailing: Switch.adaptive(
                  value: currentSettings.safeSearchEnabled,
                  onChanged: controlsDisabled
                      ? null
                      : (value) => browserProvider.setSafeSearch(
                            childId,
                            value,
                          ),
                  activeColor: SafePlayColors.brandTeal500,
                ),
              ),
              const SizedBox(height: 16),
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
                          child: const Icon(
                            Icons.filter_alt_rounded,
                            color: SafePlayColors.brightIndigo,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Content Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFilterToggle(
                      'Block Social Media',
                      currentSettings.blockSocialMedia,
                      controlsDisabled
                          ? null
                          : (value) =>
                              browserProvider.setSocialFilter(childId, value),
                      description:
                          'Prevents Facebook, TikTok, Discord & similar sites.',
                      icon: Icons.groups_2_rounded,
                    ),
                    _buildFilterToggle(
                      'Block Gambling Sites',
                      currentSettings.blockGambling,
                      controlsDisabled
                          ? null
                          : (value) =>
                              browserProvider.setGamblingFilter(childId, value),
                      description:
                          'Stops betting, casino and loot-box content.',
                      icon: Icons.casino_rounded,
                    ),
                    _buildFilterToggle(
                      'Block Violent Media',
                      currentSettings.blockViolence,
                      controlsDisabled
                          ? null
                          : (value) =>
                              browserProvider.setViolenceFilter(childId, value),
                      description:
                          'Removes graphic games, gore and unsafe forums.',
                      icon: Icons.no_crash_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                          child: const Icon(
                            Icons.block_rounded,
                            color: SafePlayColors.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Blocked Keywords',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controlsDisabled
                              ? null
                              : () => _showAddKeywordDialog(
                                    childId,
                                    browserProvider,
                                  ),
                          icon: const Icon(Icons.add_circle_rounded),
                          color: SafePlayColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (blockedKeywords.isEmpty)
                      Text(
                        'No custom keywords yet. Add phrases you never want to appear.',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 13,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: blockedKeywords
                            .map(
                              (keyword) => Chip(
                                label: Text(keyword),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                onDeleted: controlsDisabled
                                    ? null
                                    : () => unawaited(
                                          browserProvider.removeBlockedKeyword(
                                            childId,
                                            keyword,
                                          ),
                                        ),
                                backgroundColor:
                                    SafePlayColors.error.withOpacity(0.08),
                                deleteIconColor: SafePlayColors.error,
                                labelStyle: const TextStyle(
                                  color: SafePlayColors.error,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                          child: const Icon(
                            Icons.verified_rounded,
                            color: SafePlayColors.success,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Allowed Sites',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controlsDisabled
                              ? null
                              : () => _showAddSiteDialog(
                                    childId,
                                    browserProvider,
                                  ),
                          icon: const Icon(Icons.add_circle_rounded),
                          color: SafePlayColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (allowedSites.isEmpty)
                      Text(
                        'Only SafePlay curated destinations will be accessible. Add trusted domains to whitelist them.',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 13,
                        ),
                      ),
                    ...allowedSites.map(
                      (site) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: SafePlayColors.success.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: SafePlayColors.success.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.language,
                              color: SafePlayColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatSiteLabel(site),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    site,
                                    style: TextStyle(
                                      color: SafePlayColors.neutral500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: controlsDisabled
                                  ? null
                                  : () => unawaited(
                                        browserProvider.removeAllowedSite(
                                          childId,
                                          site,
                                        ),
                                      ),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                              ),
                              color: SafePlayColors.error,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Browser Activity History Section
              _buildBrowserHistorySection(
                selectedChild,
                activityProvider,
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
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
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: SafePlayColors.neutral500, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildFilterToggle(
    String label,
    bool value,
    ValueChanged<bool>? onChanged, {
    String? description,
    IconData icon = Icons.shield_rounded,
  }) {
    final iconColor = onChanged == null
        ? SafePlayColors.neutral300
        : SafePlayColors.brightIndigo;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: description == null
          ? null
          : Text(
              description,
              style: TextStyle(
                color: SafePlayColors.neutral500,
                fontSize: 12,
              ),
            ),
      value: value,
      onChanged: onChanged,
      activeColor: SafePlayColors.brandTeal500,
    );
  }

  Widget _buildFullEmptyState(
      String title, String message, IconData icon, Color color) {
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

  Widget _buildBrowserHistorySection(
    ChildProfile? child,
    BrowserActivityProvider activityProvider,
  ) {
    if (child == null) return const SizedBox.shrink();

    final childId = child.id;
    final insights = activityProvider.insightsFor(childId);
    final isLoading = activityProvider.isLoading(childId);
    final error = activityProvider.errorFor(childId);
    final activityItems =
        insights.map(_mapInsightToActivityItem).toList(growable: false);

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
                  color: SafePlayColors.brandTeal500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: SafePlayColors.brandTeal500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Browser Activity History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: isLoading
                    ? null
                    : () => activityProvider.loadActivity(
                          child.id,
                          child.name,
                        ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'High-level summary of ${child.name}\'s online activity. Privacy-focused insights.',
            style: TextStyle(
              color: SafePlayColors.neutral600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SafePlayColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SafePlayColors.error.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to load recent browsing insights.',
                    style: TextStyle(
                      color: SafePlayColors.neutral700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error,
                    style: TextStyle(
                      color: SafePlayColors.neutral600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else if (activityItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SafePlayColors.neutral50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${child.name} hasn\'t generated enough Safe Browser activity for a summary yet. Encourage supervised browsing to see privacy-preserving insights here.',
                style: TextStyle(
                  color: SafePlayColors.neutral600,
                  height: 1.4,
                ),
              ),
            )
          else
            ...activityItems
                .map((activity) => _buildBrowserActivityItem(activity)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SafePlayColors.neutral50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SafePlayColors.neutral200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: SafePlayColors.neutral600,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This summary respects privacy by showing abstracted activity patterns, not personal details.',
                    style: TextStyle(
                      color: SafePlayColors.neutral600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowserActivityItem(_BrowserActivityItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: activity.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activity.color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.summary,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity.category,
                        style: TextStyle(
                          color: activity.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.timeAgo,
                      style: TextStyle(
                        color: SafePlayColors.neutral500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _BrowserActivityItem _mapInsightToActivityItem(
    BrowserActivityInsight insight,
  ) {
    final categoryKey = insight.category.toLowerCase();
    Color color = SafePlayColors.brandTeal500;
    IconData icon = Icons.language_rounded;

    if (categoryKey.contains('safety') || categoryKey.contains('block')) {
      color = SafePlayColors.error;
      icon = Icons.block_rounded;
    } else if (categoryKey.contains('learning') ||
        categoryKey.contains('educational')) {
      color = SafePlayColors.brandTeal500;
      icon = Icons.school_rounded;
    } else if (categoryKey.contains('entertainment')) {
      color = SafePlayColors.brandOrange500;
      icon = Icons.play_circle_outline_rounded;
    } else if (categoryKey.contains('social')) {
      color = SafePlayColors.brightIndigo;
      icon = Icons.group_rounded;
    } else if (categoryKey.contains('current')) {
      color = SafePlayColors.success;
      icon = Icons.public_rounded;
    } else if (categoryKey.contains('sensitive')) {
      color = SafePlayColors.error;
      icon = Icons.warning_amber_rounded;
    } else {
      color = SafePlayColors.neutral600;
      icon = Icons.history_rounded;
    }

    return _BrowserActivityItem(
      icon: icon,
      color: color,
      summary: insight.summary,
      category: insight.category,
      timeAgo: insight.timeframe,
    );
  }

  void _showAddKeywordDialog(
    String childId,
    BrowserControlProvider browserProvider,
  ) {
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
            child: Text('Cancel',
                style: TextStyle(color: SafePlayColors.neutral500)),
          ),
          ElevatedButton(
            onPressed: () {
              final keyword = controller.text.trim().toLowerCase();
              Navigator.pop(context);
              if (keyword.isNotEmpty && childId.isNotEmpty) {
                unawaited(browserProvider.addBlockedKeyword(childId, keyword));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSiteDialog(
    String childId,
    BrowserControlProvider browserProvider,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.verified_rounded,
                color: SafePlayColors.success, size: 24),
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
            child: Text('Cancel',
                style: TextStyle(color: SafePlayColors.neutral500)),
          ),
          ElevatedButton(
            onPressed: () {
              final site = controller.text.trim();
              Navigator.pop(context);
              if (site.isNotEmpty && childId.isNotEmpty) {
                unawaited(browserProvider.addAllowedSite(childId, site));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.success,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                  colors: [
                    SafePlayColors.juniorPink,
                    SafePlayColors.juniorPurple
                  ],
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
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 32),
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
                  colors: [
                    SafePlayColors.success,
                    SafePlayColors.success.withOpacity(0.8)
                  ],
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                        child: const Icon(Icons.calendar_month_rounded,
                            color: SafePlayColors.juniorPink, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'This Week\'s Mood',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
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
                        child: const Icon(Icons.history_rounded,
                            color: SafePlayColors.brightIndigo, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recent Check-ins',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCheckinItem(
                      'Today', '🤩', 'Awesome', 'Had a great day at school!'),
                  _buildCheckinItem(
                      'Yesterday', '🙂', 'Good', 'Played with friends'),
                  _buildCheckinItem(
                      '2 days ago', '😐', 'Okay', 'Felt a bit tired'),
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

  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required bool isActive,
    Color? activeColor,
    Color? inactiveColor,
    Color? backgroundColor,
  }) {
    final resolvedColor = isActive
        ? (activeColor ?? SafePlayColors.brandTeal500)
        : (inactiveColor ?? SafePlayColors.neutral500);
    final resolvedBackground =
        backgroundColor ?? resolvedColor.withOpacity(isActive ? 0.15 : 0.08);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: resolvedColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: resolvedColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSyncDescription(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Never synced yet';
    }
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Last synced just now';
    if (diff.inHours < 1) {
      final minutes = diff.inMinutes;
      return 'Last synced ${minutes} minute${minutes == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 1) {
      final hours = diff.inHours;
      return 'Last synced ${hours} hour${hours == 1 ? '' : 's'} ago';
    }
    final days = diff.inDays;
    return 'Last synced ${days} day${days == 1 ? '' : 's'} ago';
  }

  String _formatSiteLabel(String site) {
    var normalized = site.trim();
    if (normalized.startsWith('https://')) {
      normalized = normalized.substring(8);
    } else if (normalized.startsWith('http://')) {
      normalized = normalized.substring(7);
    }
    if (normalized.startsWith('www.')) {
      normalized = normalized.substring(4);
    }
    return normalized;
  }

  Widget _buildCheckinItem(
      String date, String emoji, String mood, String note) {
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
                    Text(mood,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(date,
                        style: TextStyle(
                            color: SafePlayColors.neutral400, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style:
                      TextStyle(color: SafePlayColors.neutral600, fontSize: 13),
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

  Widget _buildMessagingAlertsScreen(
    AuthProvider authProvider,
    ChildProvider childProvider,
    MessagingSafetyProvider safetyProvider,
  ) {
    final parent = authProvider.currentUser;

    final selectedChild = childProvider.selectedChild;

    final hasChild = childProvider.children.isNotEmpty;

    final alerts = safetyProvider.alertsForChild(selectedChild?.id);

    final isLoading = safetyProvider.isLoading(selectedChild?.id);

    final error = safetyProvider.error;

    final lastScan = selectedChild != null
        ? safetyProvider.lastFetchedForChild(selectedChild.id)
        : null;

    final profanityCount = alerts
        .where((alert) => alert.category == SafetyCategory.profanity)
        .length;

    final bullyingCount = alerts
        .where((alert) => alert.category == SafetyCategory.bullying)
        .length;

    final sensitiveCount = alerts
        .where((alert) => alert.category == SafetyCategory.sensitiveTopics)
        .length;

    final strangerCount = alerts
        .where((alert) => alert.category == SafetyCategory.strangerDanger)
        .length;

    final unreviewedCount =
        alerts.where((alert) => alert.reviewed == false).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SafePlayColors.error,
                    SafePlayColors.error.withOpacity(0.8),
                  ],
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
                    child: const Icon(Icons.security_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedChild.name}'s Messages",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${alerts.length} alerts | ${unreviewedCount} need review',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'AI Guard',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SafePlayColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.safety_check_rounded,
                            color: SafePlayColors.success, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Safety Guard',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Monitoring chats between ${selectedChild.name} and teachers',
                              style: TextStyle(
                                color: SafePlayColors.neutral500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Run new scan',
                        onPressed: parent == null || isLoading
                            ? null
                            : () {
                                safetyProvider.analyzeChild(
                                  parent: parent,
                                  child: selectedChild,
                                  forceRefresh: true,
                                );
                              },
                        icon: const Icon(Icons.refresh_rounded),
                        color: SafePlayColors.brightIndigo,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: SafePlayColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.verified_user_rounded,
                          label: 'Model',
                          value: 'DeepSeek V3.1',
                          color: SafePlayColors.brightIndigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.access_time,
                          label: 'Last scan',
                          value: lastScan != null
                              ? _formatTime(lastScan)
                              : (isLoading ? 'Scanning...' : 'Pending'),
                          color: SafePlayColors.brandOrange500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.warning_amber_rounded,
                          label: 'Needs review',
                          value: '$unreviewedCount alert(s)',
                          color: SafePlayColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                        child: const Icon(Icons.visibility_rounded,
                            color: SafePlayColors.juniorPurple, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'What We Monitor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMonitorItem(
                          'Profanity',
                          Icons.report_rounded,
                          SafePlayColors.error,
                          count: profanityCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMonitorItem(
                          'Bullying',
                          Icons.warning_rounded,
                          SafePlayColors.warning,
                          count: bullyingCount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMonitorItem(
                          'Sensitive Topics',
                          Icons.psychology_rounded,
                          SafePlayColors.juniorPurple,
                          count: sensitiveCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMonitorItem(
                          'Stranger Danger',
                          Icons.person_off_rounded,
                          SafePlayColors.brandOrange500,
                          count: strangerCount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                        child: const Icon(Icons.notifications_active_rounded,
                            color: SafePlayColors.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Safety Alerts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SafePlayColors.neutral100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alerts.length} total',
                          style: TextStyle(
                            color: SafePlayColors.neutral600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (error != null && alerts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SafePlayColors.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: SafePlayColors.error.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: SafePlayColors.error, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                color: SafePlayColors.neutral600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (alerts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: SafePlayColors.success.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: SafePlayColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              color: SafePlayColors.success, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'All clear!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "DeepSeek did not detect harmful content in ${selectedChild.name}'s latest messages.",
                                  style: TextStyle(
                                    color: SafePlayColors.neutral600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...alerts.map(
                      (alert) => _buildDetailedAlertItem(
                        alert,
                        selectedChild.id,
                        safetyProvider,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: SafePlayColors.neutral600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorItem(
    String label,
    IconData icon,
    Color color, {
    int count = 0,
  }) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 0
                      ? 'No recent alerts'
                      : '$count recent alert${count == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: SafePlayColors.neutral500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAlertItem(
    ChatSafetyAlert alert,
    String childId,
    MessagingSafetyProvider safetyProvider,
  ) {
    final severity = alert.severity.toLowerCase();
    final reviewed = alert.reviewed;
    final time = alert.timestamp;
    final aiConfidence = alert.confidencePercent;

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
        color: reviewed
            ? SafePlayColors.neutral50
            : severityColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reviewed
              ? SafePlayColors.neutral200
              : severityColor.withOpacity(0.3),
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
              color: reviewed
                  ? SafePlayColors.neutral100
                  : severityColor.withOpacity(0.08),
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
                        alert.title ?? '${alert.category.label} detected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: reviewed
                              ? SafePlayColors.neutral600
                              : SafePlayColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              severityLabel,
                              style: TextStyle(
                                  color: severityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SafePlayColors.neutral200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alert.category.label,
                              style: TextStyle(
                                color: SafePlayColors.neutral700,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                                color: SafePlayColors.neutral500, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!reviewed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Icon(Icons.check_circle_rounded,
                      color: SafePlayColors.success, size: 24),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 16, color: SafePlayColors.neutral500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${alert.offenderName} → ${alert.targetName}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildRoleChip(alert.offenderRole),
                              _buildRoleChip(alert.targetRole),
                              _buildDirectionChip(alert.directionLabel),
                            ],
                          ),
                        ],
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
                          Icon(Icons.format_quote_rounded,
                              size: 14, color: severityColor),
                          const SizedBox(width: 6),
                          Text(
                            'Flagged Message',
                            style: TextStyle(
                                color: severityColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert.flaggedText,
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
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: SafePlayColors.neutral500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        alert.context,
                        style: TextStyle(
                            color: SafePlayColors.neutral600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // AI Confidence
                Row(
                  children: [
                    Icon(Icons.smart_toy_rounded,
                        size: 16, color: SafePlayColors.brightIndigo),
                    const SizedBox(width: 6),
                    Text(
                      'AI Confidence: ',
                      style: TextStyle(
                          color: SafePlayColors.neutral600, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                          onPressed: () {
                            _showFullChatDialog(context, alert);
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 16),
                          label: const Text('View Full Chat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SafePlayColors.brightIndigo,
                            side: BorderSide(
                                color: SafePlayColors.brightIndigo
                                    .withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            safetyProvider.markAlertReviewed(childId, alert.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Marked alert from ${alert.offenderName} as reviewed.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white),
                          label: const Text('Mark Reviewed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SafePlayColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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

  Widget _buildRoleChip(String role) {
    final normalized = role.toLowerCase();
    final isTeacher = normalized.contains('teacher');
    final color =
        isTeacher ? SafePlayColors.brightIndigo : SafePlayColors.brandTeal500;
    final label = isTeacher ? 'Teacher' : 'Child';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDirectionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SafePlayColors.brandOrange500.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: SafePlayColors.brandOrange500,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showFullChatDialog(
      BuildContext context, ChatSafetyAlert alert) async {
    // Get childId from the current selected child
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    final selectedChild = childProvider.selectedChild;
    if (selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child first')),
      );
      return;
    }

    final childId = selectedChild.id;
    final messagingService = MessagingService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // First, find the teacherId by looking up the source message
      String? teacherId;
      final firestore = FirebaseFirestore.instance;

      // Try to find the message in teacherInboxCollection (child to teacher) by document ID
      try {
        final childToTeacherDoc = await firestore
            .collection(MessagingService.teacherInboxCollection)
            .doc(alert.sourceMessageId)
            .get();

        if (childToTeacherDoc.exists && childToTeacherDoc.data() != null) {
          final data = childToTeacherDoc.data()!;
          if (data['childId'] == childId) {
            teacherId = data['teacherId']?.toString();
          }
        }
      } catch (_) {
        // Document might not exist or be in different collection
      }

      // If not found, try childInboxCollection (teacher to child)
      if (teacherId == null) {
        try {
          final teacherToChildDoc = await firestore
              .collection(MessagingService.childInboxCollection)
              .doc(alert.sourceMessageId)
              .get();

          if (teacherToChildDoc.exists && teacherToChildDoc.data() != null) {
            final data = teacherToChildDoc.data()!;
            if (data['childId'] == childId) {
              teacherId = data['teacherId']?.toString();
            }
          }
        } catch (_) {
          // Document might not exist
        }
      }

      // If we still don't have teacherId, try to find it by fetching recent messages and filtering in memory
      if (teacherId == null) {
        try {
          // Fetch recent messages without time filters to avoid index requirements
          final allChildMessages = await firestore
              .collection(MessagingService.teacherInboxCollection)
              .where('childId', isEqualTo: childId)
              .orderBy('createdAt', descending: true)
              .limit(50)
              .get();

          // Filter by timestamp in memory
          for (final doc in allChildMessages.docs) {
            final data = doc.data();
            final createdAt = data['createdAt'];
            DateTime timestamp;
            if (createdAt is Timestamp) {
              timestamp = createdAt.toDate();
            } else if (createdAt is DateTime) {
              timestamp = createdAt;
            } else {
              continue;
            }

            // Check if this message is within 1 hour of the alert timestamp
            if (timestamp.isAfter(
                    alert.timestamp.subtract(const Duration(hours: 1))) &&
                timestamp
                    .isBefore(alert.timestamp.add(const Duration(hours: 1)))) {
              teacherId = data['teacherId']?.toString();
              break;
            }
          }
        } catch (_) {
          // If orderBy fails (missing index), try without it
          try {
            final allChildMessages = await firestore
                .collection(MessagingService.teacherInboxCollection)
                .where('childId', isEqualTo: childId)
                .limit(100)
                .get();

            // Filter by timestamp in memory
            for (final doc in allChildMessages.docs) {
              final data = doc.data();
              final createdAt = data['createdAt'];
              DateTime timestamp;
              if (createdAt is Timestamp) {
                timestamp = createdAt.toDate();
              } else if (createdAt is DateTime) {
                timestamp = createdAt;
              } else {
                continue;
              }

              // Check if this message is within 1 hour of the alert timestamp
              if (timestamp.isAfter(
                      alert.timestamp.subtract(const Duration(hours: 1))) &&
                  timestamp.isBefore(
                      alert.timestamp.add(const Duration(hours: 1)))) {
                teacherId = data['teacherId']?.toString();
                break;
              }
            }
          } catch (_) {
            // If query still fails, continue without teacherId
          }
        }
      }

      if (teacherId == null) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not find the conversation. Please try again.')),
        );
        return;
      }

      // Fetch conversation context
      final chatMessages = await messagingService.fetchConversationContext(
        childId: childId,
        teacherId: teacherId,
        aroundTimestamp: alert.timestamp,
        messagesBefore: 3,
        messagesAfter: 3,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show the chat dialog
      if (context.mounted) {
        _showChatDialog(context, alert, chatMessages);
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chat: ${e.toString()}')),
        );
      }
    }
  }

  void _showChatDialog(BuildContext context, ChatSafetyAlert alert,
      List<Map<String, dynamic>> chatMessages) {
    // Find which message is the flagged one
    final flaggedMessageId = alert.sourceMessageId;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SafePlayColors.brightIndigo.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SafePlayColors.brightIndigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chat_bubble_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Full Chat Conversation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${alert.offenderName} ↔ ${alert.targetName}',
                            style: TextStyle(
                              color: SafePlayColors.neutral600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Chat messages
              Expanded(
                child: chatMessages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 48, color: SafePlayColors.neutral400),
                              const SizedBox(height: 16),
                              Text(
                                'No messages found',
                                style: TextStyle(
                                  color: SafePlayColors.neutral600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: chatMessages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final msg = chatMessages[index];
                            final isFromChild =
                                msg['isFromChild'] as bool? ?? false;
                            final messageId = msg['id'] as String? ?? '';
                            final isFlagged = messageId == flaggedMessageId;
                            final sender =
                                msg['sender'] as String? ?? 'Unknown';
                            final message = msg['message'] as String? ?? '';
                            final timestamp =
                                msg['timestamp'] as DateTime? ?? DateTime.now();

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isFlagged
                                    ? SafePlayColors.error.withOpacity(0.1)
                                    : (isFromChild
                                        ? SafePlayColors.brightIndigo
                                            .withOpacity(0.05)
                                        : Colors.grey.withOpacity(0.05)),
                                borderRadius: BorderRadius.circular(12),
                                border: isFlagged
                                    ? Border.all(
                                        color: SafePlayColors.error
                                            .withOpacity(0.3),
                                        width: 2)
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        sender,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isFlagged
                                              ? SafePlayColors.error
                                              : SafePlayColors.neutral900,
                                        ),
                                      ),
                                      if (isFlagged) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: SafePlayColors.error
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'FLAGGED',
                                            style: TextStyle(
                                              color: SafePlayColors.error,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      Text(
                                        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: SafePlayColors.neutral500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: SafePlayColors.neutral700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SafePlayColors.neutral50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: SafePlayColors.neutral600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing messages around the flagged incident from the database.',
                        style: TextStyle(
                          color: SafePlayColors.neutral600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

/// Helper class for browser activity history items (UI only)
class _BrowserActivityItem {
  final IconData icon;
  final Color color;
  final String summary;
  final String category;
  final String timeAgo;

  _BrowserActivityItem({
    required this.icon,
    required this.color,
    required this.summary,
    required this.category,
    required this.timeAgo,
  });
}

class _RecentActivityItem {
  const _RecentActivityItem({
    required this.title,
    required this.subjectLabel,
    required this.subjectColor,
    required this.timeLabel,
    this.completionPercent = 100,
  });

  final String title;
  final String subjectLabel;
  final Color subjectColor;
  final String timeLabel;
  final int completionPercent;
}
