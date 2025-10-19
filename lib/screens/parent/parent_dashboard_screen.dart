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
import '../../widgets/parent/activity_timeline_widget.dart';
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
        title: const Text('Parent Dashboard'),
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
            final user = authProvider.currentUser;
            final children = childProvider.children;
            final selectedChild = childProvider.selectedChild;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildWelcomeSection(context, user, children.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildChildSelectorCard(context, childProvider),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child:
                        _buildStatsRow(context, children.length, selectedChild),
                  ),
                ),
                _buildRecommendedActivitiesSection(
                    context, childProvider, activityProvider),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: ChildrenListWidget(
                      children: children,
                      onChildTap: (child) {
                        // Select the child when tapped
                        unawaited(childProvider.selectChild(child));
                      },
                      onChildEdit: (child) {
                        // Navigate to edit child screen
                        context.push(RouteNames.parentEditChild, extra: child);
                      },
                      onChildSetupLogin: (child) {
                        // Navigate to appropriate auth setup screen
                        if (child.ageGroup == AgeGroup.junior) {
                          context.push(RouteNames.juniorAuthSetup,
                              extra: child);
                        } else {
                          context.push(RouteNames.brightAuthSetup,
                              extra: child);
                        }
                      },
                      onChildDelete: (child) async {
                        // Delete the child profile
                        final success =
                            await childProvider.deleteChild(child.id);
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  sliver: const SliverToBoxAdapter(
                    child: ActivityTimelineWidget(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.parentAddChild),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Child'),
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    UserProfile? user,
    int childCount,
  ) {
    final greeting = _greetingForNow();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user?.name ?? 'Parent'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              childCount == 0
                  ? "Let's add your children so you can monitor their progress."
                  : "Here's the latest on your ${childCount == 1 ? 'child' : 'children'} today.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSelectorCard(
      BuildContext context, ChildProvider childProvider) {
    if (childProvider.children.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No child profiles yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a child to begin tracking activity and wellbeing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.neutral700,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedChild = childProvider.selectedChild;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active child',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedChild?.id,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.child_care_outlined),
                border: OutlineInputBorder(),
                labelText: 'Choose a child',
              ),
              items: childProvider.children
                  .map(
                    (child) => DropdownMenuItem(
                      value: child.id,
                      child: Text(child.name),
                    ),
                  )
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
            if (selectedChild != null) ...[
              const SizedBox(height: 12),
              Text(
                'Viewing ${selectedChild.name}\'s data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    int childCount,
    ChildProfile? activeChild,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Children',
            value: childCount.toString(),
            icon: Icons.family_restroom,
            color: SafePlayColors.brandTeal500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Active child',
            value: activeChild?.name ?? 'None selected',
            icon: Icons.assignment_ind,
            color: SafePlayColors.brandOrange500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Streak',
            value: activeChild == null ? '-' : '${activeChild.streakDays} days',
            icon: Icons.local_fire_department,
            color: SafePlayColors.success,
          ),
        ),
      ],
    );
  }

  SliverPadding _buildRecommendedActivitiesSection(
    BuildContext context,
    ChildProvider childProvider,
    ActivityProvider activityProvider,
  ) {
    if (childProvider.children.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }

    final selectedChild = childProvider.selectedChild;
    final activities = activityProvider.activities;
    final isLoading = activityProvider.isLoading;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school,
                        color: SafePlayColors.brightIndigo),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended activities',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const LinearProgressIndicator()
                else if (selectedChild == null)
                  Text(
                    'Select a child to preview recommended activities.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else if (activities.isEmpty)
                  Text(
                    'No activities available for ${selectedChild.name} yet. Check back soon.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else ...[
                  ...activities.take(4).map(
                        (activity) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: SafePlayColors.neutral200,
                            child: Icon(
                              Icons.auto_stories,
                              color: SafePlayColors.brandTeal500,
                            ),
                          ),
                          title: Text(activity.title),
                          subtitle: Text(
                            '${activity.subject.displayName} - ${activity.durationMinutes} min - ${activity.points} XP',
                          ),
                        ),
                      ),
                  if (activities.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '+${activities.length - 4} more activities',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: SafePlayColors.brightIndigo,
                                  ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
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
