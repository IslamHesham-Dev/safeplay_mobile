import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';
import '../../models/activity.dart';
import '../../models/activity_session_entry.dart';
import '../../models/browser_activity_insight.dart';
import '../../models/browser_control_settings.dart';
import '../../models/chat_safety_alert.dart';
import '../../models/wellbeing_entry.dart';
import '../../models/wellbeing_insight.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../models/game_activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_session_provider.dart';
import '../../providers/browser_activity_provider.dart';
import '../../providers/browser_control_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/messaging_safety_provider.dart';
import '../../providers/wellbeing_provider.dart';
import '../../providers/screen_time_limit_provider.dart';
import '../../constants/wellbeing_moods.dart';
import '../../widgets/parent/child_list_item.dart';
import '../../widgets/parent/parent_settings_menu.dart';
import '../../services/messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/locale_provider.dart';
import '../../localization/app_localizations.dart';

const Map<String, String> _moodLocalizationKeys = {
  'amazing': 'wellbeing.mood.amazing',
  'happy': 'wellbeing.mood.happy',
  'good': 'wellbeing.mood.good',
  'okay': 'wellbeing.mood.okay',
  'sad': 'wellbeing.mood.sad',
  'upset': 'wellbeing.mood.upset',
};

const Map<String, String> _insightTagKeys = {
  'mood_trends': 'wellbeing.tag.mood_trends',
  'recent_week': 'wellbeing.tag.recent_week',
};

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
  WellbeingProvider? _wellbeingProvider;
  ScreenTimeLimitProvider? _screenTimeProvider;
  String? _lastLoadedChildId;
  bool _isSyncingChild = false;
  int _currentNavIndex = 0;
  bool _showAllRecentActivities = false;
  final Map<String, int> _pendingScreenLimitMinutes = {};
  final Map<String, bool> _pendingScreenLimitEnabled = {};

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
      _wellbeingProvider = context.read<WellbeingProvider>();
      _screenTimeProvider = context.read<ScreenTimeLimitProvider>();
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
        _pendingScreenLimitMinutes.clear();
        _pendingScreenLimitEnabled.clear();
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
      final localeCode = context.read<LocaleProvider>().locale.languageCode;
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
            localeCode: localeCode,
          ),
        );
      }
      if (sessionProvider != null) {
        unawaited(sessionProvider.loadSessions(selected.id));
      }
      final wellbeingProvider = _wellbeingProvider;
      if (wellbeingProvider != null) {
        unawaited(wellbeingProvider.loadEntries(selected.id));
        unawaited(
          wellbeingProvider.loadInsights(
            selected.id,
            selected.name,
            localeCode: localeCode,
          ),
        );
      }
      final screenProvider = _screenTimeProvider;
      if (screenProvider != null) {
        unawaited(screenProvider.loadSettings(selected.id));
      }
    } finally {
      _isSyncingChild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(context)),
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
            final wellbeingProvider = context.watch<WellbeingProvider>();
            final screenTimeProvider = context.watch<ScreenTimeLimitProvider>();
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
                  wellbeingProvider,
                  screenTimeProvider,
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
              label: Text(context.loc.t('dashboard.add_child')),
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  String _getAppBarTitle(BuildContext context) {
    final loc = context.loc;
    switch (_currentNavIndex) {
      case 0:
        return loc.t('label.home');
      case 1:
        return loc.t('label.controls');
      case 2:
        return loc.t('label.wellbeing');
      case 3:
        return loc.t('label.messaging');
      default:
        return loc.t('label.home');
    }
  }

  Widget _buildBottomNavBar() {
    final loc = context.loc;
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
              _buildNavItem(0, Icons.home_rounded, loc.t('label.nav_home')),
              _buildNavItem(
                  1, Icons.shield_rounded, loc.t('label.nav_controls')),
              _buildNavItem(
                  2, Icons.favorite_rounded, loc.t('label.nav_wellbeing')),
              _buildNavItem(
                  3, Icons.security_rounded, loc.t('label.nav_alerts')),
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
    WellbeingProvider wellbeingProvider,
    ScreenTimeLimitProvider screenTimeProvider,
  ) {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeScreen(
          authProvider,
          childProvider,
          activitySessionProvider,
          screenTimeProvider,
        );
      case 1:
        return _buildParentalControlsScreen(
          childProvider,
          browserProvider,
          activitySummaryProvider,
        );
      case 2:
        return _buildWellbeingScreen(childProvider, wellbeingProvider);
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
          screenTimeProvider,
        );
    }
  }

  // ============ HOME SCREEN ============
  Widget _buildHomeScreen(
    AuthProvider authProvider,
    ChildProvider childProvider,
    ActivitySessionProvider sessionProvider,
    ScreenTimeLimitProvider screenTimeProvider,
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
        // Screen Time Limit Controls
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: _buildScreenTimeLimitCard(
              context,
              childProvider,
              screenTimeProvider,
            ),
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
    final greeting = _greetingForNow(context);
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
                      ? context.loc.t('dashboard.add_first_child')
                      : context.loc
                          .t('dashboard.managing_children')
                          .replaceFirst('{count}', '$childCount'),
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
    final loc = context.loc;
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
                    context.loc.t('dashboard.no_children'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.loc.t('dashboard.add_first_child'),
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
                loc.t('dashboard.active_child'),
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
                        loc.t('dashboard.selected'),
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
                hintText: loc.t('dashboard.select_child_prompt'),
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
                                    ? context.loc.t('label.wellbeing')
                                    : context.loc.t('label.controls'),
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
    final loc = context.loc;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: loc.t('dashboard.children'),
            value: childCount.toString(),
            icon: Icons.people_alt_rounded,
            color: SafePlayColors.brandTeal500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: loc.t('dashboard.streak'),
            value: activeChild == null ? '-' : '${activeChild.streakDays}d',
            icon: Icons.local_fire_department_rounded,
            color: SafePlayColors.brandOrange500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: loc.t('dashboard.safety'),
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
        .map((entry) => _mapSessionToRecentActivity(context, entry))
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
                    Text(
                      context.loc.t('dashboard.recent_activities'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
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
                            '${selectedChild.name} • ${context.loc.t('dashboard.recent_activities')}',
                            style: TextStyle(
                                color: SafePlayColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    else
                      Text(
                        hasChild
                            ? context.loc.t('dashboard.select_child_limits')
                            : context.loc.t('dashboard.add_first_child'),
                        style: TextStyle(
                            color: SafePlayColors.neutral400, fontSize: 12),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: context.loc.t('action.refresh'),
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
                    _showAllRecentActivities
                        ? context.loc.t('dashboard.view_less')
                        : context.loc.t('dashboard.view_all'),
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
              context.loc.t('dashboard.add_child_to_see_activities'),
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildEmptyStateMessage(
              context.loc.t('dashboard.select_child_limits'),
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
              context.loc
                  .t('dashboard.no_recent_activities')
                  .replaceFirst('{name}', selectedChild.name),
              Icons.hourglass_empty_rounded,
              SafePlayColors.neutral400,
            )
          else ...[
            const SizedBox(height: 8),
            ...recentItems.map(_buildActivityItem),
          ],
          if (error != null && hasSessions)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                context.loc.t('dashboard.cached_insights'),
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
                    context.loc.t('browser.note_privacy'),
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

  // ============ SCREEN TIME LIMIT CARD ============
  Widget _buildScreenTimeLimitCard(
    BuildContext context,
    ChildProvider childProvider,
    ScreenTimeLimitProvider screenTimeProvider,
  ) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    final childId = selectedChild?.id ?? '';
    final settings =
        childId.isNotEmpty ? screenTimeProvider.settingsFor(childId) : null;
    final isLoading =
        childId.isNotEmpty && screenTimeProvider.isLoading(childId);
    final isSaving = childId.isNotEmpty && screenTimeProvider.isSaving(childId);
    final displayEnabled =
        _pendingScreenLimitEnabled[childId] ?? settings?.isEnabled ?? false;
    final displayMinutes = _pendingScreenLimitMinutes[childId] ??
        settings?.dailyLimitMinutes ??
        120;
    final remainingMinutes = settings?.remainingMinutes ?? displayMinutes;
    final limitMinutes = settings?.dailyLimitMinutes ?? displayMinutes;
    final isLocked = settings?.shouldLock ?? false;
    final controlsDisabled = childId.isEmpty || isLoading || isSaving;

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
                      SafePlayColors.brandOrange500.withOpacity(0.15),
                      SafePlayColors.brandOrange500.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: SafePlayColors.brandOrange500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.t('dashboard.screen_time'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (selectedChild != null)
                      Text(
                        '${context.loc.t('dashboard.screen_time_desc')}${selectedChild.name}',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 12,
                        ),
                      )
                    else
                      Text(
                        hasChild
                            ? context.loc.t('dashboard.select_child_limits')
                            : context.loc.t('dashboard.add_first_child'),
                        style: TextStyle(
                          color: SafePlayColors.neutral400,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasChild)
            _buildEmptyStateMessage(
              context.loc.t('dashboard.add_first_child'),
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildEmptyStateMessage(
              context.loc.t('dashboard.select_child_limits'),
              Icons.touch_app_rounded,
              SafePlayColors.brandTeal500,
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.t('dashboard.enable_screen_time'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.loc.t('dashboard.auto_pause'),
                        style: TextStyle(
                          color: SafePlayColors.neutral600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: displayEnabled,
                  onChanged: controlsDisabled
                      ? null
                      : (value) {
                          setState(() {
                            _pendingScreenLimitEnabled[childId] = value;
                            if (!value) {
                              _pendingScreenLimitMinutes.remove(childId);
                            }
                          });
                          if (childId.isNotEmpty) {
                            unawaited(
                              screenTimeProvider
                                  .setLimit(
                                childId,
                                isEnabled: value,
                                dailyLimitMinutes: displayMinutes,
                              )
                                  .whenComplete(() {
                                if (!mounted) return;
                                setState(() {
                                  _pendingScreenLimitEnabled.remove(childId);
                                });
                              }),
                            );
                          }
                        },
                  activeColor: SafePlayColors.brandOrange500,
                ),
              ],
            ),
            if (displayEnabled) ...[
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.loc.t('dashboard.daily_limit_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: SafePlayColors.brandOrange500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTimeLimit(context, displayMinutes),
                          style: TextStyle(
                            color: SafePlayColors.brandOrange500,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: displayMinutes.clamp(30, 240).toDouble(),
                    min: 30,
                    max: 240,
                    divisions: 14,
                    label: _formatTimeLimit(context, displayMinutes),
                    activeColor: SafePlayColors.brandOrange500,
                    inactiveColor: SafePlayColors.neutral300,
                    onChanged: controlsDisabled
                        ? null
                        : (value) {
                            setState(() {
                              _pendingScreenLimitMinutes[childId] =
                                  value.round();
                            });
                          },
                    onChangeEnd: controlsDisabled
                        ? null
                        : (value) {
                            if (childId.isEmpty) return;
                            final minutes = value.round();
                            unawaited(
                              screenTimeProvider
                                  .setLimit(
                                childId,
                                isEnabled: true,
                                dailyLimitMinutes: minutes,
                              )
                                  .whenComplete(() {
                                if (!mounted) return;
                                setState(() {
                                  _pendingScreenLimitMinutes.remove(childId);
                                });
                              }),
                            );
                          },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '30 ${context.loc.t('dashboard.minutes')}',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '4 ${context.loc.t('dashboard.hours')}',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                context.loc.t('dashboard.quick_presets'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTimePresetChip(
                    '1 ${context.loc.t('dashboard.hours')}',
                    60,
                    displayMinutes,
                    controlsDisabled
                        ? null
                        : () => _applyPresetLimit(
                              childId,
                              60,
                              screenTimeProvider,
                              displayEnabled,
                            ),
                  ),
                  _buildTimePresetChip(
                    '1.5 ${context.loc.t('dashboard.hours')}',
                    90,
                    displayMinutes,
                    controlsDisabled
                        ? null
                        : () => _applyPresetLimit(
                              childId,
                              90,
                              screenTimeProvider,
                              displayEnabled,
                            ),
                  ),
                  _buildTimePresetChip(
                    '2 ${context.loc.t('dashboard.hours')}',
                    120,
                    displayMinutes,
                    controlsDisabled
                        ? null
                        : () => _applyPresetLimit(
                              childId,
                              120,
                              screenTimeProvider,
                              displayEnabled,
                            ),
                  ),
                  _buildTimePresetChip(
                    '3 ${context.loc.t('dashboard.hours')}',
                    180,
                    displayMinutes,
                    controlsDisabled
                        ? null
                        : () => _applyPresetLimit(
                              childId,
                              180,
                              screenTimeProvider,
                              displayEnabled,
                            ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SafePlayColors.brandOrange500.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SafePlayColors.brandOrange500.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: SafePlayColors.brandOrange500,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.loc.t('dashboard.limit_reached'),
                        style: TextStyle(
                          color: SafePlayColors.neutral700,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
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
                      Icons.schedule_rounded,
                      color: SafePlayColors.neutral600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isLocked
                            ? '${selectedChild.name} ${context.loc.t('dashboard.limit_reached')}'
                            : context.loc
                                .t('dashboard.remaining_time_text')
                                .replaceFirst(
                                  '{time}',
                                  _formatMinutes(context, remainingMinutes),
                                )
                                .replaceFirst(
                                  '{total}',
                                  _formatMinutes(context, limitMinutes),
                                ),
                        style: TextStyle(
                          color: SafePlayColors.neutral700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controlsDisabled
                        ? null
                        : () {
                            if (childId.isEmpty) return;
                            unawaited(
                              screenTimeProvider.unlockLimit(childId),
                            );
                          },
                    icon: const Icon(Icons.lock_open_rounded),
                    label: Text(context.loc.t('dashboard.unlock_today')),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTimePresetChip(
    String label,
    int minutes,
    int currentMinutes,
    VoidCallback? onTap,
  ) {
    final isSelected = minutes == currentMinutes;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? SafePlayColors.brandOrange500
              : SafePlayColors.neutral100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? SafePlayColors.brandOrange500
                : SafePlayColors.neutral300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : SafePlayColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _applyPresetLimit(
    String childId,
    int minutes,
    ScreenTimeLimitProvider screenTimeProvider,
    bool isEnabled,
  ) {
    setState(() {
      _pendingScreenLimitMinutes[childId] = minutes;
    });
    if (!isEnabled || childId.isEmpty) return;
    unawaited(
      screenTimeProvider
          .setLimit(
        childId,
        isEnabled: true,
        dailyLimitMinutes: minutes,
      )
          .whenComplete(() {
        if (!mounted) return;
        setState(() {
          _pendingScreenLimitMinutes.remove(childId);
        });
      }),
    );
  }

  String _formatMinutes(BuildContext context, int minutes) {
    final loc = context.loc;
    if (minutes < 60) return '$minutes ${loc.t('dashboard.minutes')}';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours ${loc.t('dashboard.hours')}';
    }
    return '$hours ${loc.t('dashboard.hours')} $mins ${loc.t('dashboard.minutes')}';
  }

  String _formatTimeLimit(BuildContext context, int minutes) {
    final loc = context.loc;
    if (minutes < 60) {
      return '$minutes ${loc.t('dashboard.minutes')}';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours ${loc.t('dashboard.hours')}';
    }
    return '$hours ${loc.t('dashboard.hours')} $mins ${loc.t('dashboard.minutes')}';
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
    BuildContext context,
    ActivitySessionEntry entry,
  ) {
    Activity? activity;
    final activities = _activityProvider?.activities;
    if (activities != null) {
      for (final a in activities) {
        if (a.id == entry.activityId) {
          activity = a;
          break;
        }
      }
    }
    final subjectEnum = _mapRawSubjectToEnum(entry.subject);
    final subjectLabel =
        subjectEnum?.displayName ?? _formatSubjectLabel(context, entry.subject);
    final translatedTitle = _translateActivityTitle(context, activity, entry);
    return _RecentActivityItem(
      title: translatedTitle,
      subjectLabel: subjectLabel,
      subjectColor: _subjectColor(subjectEnum),
      timeLabel: _formatDurationLabel(context, entry.durationMinutes),
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

  String _formatDurationLabel(BuildContext context, int? minutes) {
    if (minutes == null || minutes <= 0) {
      return context.loc.t('activity.teacher_assigned');
    }
    if (minutes == 1) {
      return context.loc.t('activity.single_min_session');
    }
    return context.loc
        .t('activity.minutes_session')
        .replaceFirst('{minutes}', minutes.toString());
  }

  String _formatSubjectLabel(BuildContext context, String? raw) {
    final fallback = context.loc.t('activity.learning');
    if (raw == null || raw.isEmpty) return fallback;
    final normalized = raw.replaceAll(RegExp(r'[_\\-]+'), ' ').trim();
    if (normalized.isEmpty) return fallback;
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _translateGameTitle(BuildContext context, String rawTitle) {
        var normalized = rawTitle.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r"[\u2019\u00B4`']+"), "'");
    normalized = normalized.replaceAll(RegExp(r"[!?.:]+$"), '');
    normalized = normalized.replaceAll(RegExp(r"[^\p{L}\p{N}' ]+", unicode: true), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    final slugKey = 'game.' + normalized.replaceAll(' ', '_').replaceAll('-', '_');
    final slugTranslation = context.loc.t(slugKey);
    if (slugTranslation != slugKey) {
      return slugTranslation;
    }

    final gameTranslations = {
      'letter sound adventure': context.loc.t('game.letter_sound_adventure'),
      'math maze': context.loc.t('game.math_maze'),
      'science quiz': context.loc.t('game.science_quiz'),
      'reading quest': context.loc.t('game.reading_quest'),
      'shapes sorter': context.loc.t('game.shapes_sorter'),
      'number grid race': context.loc.t('game.number_grid_race'),
      "koala counter's adventure":
          context.loc.t('game.koala_counter_adventure'),
      'koala counter adventure': context.loc.t('game.koala_counter_adventure'),
      'ordinal order challenge': context.loc.t('game.ordinal_order_challenge'),
      'pattern builder': context.loc.t('game.pattern_builder'),
      'bubblepop grammar': context.loc.t('game.bubblepop_grammar'),
      'bubble pop grammar': context.loc.t('game.bubblepop_grammar'),
      'seashell quiz': context.loc.t('game.seashell_quiz'),
      'fish tank quiz': context.loc.t('game.fish_tank_quiz'),
      'add equations': context.loc.t('game.add_equations'),
      'fraction navigator': context.loc.t('game.fraction_navigator'),
      'inverse operation chain': context.loc.t('game.inverse_operation_chain'),
      'data visualization lab': context.loc.t('game.data_visualization_lab'),
      'cartesian grid explorer': context.loc.t('game.cartesian_grid_explorer'),
      'memory match': context.loc.t('game.memory_match'),
      'word builder': context.loc.t('game.word_builder'),
      'story sequencer': context.loc.t('game.story_sequencer'),
      'math adventures': context.loc.t('game.math_adventures'),
      'reading adventures': context.loc.t('game.reading_adventures'),
      'science adventures': context.loc.t('game.science_adventures'),
      'number hunt': context.loc.t('game.number_hunt'),
      'koala jumps': context.loc.t('game.koala_jumps'),
      'pattern wizard': context.loc.t('game.pattern_wizard'),
      'equality explorer basics':
          context.loc.t('game.equality_explorer_basics'),
      'area model introduction': context.loc.t('game.area_model_introduction'),
      'mean share and balance': context.loc.t('game.mean_share_balance'),
      'balancing act': context.loc.t('game.balancing_act'),
      'states of matter simulation':
          context.loc.t('game.states_of_matter_simulation'),
      'balloons static electricity':
          context.loc.t('game.balloons_static_electricity'),
      'exploring density': context.loc.t('game.exploring_density'),
      'food chains': context.loc.t('game.food_chains'),
      'microorganisms': context.loc.t('game.microorganisms'),
      'human body health growth':
          context.loc.t('game.human_body_health_growth'),
      'teeth eating': context.loc.t('game.teeth_eating'),
      'plants animals': context.loc.t('game.plants_animals'),
      'keeping healthy': context.loc.t('game.keeping_healthy'),
      'how plants grow': context.loc.t('game.how_plants_grow'),
      'skeleton bones': context.loc.t('game.skeleton_bones'),
      'plant animal differences':
          context.loc.t('game.plant_animal_differences'),
      'life cycle of a plant': context.loc.t('game.life_cycle_plant'),
      'electricity circuits': context.loc.t('game.electricity_circuits'),
      'forces in action': context.loc.t('game.forces_in_action'),
      'how we see': context.loc.t('game.how_we_see'),
      'earth sun moon': context.loc.t('game.earth_sun_moon'),
      'circuits conductors': context.loc.t('game.circuits_conductors'),
      'magnets springs': context.loc.t('game.magnets_springs'),
      'sun light shadows': context.loc.t('game.sun_light_shadows'),
      'changing sounds': context.loc.t('game.changing_sounds'),
      'friction': context.loc.t('game.friction'),
      'light dark': context.loc.t('game.light_dark'),
      'changing state of water': context.loc.t('game.changing_state_water'),
      'reversible changes': context.loc.t('game.reversible_changes'),
      'properties of materials': context.loc.t('game.properties_materials'),
      'rocks minerals soils': context.loc.t('game.rocks_minerals_soils'),
      'melting points': context.loc.t('game.melting_points'),
      'solids liquids and gases': context.loc.t('game.solids_liquids_gases'),
      'heat transfer': context.loc.t('game.heat_transfer'),
      'addition game for kids': context.loc.t('game.addition_kids'),
      'subtraction game for kids': context.loc.t('game.subtraction_kids'),
      'multiplication game for kids': context.loc.t('game.multiplication_kids'),
      'division game for kids': context.loc.t('game.division_kids'),
      'shapes game for kids': context.loc.t('game.shapes_kids'),
      'angles game for kids': context.loc.t('game.angles_kids'),
      'measurements game for kids': context.loc.t('game.measurements_kids'),
      'grids coordinates game': context.loc.t('game.grids_coordinates_kids'),
      'transformation game for kids': context.loc.t('game.transformation_kids'),
      'fractions game for kids': context.loc.t('game.fractions_kids'),
      'decimals game for kids': context.loc.t('game.decimals_kids'),
      'number patterns game': context.loc.t('game.number_patterns_kids'),
      'place values game for kids': context.loc.t('game.place_values_kids'),
      'calculator game for kids': context.loc.t('game.calculator_kids'),
      'money game for kids': context.loc.t('game.money_kids'),
      'problem solving game for kids':
          context.loc.t('game.problem_solving_kids'),
      'probability game for kids': context.loc.t('game.probability_kids'),
      'percentages game for kids': context.loc.t('game.percentages_kids'),
      'mean median mode game': context.loc.t('game.mean_median_mode_kids'),
      'frequency tables game': context.loc.t('game.frequency_tables_kids'),
      'map routes directions game':
          context.loc.t('game.map_routes_directions_kids'),
      'poetry game for kids': context.loc.t('game.poetry_kids'),
      'non fiction game for kids': context.loc.t('game.non_fiction_kids'),
      'dictionary game for kids': context.loc.t('game.dictionary_kids'),
      'punctuation games for kids': context.loc.t('game.punctuation_kids'),
      'conjunction game for kids': context.loc.t('game.conjunction_kids'),
      'prefix suffix game': context.loc.t('game.prefix_suffix_kids'),
      'verb noun adjective game':
          context.loc.t('game.verb_noun_adjective_kids'),
      'debate game for kids': context.loc.t('game.debate_kids'),
      'newspaper game for kids': context.loc.t('game.newspaper_kids'),
      'advertising game': context.loc.t('game.advertising'),
      'learn how to write a letter': context.loc.t('game.write_letter'),
      'story writing game for kids': context.loc.t('game.story_writing_kids'),
      'instructions game for kids': context.loc.t('game.instructions_kids'),
      'fun crossword game for kids': context.loc.t('game.fun_crossword_kids'),
      'letter matching game for kids':
          context.loc.t('game.letter_matching_kids'),
      'spiderman spelling game': context.loc.t('game.spiderman_spelling'),
      'alphabet game for kids': context.loc.t('game.alphabet_kids'),
      'easy spelling game for kids': context.loc.t('game.easy_spelling_kids'),
      'word guessing puzzle game': context.loc.t('game.word_guessing_puzzle'),
    };
    if (gameTranslations.containsKey(normalized)) {
      return gameTranslations[normalized]!;
    }
    for (final entry in gameTranslations.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return rawTitle;
  }

  String _translateActivityTitle(
    BuildContext context,
    Activity? activity,
    ActivitySessionEntry entry,
  ) {
    // Prefer game type translation when available
    if (activity is GameActivity) {
      final key = _gameTypeLocalizationKey(activity.gameConfig.gameType);
      if (key != null) return context.loc.t(key);
    }
    // Fallback: translate the stored activity title or the session title
    final sourceTitle = activity?.title ?? entry.title;
    return _translateGameTitle(context, sourceTitle);
  }

  String? _gameTypeLocalizationKey(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
        return 'game.number_grid_race';
      case GameType.koalaCounterAdventure:
        return 'game.koala_counter_adventure';
      case GameType.ordinalDragOrder:
        return 'game.ordinal_order_challenge';
      case GameType.patternBuilder:
        return 'game.pattern_builder';
      case GameType.bubblePopGrammar:
        return 'game.bubblepop_grammar';
      case GameType.seashellQuiz:
        return 'game.seashell_quiz';
      case GameType.fishTankQuiz:
        return 'game.fish_tank_quiz';
      case GameType.addEquations:
        return 'game.add_equations';
      case GameType.fractionNavigator:
        return 'game.fraction_navigator';
      case GameType.inverseOperationChain:
        return 'game.inverse_operation_chain';
      case GameType.dataVisualization:
        return 'game.data_visualization_lab';
      case GameType.cartesianGrid:
        return 'game.cartesian_grid_explorer';
      case GameType.memoryMatch:
        return 'game.memory_match';
      case GameType.wordBuilder:
        return 'game.word_builder';
      case GameType.storySequencer:
        return 'game.story_sequencer';
    }
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
                                context.loc
                                    .t('browser.child_browser_title')
                                    .replaceFirst('{name}', selectedChild.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.loc.t('browser.cloud_rules'),
                                style: const TextStyle(
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
                          label: Text(context.loc.t('action.refresh')),
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
                              ? context.loc.t('browser.safe_search_on')
                              : context.loc.t('browser.safe_search_off'),
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
                              ? context.loc.t('browser.social_blocked')
                              : context.loc.t('browser.social_allowed'),
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
                              ? context.loc.t('browser.gambling_blocked')
                              : context.loc.t('browser.gambling_allowed'),
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
                              ? context.loc.t('browser.violence_blocked')
                              : context.loc.t('browser.violence_allowed'),
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
                                ? context.loc.t('browser.syncing')
                                : _formatSyncDescription(
                                    context, currentSettings.updatedAt),
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
                            context.loc.t('browser.using_defaults'),
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
                title: context.loc.t('browser.ai_safe_search'),
                subtitle: context.loc.t('browser.ai_safe_search_desc'),
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
                        Text(
                          context.loc.t('browser.content_filters'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFilterToggle(
                      context.loc.t('browser.block_social'),
                      currentSettings.blockSocialMedia,
                      controlsDisabled
                          ? null
                          : (value) =>
                              browserProvider.setSocialFilter(childId, value),
                      description: context.loc.t('browser.block_social_desc'),
                      icon: Icons.groups_2_rounded,
                    ),
                    _buildFilterToggle(
                      context.loc.t('browser.block_gambling'),
                      currentSettings.blockGambling,
                      controlsDisabled
                          ? null
                          : (value) =>
                              browserProvider.setGamblingFilter(childId, value),
                      description:
                          context.loc.t('browser.block_gambling_desc'),
                      icon: Icons.casino_rounded,
                    ),
                    _buildFilterToggle(
                      context.loc.t('browser.block_violence'),
                      currentSettings.blockViolence,
                      controlsDisabled
                          ? null
                          : (value) =>
                              browserProvider.setViolenceFilter(childId, value),
                      description:
                          context.loc.t('browser.block_violence_desc'),
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
                        Expanded(
                          child: Text(
                            context.loc.t('browser.blocked_keywords'),
                            style: const TextStyle(
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
                        context.loc.t('browser.keyword_empty_note'),
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
                        Expanded(
                          child: Text(
                            context.loc.t('browser.allowed_sites'),
                            style: const TextStyle(
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
                        context.loc.t('browser.allowed_empty_note'),
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
    return Center(
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
              textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildBrowserHistorySection(
    ChildProfile? child,
    BrowserActivityProvider activityProvider,
  ) {
    if (child == null) return const SizedBox.shrink();

    final loc = context.loc;
    final localeCode = context.read<LocaleProvider>().locale.languageCode;
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
              Expanded(
                child: Text(
                  loc.t('label.browser_activity'),
                  style: const TextStyle(
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
                          localeCode: localeCode,
                        ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc
                .t('browser.summary_hint')
                .replaceFirst('{name}', child.name),
            style: TextStyle(
              color: SafePlayColors.neutral600,
              fontSize: 13,
              height: 1.35,
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
                    loc.t('browser.error_title'),
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
                loc.t('browser.empty'),
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
                    loc.t('browser.summary_hint'),
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

  _WellbeingInsightItem _mapWellbeingInsight(
    BuildContext context,
    WellbeingInsight insight,
  ) {
    final tone = insight.tone.toLowerCase();
    Color color = SafePlayColors.brandTeal500;
    IconData icon = Icons.favorite_rounded;

    if (tone.contains('caution')) {
      color = SafePlayColors.warning;
      icon = Icons.flag_rounded;
    } else if (tone.contains('positive')) {
      color = SafePlayColors.success;
      icon = Icons.emoji_emotions_rounded;
    } else if (tone.contains('support')) {
      color = SafePlayColors.brandTeal500;
      icon = Icons.volunteer_activism_rounded;
    } else {
      color = SafePlayColors.neutral600;
      icon = Icons.insights_rounded;
    }

    return _WellbeingInsightItem(
      icon: icon,
      color: color,
      summary: insight.summary,
      category: _formatInsightTag(context, insight.category),
      timeframe: _formatInsightTag(
        context,
        insight.timeframe.isEmpty ? 'recent_checkins' : insight.timeframe,
        isTimeframe: true,
      ),
    );
  }

  Widget _buildWellbeingInsightItem(_WellbeingInsightItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.summary,
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
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          color: item.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeframe,
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
            Text(context.loc.t('browser.dialog_add_blocked_title')),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.loc.t('browser.dialog_add_blocked_hint'),
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
            child: Text(context.loc.t('action.cancel'),
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
            child: Text(
              context.loc.t('browser.add_blocked_keyword'),
              style: const TextStyle(color: Colors.white),
            ),
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
            Text(context.loc.t('browser.dialog_add_allowed_title')),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.loc.t('browser.dialog_add_allowed_hint'),
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
            child: Text(context.loc.t('action.cancel'),
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
            child: Text(
              context.loc.t('browser.add_allowed_site'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ============ WELLBEING SCREEN ============
  Widget _buildWellbeingScreen(
    ChildProvider childProvider,
    WellbeingProvider wellbeingProvider,
  ) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    final loc = context.loc;

    Future<void> refresh() async {
      if (selectedChild != null) {
        await wellbeingProvider.loadEntries(selectedChild.id);
        final localeCode = context.read<LocaleProvider>().locale.languageCode;
        await wellbeingProvider.loadInsights(
          selectedChild.id,
          selectedChild.name,
          localeCode: localeCode,
        );
      }
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildSelectorCard(context, childProvider),
            const SizedBox(height: 20),
            if (!hasChild)
              _buildFullEmptyState(
                loc.t('wellbeing.add_child_title'),
                loc.t('wellbeing.add_child_subtitle'),
                Icons.child_care_rounded,
                SafePlayColors.brandOrange500,
              )
            else if (selectedChild == null)
              _buildFullEmptyState(
                loc.t('wellbeing.select_child_title'),
                loc.t('wellbeing.select_child_subtitle'),
                Icons.touch_app_rounded,
                SafePlayColors.brandTeal500,
              )
            else ...[
              Builder(
                builder: (context) {
                  final entries =
                      wellbeingProvider.entriesForChild(selectedChild.id);
                  final isLoading =
                      wellbeingProvider.isLoading(selectedChild.id);
                  final hasEntries = entries.isNotEmpty;
                  final averageScore =
                      wellbeingProvider.averageScore(selectedChild.id);
                  final moodDefinition = hasEntries
                      ? moodDefinitionForScore(averageScore)
                      : kWellbeingMoods.last;
                  final latestEntry = hasEntries ? entries.first : null;
                  final localeCode =
                      context.read<LocaleProvider>().locale.languageCode;
                  final weeklySummary =
                      _generateWeeklyMoodSummary(entries, localeCode);
                  final recentEntries = wellbeingProvider.recentEntries(
                    selectedChild.id,
                    limit: 5,
                  );

                  if (!hasEntries && !isLoading) {
                    final firstName = selectedChild.name.split(' ').first;
                    return _buildFullEmptyState(
                      loc.t('wellbeing.no_checkins_title'),
                      loc
                          .t('wellbeing.no_checkins_message')
                          .replaceFirst('{name}', firstName),
                      Icons.favorite_outline_rounded,
                      SafePlayColors.juniorPink,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWellbeingHeader(
                        context,
                        selectedChild,
                        latestEntry,
                      ),
                      const SizedBox(height: 20),
                      _buildWellbeingOverviewCard(
                        context,
                        moodDefinition,
                        averageScore,
                        latestEntry,
                        isLoading,
                        hasEntries,
                      ),
                      const SizedBox(height: 20),
                      _buildWeeklyMoodCard(
                        context,
                        weeklySummary,
                        hasEntries,
                        isLoading,
                      ),
                      const SizedBox(height: 20),
                      _buildRecentCheckinsCard(
                        context,
                        recentEntries,
                        isLoading,
                      ),
                      const SizedBox(height: 20),
                      _buildWellbeingAiReportCard(
                        selectedChild,
                        wellbeingProvider,
                      ),
                      const SizedBox(height: 20),
                      _buildWellbeingPrivacyNote(context),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingHeader(
    BuildContext context,
    ChildProfile child,
    WellbeingEntry? latestEntry,
  ) {
    final loc = context.loc;
    final localeCode = context.read<LocaleProvider>().locale.languageCode;
    final timestampLabel = latestEntry == null
        ? loc.t('wellbeing.no_checkins_title')
        : loc
            .t('wellbeing.last_shared')
            .replaceFirst(
              '{timestamp}',
              DateFormat('MMM d \u2022 h:mm a', localeCode)
                  .format(latestEntry.timestamp),
            );
    final title =
        loc.t('wellbeing.child_header').replaceFirst('{name}', child.name);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SafePlayColors.juniorPink,
            SafePlayColors.juniorPurple,
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
            child: const Icon(
              Icons.favorite_rounded,
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timestampLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingOverviewCard(
    BuildContext context,
    WellbeingMoodDefinition moodDefinition,
    double averageScore,
    WellbeingEntry? latestEntry,
    bool isLoading,
    bool hasEntries,
  ) {
    final loc = context.loc;
    final note = latestEntry?.notes?.trim();
    final hasScore = hasEntries && !isLoading;
    final clampedScore = averageScore.clamp(0, 100).toStringAsFixed(0);
    final scoreText = hasScore ? '$clampedScore%' : '--';
    final localizedMoodLabel =
        _localizedMoodLabel(context, moodDefinition.label);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            moodDefinition.color,
            moodDefinition.color.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: moodDefinition.color.withOpacity(0.25),
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
            child: Text(
              moodDefinition.emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('wellbeing.overview'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizedMoodLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    loc
                        .t('wellbeing.latest_note')
                        .replaceFirst('{note}', note),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
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
                  scoreText,
                  style: TextStyle(
                    color: moodDefinition.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  loc.t('wellbeing.score_label'),
                  style: TextStyle(
                    color: moodDefinition.color.withOpacity(0.7),
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

  Widget _buildWellbeingAiReportCard(
    ChildProfile child,
    WellbeingProvider wellbeingProvider,
  ) {
    final loc = context.loc;
    final localeCode = context.read<LocaleProvider>().locale.languageCode;
    final insights = wellbeingProvider.insightsForChild(child.id);
    final isLoading = wellbeingProvider.isInsightsLoading(child.id);
    final error = wellbeingProvider.insightErrorFor(child.id);
    final items =
        insights.map((insight) => _mapWellbeingInsight(context, insight)).toList();

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
                  Icons.psychology_rounded,
                  color: SafePlayColors.brandTeal500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.t('label.ai_wellbeing'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: isLoading
                    ? null
                    : () => unawaited(
                          wellbeingProvider.loadInsights(
                            child.id,
                            child.name,
                            localeCode: localeCode,
                          ),
                        ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.t('browser.summary_hint'),
            style: TextStyle(
              color: SafePlayColors.neutral600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SafePlayColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SafePlayColors.error.withOpacity(0.2),
                ),
              ),
              child: Text(
                'Could not refresh the AI report: $error',
                style: TextStyle(
                  color: SafePlayColors.error.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            )
          else if (items.isEmpty)
            Text(
              '${child.name} has not completed enough wellbeing check-ins for an AI summary yet.',
              style: TextStyle(
                color: SafePlayColors.neutral600,
                height: 1.4,
              ),
            )
          else
            ...items.map(_buildWellbeingInsightItem),
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
                const Icon(
                  Icons.shield_moon_rounded,
                  color: SafePlayColors.neutral600,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.t('label.privacy_note'),
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

  Widget _buildWeeklyMoodCard(
    BuildContext context,
    List<_MoodDaySummary> summary,
    bool hasEntries,
    bool isLoading,
  ) {
    final loc = context.loc;
    final hasSignals = summary.any((day) => day.emoji != '-');

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
                  color: SafePlayColors.juniorPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: SafePlayColors.juniorPink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                loc.t('label.this_weeks_mood'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading && !hasEntries)
            const Center(child: CircularProgressIndicator())
          else if (!hasSignals)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(loc.t('wellbeing.no_mood_week')),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: summary
                  .map(
                    (day) => _buildMoodDay(
                      day.label,
                      day.emoji,
                      day.color,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentCheckinsCard(
    BuildContext context,
    List<WellbeingEntry> entries,
    bool isLoading,
  ) {
    final loc = context.loc;
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
                  color: SafePlayColors.brightIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: SafePlayColors.brightIndigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                loc.t('wellbeing.recent_checkins'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading && entries.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (entries.isEmpty)
            Text(loc.t('wellbeing.no_recent_checkins'))
          else
            ...entries.map(
              (entry) => _buildCheckinItem(
                _formatCheckinDate(context, entry.timestamp),
                entry.moodEmoji,
                _localizedMoodLabel(context, entry.moodLabel),
                entry.notes?.isNotEmpty == true
                    ? entry.notes!
                    : loc.t('wellbeing.no_note_added'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWellbeingPrivacyNote(BuildContext context) {
    return Container(
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
          const Icon(
            Icons.info_outline_rounded,
            color: SafePlayColors.neutral600,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.loc.t('wellbeing.note_privacy'),
              style: TextStyle(
                color: SafePlayColors.neutral600,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MoodDaySummary> _generateWeeklyMoodSummary(
      List<WellbeingEntry> entries, String localeCode) {
    final now = DateTime.now();
    final Map<String, WellbeingEntry> latestPerDay = {};
    for (final entry in entries) {
      final key = _dayKey(entry.timestamp);
      latestPerDay.putIfAbsent(key, () => entry);
    }

    final formatter = DateFormat('EEE', localeCode);
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final key = _dayKey(date);
      final entry = latestPerDay[key];
      if (entry == null) {
        return _MoodDaySummary(
          formatter.format(date),
          '—',
          SafePlayColors.neutral300,
        );
      }
      final moodDefinition = moodDefinitionForLabel(entry.moodLabel);
      return _MoodDaySummary(
        formatter.format(date),
        moodDefinition.emoji,
        moodDefinition.color,
      );
    });
  }

  String _dayKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

// ============ MESSAGING ALERTS SCREEN ============

  Widget _buildMessagingAlertsScreen(
    AuthProvider authProvider,
    ChildProvider childProvider,
    MessagingSafetyProvider safetyProvider,
  ) {
    final parent = authProvider.currentUser;
    final loc = context.loc;

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
              loc.t('messaging.add_child_title'),
              loc.t('messaging.add_child_subtitle'),
              Icons.child_care_rounded,
              SafePlayColors.brandOrange500,
            )
          else if (selectedChild == null)
            _buildFullEmptyState(
              loc.t('messaging.select_child_title'),
              loc.t('messaging.select_child_subtitle'),
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
                          loc
                              .t('messaging.child_header')
                              .replaceFirst('{name}', selectedChild.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc
                              .t('messaging.alerts_summary')
                              .replaceFirst('{total}', '${alerts.length}')
                              .replaceFirst('{unreviewed}', '$unreviewedCount'),
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
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          loc.t('messaging.ai_guard'),
                          style: const TextStyle(
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
                            Text(
                              loc.t('messaging.ai_safety_guard'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc
                                  .t('messaging.ai_monitoring')
                                  .replaceFirst('{name}', selectedChild.name),
                              style: TextStyle(
                                color: SafePlayColors.neutral500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: loc.t('messaging.run_scan'),
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
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              loc.t('messaging.active'),
                              style: const TextStyle(
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
                          label: loc.t('messaging.model_label'),
                          value: 'DeepSeek V3.1',
                          color: SafePlayColors.brightIndigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.access_time,
                          label: loc.t('messaging.last_scan'),
                          value: lastScan != null
                              ? _formatTime(lastScan)
                              : (isLoading
                                  ? loc.t('messaging.scanning')
                                  : loc.t('messaging.pending')),
                          color: SafePlayColors.brandOrange500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.warning_amber_rounded,
                          label: loc.t('messaging.needs_review'),
                          value: loc
                              .t('messaging.alert_count')
                              .replaceFirst('{count}', '$unreviewedCount'),
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
                      Text(
                        loc.t('messaging.monitor_title'),
                        style: const TextStyle(
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
                          context,
                          loc.t('messaging.profanity'),
                          Icons.report_rounded,
                          SafePlayColors.error,
                          count: profanityCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMonitorItem(
                          context,
                          loc.t('messaging.bullying'),
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
                          context,
                          loc.t('messaging.sensitive_topics'),
                          Icons.psychology_rounded,
                          SafePlayColors.juniorPurple,
                          count: sensitiveCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMonitorItem(
                          context,
                          loc.t('messaging.stranger_danger'),
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
                      Expanded(
                        child: Text(
                          loc.t('messaging.safety_alerts'),
                          style: const TextStyle(
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
                          loc
                              .t('messaging.total_alerts')
                              .replaceFirst('{count}', '${alerts.length}'),
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
                                Text(
                                  loc.t('messaging.all_clear_title'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc
                                      .t('messaging.all_clear_body')
                                      .replaceFirst(
                                          '{name}', selectedChild.name),
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
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    int count = 0,
  }) {
    final loc = context.loc;
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
                      ? loc.t('messaging.no_recent_alerts')
                      : loc
                          .t('messaging.recent_alerts_count')
                          .replaceFirst('{count}', '$count'),
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

  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required Color backgroundColor,
  }) {
    final resolvedColor = isActive ? activeColor : inactiveColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: resolvedColor.withOpacity(isActive ? 0.6 : 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: resolvedColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: resolvedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

String _formatSyncDescription(BuildContext context, DateTime? timestamp) {
  final loc = context.loc;
  String withCount(String key, int count) {
    final template = loc.t(key);
    return template.contains('{count}')
        ? template.replaceFirst('{count}', '$count')
        : template;
  }

  if (timestamp == null) {
    return loc.t('browser.sync_never');
  }
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return loc.t('browser.sync_just_now');
  if (diff.inHours < 1) {
    final minutes = diff.inMinutes;
    final key = minutes == 1
        ? 'browser.sync_minutes_single'
        : 'browser.sync_minutes_plural';
    return withCount(key, minutes);
  }
  if (diff.inDays < 1) {
    final hours = diff.inHours;
    final key =
        hours == 1 ? 'browser.sync_hours_single' : 'browser.sync_hours_plural';
    return withCount(key, hours);
  }
  final days = diff.inDays;
  final key =
      days == 1 ? 'browser.sync_days_single' : 'browser.sync_days_plural';
  return withCount(key, days);
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

  Widget _buildMoodDay(String day, String emoji, Color color) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: SafePlayColors.neutral600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
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

  String _formatCheckinDate(BuildContext context, DateTime timestamp) {
    final localeCode = context.read<LocaleProvider>().locale.languageCode;
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    final timeLabel = DateFormat('h:mm a', localeCode).format(timestamp);
    if (diff.inDays == 0) {
      return timeLabel;
    }
    if (diff.inDays == 1) {
      return context.loc
          .t('wellbeing.checkin_yesterday')
          .replaceFirst('{time}', timeLabel);
    }
    final dayLabel = DateFormat('EEE', localeCode).format(timestamp);
    return context.loc
        .t('wellbeing.checkin_day_time')
        .replaceFirst('{day}', dayLabel)
        .replaceFirst('{time}', timeLabel);
  }

  String _localizedMoodLabel(BuildContext context, String label) {
    final key = _moodLocalizationKeys[label.trim().toLowerCase()];
    if (key == null) return label;
    final translated = context.loc.t(key);
    return translated.isNotEmpty ? translated : label;
  }

  String _formatInsightTag(
    BuildContext context,
    String raw, {
    bool isTimeframe = false,
  }) {
    final loc = context.loc;
    final normalized = raw.trim().toLowerCase().replaceAll('-', '_');
    final mappedKey = _insightTagKeys[normalized];
    if (mappedKey != null) {
      final translated = loc.t(mappedKey);
      if (translated.isNotEmpty && translated != mappedKey) return translated;
    }
    if (isTimeframe && normalized == 'recent_checkins') {
      return loc.t('wellbeing.recent_checkins');
    }
    final friendly = normalized
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
    return friendly.isEmpty ? raw : friendly;
  }

  String _localizedCategoryLabel(
      BuildContext context, SafetyCategory category) {
    final loc = context.loc;
    switch (category) {
      case SafetyCategory.profanity:
        return loc.t('messaging.profanity');
      case SafetyCategory.bullying:
        return loc.t('messaging.bullying');
      case SafetyCategory.sensitiveTopics:
        return loc.t('messaging.sensitive_topics');
      case SafetyCategory.strangerDanger:
        return loc.t('messaging.stranger_danger');
      case SafetyCategory.other:
        return loc.t('messaging.safety_alerts');
    }
  }

  String _localizedAlertTitle(
    BuildContext context,
    ChatSafetyAlert alert,
    String categoryLabel, {
    required bool isArabic,
  }) {
    final loc = context.loc;
    final key = switch (alert.category) {
      SafetyCategory.profanity => 'messaging.title.profanity',
      SafetyCategory.bullying => 'messaging.title.bullying',
      SafetyCategory.sensitiveTopics => 'messaging.title.sensitive',
      SafetyCategory.strangerDanger => 'messaging.title.stranger',
      SafetyCategory.other => 'messaging.title.other',
    };
    final localized = loc.t(key);
    if (isArabic) return localized;
    return alert.title ?? '$categoryLabel ${loc.t('messaging.detected')}';
  }

  String _localizedAlertContext(
    BuildContext context,
    ChatSafetyAlert alert, {
    required bool isArabic,
  }) {
    if (!isArabic) return alert.context;
    final loc = context.loc;
    final key = switch (alert.category) {
      SafetyCategory.profanity => 'messaging.desc.profanity',
      SafetyCategory.bullying => 'messaging.desc.bullying',
      SafetyCategory.sensitiveTopics => 'messaging.desc.sensitive',
      SafetyCategory.strangerDanger => 'messaging.desc.stranger',
      SafetyCategory.other => 'messaging.desc.other',
    };
    return loc.t(key);
  }

  String _localizedDirectionLabel(BuildContext context, String rawLabel) {
    final loc = context.loc;
    final normalized = rawLabel.toLowerCase();
    if (normalized.contains('teacher') && normalized.contains('child')) {
      final teacherFirst = normalized.indexOf('teacher') <
          normalized.indexOf('child');
      return loc.t('messaging.full_chat_between')
          .replaceFirst(
              '{from}',
              teacherFirst
                  ? loc.t('messaging.role.teacher')
                  : loc.t('messaging.role.child'))
          .replaceFirst(
              '{to}',
              teacherFirst
                  ? loc.t('messaging.role.child')
                  : loc.t('messaging.role.teacher'));
    }
    return rawLabel;
  }

  Widget _buildDetailedAlertItem(
    ChatSafetyAlert alert,
    String childId,
    MessagingSafetyProvider safetyProvider,
  ) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final isArabic = localeCode == 'ar';
    final severity = alert.severity.toLowerCase();
    final reviewed = alert.reviewed;
    final time = alert.timestamp;
    final aiConfidence = alert.confidencePercent;
    final loc = context.loc;
    final categoryLabel = _localizedCategoryLabel(context, alert.category);

    Color severityColor;
    IconData severityIcon;
    String severityLabel;
    switch (severity) {
      case 'high':
        severityColor = SafePlayColors.error;
        severityIcon = Icons.error_rounded;
        severityLabel = loc.t('messaging.severity_high');
        break;
      case 'medium':
        severityColor = SafePlayColors.warning;
        severityIcon = Icons.warning_rounded;
        severityLabel = loc.t('messaging.severity_medium');
        break;
      default:
        severityColor = SafePlayColors.brandOrange500;
        severityIcon = Icons.info_rounded;
        severityLabel = loc.t('messaging.severity_low');
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
                        _localizedAlertTitle(context, alert, categoryLabel,
                            isArabic: isArabic),
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
                    child: Text(
                      loc.t('messaging.new_badge'),
                      style: const TextStyle(
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
                              _buildDirectionChip(
                                _localizedDirectionLabel(
                                  context,
                                  alert.directionLabel,
                                ),
                              ),
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
                            loc.t('messaging.flagged_message'),
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
                        _localizedAlertContext(
                          context,
                          alert,
                          isArabic: isArabic,
                        ),
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
                      loc.t('messaging.ai_confidence'),
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
                          label: Text(loc.t('messaging.view_full_chat')),
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
                                  loc
                                      .t('messaging.reviewed_snackbar')
                                      .replaceFirst(
                                          '{name}', alert.offenderName),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white),
                          label: Text(loc.t('messaging.mark_reviewed')),
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
    final loc = context.loc;
    final label = isTeacher
        ? loc.t('messaging.role.teacher')
        : loc.t('messaging.role.child');

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
        SnackBar(content: Text(context.loc.t('messaging.select_child_first'))),
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
          SnackBar(
            content: Text(
              context.loc
                  .t('messaging.chat_load_error')
                  .replaceFirst('{error}', e.toString()),
            ),
          ),
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
                          Text(
                            context.loc.t('messaging.full_chat_title'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.loc
                                .t('messaging.full_chat_between')
                                .replaceFirst('{from}', alert.offenderName)
                                .replaceFirst('{to}', alert.targetName),
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
                                        context.loc.t('messaging.no_messages'),
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
                                            context.loc
                                                .t('messaging.flagged_badge'),
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
                    context.loc.t('messaging.chat_context_note'),
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

  String _greetingForNow(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.loc.t('greeting.morning');
    if (hour < 17) return context.loc.t('greeting.afternoon');
    return context.loc.t('greeting.evening');
  }
}

class _MoodDaySummary {
  const _MoodDaySummary(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;
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

class _WellbeingInsightItem {
  final IconData icon;
  final Color color;
  final String summary;
  final String category;
  final String timeframe;

  _WellbeingInsightItem({
    required this.icon,
    required this.color,
    required this.summary,
    required this.category,
    required this.timeframe,
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
