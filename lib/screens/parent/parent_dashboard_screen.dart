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

  // Parental controls state (UI only)
  bool _safeSearchEnabled = true;
  bool _blockAds = true;
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
                // Parental Controls Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildParentalControlsCard(context, childProvider),
                  ),
                ),
                // Wellbeing Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildWellbeingCard(context, childProvider),
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

  // ============ PARENTAL CONTROLS CARD ============
  Widget _buildParentalControlsCard(BuildContext context, ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SafePlayColors.brightIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: SafePlayColors.brightIndigo),
          ),
          title: const Text(
            'Browser Parental Controls',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            selectedChild != null 
                ? 'Settings for ${selectedChild.name}'
                : 'Select a child to configure',
            style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12),
          ),
          children: [
            if (childProvider.children.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: SafePlayColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add a child first to configure their browser settings.',
                        style: TextStyle(color: SafePlayColors.neutral700),
                      ),
                    ),
                  ],
                ),
              )
            else if (selectedChild == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: SafePlayColors.brandTeal500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select a child from the dropdown above to configure their settings.',
                        style: TextStyle(color: SafePlayColors.neutral700),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Safe Search Toggle
              SwitchListTile(
                title: const Text('Safe Search'),
                subtitle: const Text('Filter inappropriate content from searches'),
                value: _safeSearchEnabled,
                onChanged: (value) => setState(() => _safeSearchEnabled = value),
                activeColor: SafePlayColors.brandTeal500,
              ),
              const Divider(height: 1),
              
              // Content Filters
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined, size: 20, color: SafePlayColors.brightIndigo),
                        const SizedBox(width: 8),
                        Text(
                          'Content Filters',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChip('Block Ads', _blockAds, (v) => setState(() => _blockAds = v)),
                    _buildFilterChip('Block Social Media', _blockSocialMedia, (v) => setState(() => _blockSocialMedia = v)),
                    _buildFilterChip('Block Gambling', _blockGambling, (v) => setState(() => _blockGambling = v)),
                    _buildFilterChip('Block Violence', _blockViolence, (v) => setState(() => _blockViolence = v)),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Blocked Keywords
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.block, size: 20, color: SafePlayColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'Blocked Keywords',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._blockedKeywords.map((keyword) => Chip(
                          label: Text(keyword),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _blockedKeywords.remove(keyword)),
                          backgroundColor: SafePlayColors.error.withOpacity(0.1),
                          labelStyle: const TextStyle(color: SafePlayColors.error),
                        )),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                          onPressed: () => _showAddKeywordDialog(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Allowed Sites
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 20, color: SafePlayColors.success),
                        const SizedBox(width: 8),
                        Text(
                          'Allowed Websites',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._allowedSites.map((site) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language, color: SafePlayColors.success, size: 20),
                      title: Text(site),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: SafePlayColors.error, size: 20),
                        onPressed: () => setState(() => _allowedSites.remove(site)),
                      ),
                    )),
                    TextButton.icon(
                      onPressed: () => _showAddSiteDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Website'),
                    ),
                  ],
                ),
              ),
              
              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Settings saved for ${selectedChild.name}'),
                          backgroundColor: SafePlayColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafePlayColors.brandTeal500,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Settings'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SafePlayColors.brandTeal500,
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
        title: const Text('Add Blocked Keyword'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter keyword to block',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _blockedKeywords.add(controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
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
        title: const Text('Add Allowed Website'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., example.com',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _allowedSites.add(controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ============ WELLBEING CARD ============
  Widget _buildWellbeingCard(BuildContext context, ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SafePlayColors.juniorPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite_outline, color: SafePlayColors.juniorPink),
          ),
          title: const Text(
            'Wellbeing Reports',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            selectedChild != null 
                ? '${selectedChild.name}\'s emotional health'
                : 'Select a child to view',
            style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12),
          ),
          children: [
            if (childProvider.children.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: SafePlayColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add a child first to view their wellbeing reports.',
                        style: TextStyle(color: SafePlayColors.neutral700),
                      ),
                    ),
                  ],
                ),
              )
            else if (selectedChild == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: SafePlayColors.brandTeal500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select a child from the dropdown above to view their wellbeing.',
                        style: TextStyle(color: SafePlayColors.neutral700),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Weekly Mood Summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: SafePlayColors.juniorPink),
                        const SizedBox(width: 8),
                        Text(
                          'This Week\'s Mood',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMoodDay('Mon', '🤩', SafePlayColors.success),
                        _buildMoodDay('Tue', '🙂', SafePlayColors.brandTeal500),
                        _buildMoodDay('Wed', '🙂', SafePlayColors.brandTeal500),
                        _buildMoodDay('Thu', '😐', SafePlayColors.warning),
                        _buildMoodDay('Fri', '🤩', SafePlayColors.success),
                        _buildMoodDay('Sat', '—', SafePlayColors.neutral300),
                        _buildMoodDay('Sun', '—', SafePlayColors.neutral300),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Overall Score
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('😊', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Wellbeing',
                              style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12),
                            ),
                            const Text(
                              'Good',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: SafePlayColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SafePlayColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '85%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              
              // Recent Check-ins
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, size: 20, color: SafePlayColors.brightIndigo),
                        const SizedBox(width: 8),
                        Text(
                          'Recent Check-ins',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCheckinItem('Today', '🤩', 'Awesome', 'Had a great day at school!'),
                    _buildCheckinItem('Yesterday', '🙂', 'Good', 'Played with friends'),
                    _buildCheckinItem('2 days ago', '😐', 'Okay', 'Felt a bit tired'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDay(String day, String emoji, Color color) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: SafePlayColors.neutral500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckinItem(String date, String emoji, String mood, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mood,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date,
                      style: TextStyle(color: SafePlayColors.neutral500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(color: SafePlayColors.neutral600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
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
