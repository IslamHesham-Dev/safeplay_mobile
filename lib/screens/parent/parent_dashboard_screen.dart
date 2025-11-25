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
                // Recent Activities Section (moved here, right after stats)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildRecentActivitiesCard(context, childProvider, activityProvider),
                  ),
                ),
                // Parental Controls Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildParentalControlsCard(context, childProvider),
                  ),
                ),
                // Wellbeing Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildWellbeingCard(context, childProvider),
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.parentAddChild),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Child'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
      ),
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
                prefixIcon: Icon(
                  Icons.child_care,
                  color: selectedChild != null ? SafePlayColors.brandTeal500 : SafePlayColors.neutral400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: 'Select a child',
                hintStyle: TextStyle(color: SafePlayColors.neutral400),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: childProvider.children
                  .map((child) => DropdownMenuItem(
                        value: child.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: child.ageGroup == AgeGroup.junior
                                  ? SafePlayColors.juniorPurple.withOpacity(0.2)
                                  : SafePlayColors.brightIndigo.withOpacity(0.2),
                              child: Text(
                                child.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: child.ageGroup == AgeGroup.junior
                                      ? SafePlayColors.juniorPurple
                                      : SafePlayColors.brightIndigo,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(child.name),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: child.ageGroup == AgeGroup.junior
                                    ? SafePlayColors.juniorPurple.withOpacity(0.1)
                                    : SafePlayColors.brightIndigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                child.ageGroup == AgeGroup.junior ? 'Junior' : 'Bright',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: child.ageGroup == AgeGroup.junior
                                      ? SafePlayColors.juniorPurple
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
    
    // Generate mock activities for selected child
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
                  onPressed: () {
                    // View all activities
                  },
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

  // ============ PARENTAL CONTROLS CARD ============
  Widget _buildParentalControlsCard(BuildContext context, ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
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
            child: const Icon(Icons.shield_rounded, color: SafePlayColors.brightIndigo, size: 24),
          ),
          title: const Text(
            'Browser Controls',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (selectedChild != null) ...[
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
                    selectedChild.name,
                    style: TextStyle(color: SafePlayColors.success, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ] else
                  Text(
                    hasChild ? 'Select a child above' : 'Add a child first',
                    style: TextStyle(color: SafePlayColors.neutral400, fontSize: 12),
                  ),
              ],
            ),
          ),
          children: [
            if (!hasChild)
              _buildEmptyStateMessage(
                'Add a child to configure their browser settings.',
                Icons.child_care_rounded,
                SafePlayColors.brandOrange500,
              )
            else if (selectedChild == null)
              _buildEmptyStateMessage(
                'Select a child from the dropdown to manage their browser settings.',
                Icons.touch_app_rounded,
                SafePlayColors.brandTeal500,
              )
            else ...[
              // Safe Search Toggle
              _buildControlToggle(
                'Safe Search',
                'Filter inappropriate content',
                Icons.search_rounded,
                _safeSearchEnabled,
                (v) => setState(() => _safeSearchEnabled = v),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1),
              ),
              
              // Content Filters
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_alt_rounded, size: 18, color: SafePlayColors.brightIndigo),
                        const SizedBox(width: 8),
                        const Text('Content Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('Ads', _blockAds, (v) => setState(() => _blockAds = v)),
                        _buildFilterChip('Social Media', _blockSocialMedia, (v) => setState(() => _blockSocialMedia = v)),
                        _buildFilterChip('Gambling', _blockGambling, (v) => setState(() => _blockGambling = v)),
                        _buildFilterChip('Violence', _blockViolence, (v) => setState(() => _blockViolence = v)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1),
              ),
              
              // Blocked Keywords
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.block_rounded, size: 18, color: SafePlayColors.error),
                        const SizedBox(width: 8),
                        const Text('Blocked Keywords', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showAddKeywordDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: SafePlayColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 14, color: SafePlayColors.error),
                                const SizedBox(width: 4),
                                Text('Add', style: TextStyle(color: SafePlayColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _blockedKeywords.map((keyword) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SafePlayColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: SafePlayColors.error.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(keyword, style: TextStyle(color: SafePlayColors.error, fontSize: 13)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _blockedKeywords.remove(keyword)),
                              child: Icon(Icons.close, size: 14, color: SafePlayColors.error),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1),
              ),
              
              // Allowed Sites
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 18, color: SafePlayColors.success),
                        const SizedBox(width: 8),
                        const Text('Allowed Sites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showAddSiteDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: SafePlayColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 14, color: SafePlayColors.success),
                                const SizedBox(width: 4),
                                Text('Add', style: TextStyle(color: SafePlayColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._allowedSites.map((site) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: SafePlayColors.success.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SafePlayColors.success.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.language, color: SafePlayColors.success, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(site, style: const TextStyle(fontSize: 13))),
                          GestureDetector(
                            onTap: () => setState(() => _allowedSites.remove(site)),
                            child: Icon(Icons.remove_circle_outline, color: SafePlayColors.error.withOpacity(0.7), size: 18),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              
              // Save Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
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
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafePlayColors.brandTeal500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlToggle(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SafePlayColors.brandTeal500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: SafePlayColors.brandTeal500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: SafePlayColors.neutral500, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SafePlayColors.brandTeal500,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: value ? SafePlayColors.brightIndigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? SafePlayColors.brightIndigo : SafePlayColors.neutral200,
          ),
          boxShadow: value ? [
            BoxShadow(
              color: SafePlayColors.brightIndigo.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: value ? Colors.white : SafePlayColors.neutral400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: value ? Colors.white : SafePlayColors.neutral600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
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

  // ============ WELLBEING CARD ============
  Widget _buildWellbeingCard(BuildContext context, ChildProvider childProvider) {
    final selectedChild = childProvider.selectedChild;
    final hasChild = childProvider.children.isNotEmpty;
    
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SafePlayColors.juniorPink.withOpacity(0.15),
                  SafePlayColors.juniorPink.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_rounded, color: SafePlayColors.juniorPink, size: 24),
          ),
          title: const Text(
            'Wellbeing Reports',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (selectedChild != null) ...[
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
                    '${selectedChild.name}\'s mood',
                    style: TextStyle(color: SafePlayColors.success, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ] else
                  Text(
                    hasChild ? 'Select a child above' : 'Add a child first',
                    style: TextStyle(color: SafePlayColors.neutral400, fontSize: 12),
                  ),
              ],
            ),
          ),
          children: [
            if (!hasChild)
              _buildEmptyStateMessage(
                'Add a child to view their wellbeing reports.',
                Icons.child_care_rounded,
                SafePlayColors.brandOrange500,
              )
            else if (selectedChild == null)
              _buildEmptyStateMessage(
                'Select a child from the dropdown to view their emotional health.',
                Icons.touch_app_rounded,
                SafePlayColors.brandTeal500,
              )
            else ...[
              // Overall Score Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SafePlayColors.success, SafePlayColors.success.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('😊', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Wellbeing',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Good',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '85%',
                          style: TextStyle(
                            color: SafePlayColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Weekly Mood
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 18, color: SafePlayColors.juniorPink),
                        const SizedBox(width: 8),
                        const Text('This Week', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
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
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Divider(height: 1),
              ),
              
              // Recent Check-ins
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_rounded, size: 18, color: SafePlayColors.brightIndigo),
                        const SizedBox(width: 8),
                        const Text('Recent Check-ins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
            color: SafePlayColors.neutral400,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(mood, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(date, style: TextStyle(color: SafePlayColors.neutral400, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(color: SafePlayColors.neutral600, fontSize: 12),
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

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
