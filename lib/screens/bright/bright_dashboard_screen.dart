import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/bright/stats_card_widget.dart';
import '../../widgets/bright/achievement_badge_widget.dart';
import '../../widgets/bright/level_progress_bar.dart';

/// Bright Minds dashboard (ages 9-12)
class BrightDashboardScreen extends StatefulWidget {
  const BrightDashboardScreen({super.key});

  @override
  State<BrightDashboardScreen> createState() => _BrightDashboardScreenState();
}

class _BrightDashboardScreenState extends State<BrightDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final activityProvider = context.read<ActivityProvider>();

    final child = authProvider.currentChild;
    if (child != null) {
      await activityProvider.loadActivitiesForChild(child);
    } else {
      activityProvider.clearActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<AuthProvider, ActivityProvider>(
          builder: (context, authProvider, activityProvider, _) {
            final child = authProvider.currentChild;
            if (child == null) {
              return const Center(child: Text('No child logged in'));
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SafePlayColors.brightIndigo,
                            SafePlayColors.brightTeal,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Text(
                              child.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome, ${child.name}!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Ready to learn?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // TODO: Open notifications
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_events_outlined),
                      onPressed: () {
                        setState(() => _selectedTabIndex = 2);
                      },
                    ),
                  ],
                ),

                // Level Progress
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: LevelProgressBar(
                      currentLevel: child.level,
                      currentXP: child.xp,
                      xpForNextLevel: child.level * 100,
                    ),
                  ),
                ),

                // Stats Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Activities',
                            value: '12',
                            subtitle: 'This week',
                            icon: Icons.school,
                            color: SafePlayColors.brightIndigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Streak',
                            value: '${child.streakDays}',
                            subtitle: 'Days',
                            icon: Icons.local_fire_department,
                            color: SafePlayColors.brandOrange500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'XP Earned',
                            value: '${child.xp}',
                            subtitle: 'Total points',
                            icon: Icons.star,
                            color: SafePlayColors.brightAmber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Achievements',
                            value: '${child.achievements.length}',
                            subtitle: 'Unlocked',
                            icon: Icons.emoji_events,
                            color: SafePlayColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SafePlayColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildTab('Activities', 0),
                          _buildTab('Forum', 1),
                          _buildTab('Achievements', 2),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab Content
                if (_selectedTabIndex == 0)
                  _buildActivitiesTab(activityProvider)
                else if (_selectedTabIndex == 1)
                  _buildForumTab()
                else
                  _buildAchievementsTab(child),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: SafePlayColors.brightIndigo,
        unselectedItemColor: SafePlayColors.neutral500,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? SafePlayColors.brightIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : SafePlayColors.neutral700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(ActivityProvider activityProvider) {
    final activities = activityProvider.activities;

    if (activityProvider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (activities.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 80,
                color: SafePlayColors.neutral500,
              ),
              const SizedBox(height: 16),
              Text(
                'No activities available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SafePlayColors.neutral500,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final activity = activities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      SafePlayColors.brightIndigo.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.school,
                    color: SafePlayColors.brightIndigo,
                  ),
                ),
                title: Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${activity.estimatedDuration} min • ${activity.points} XP',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${activity.title}...')),
                  );
                },
              ),
            );
          },
          childCount: activities.length,
        ),
      ),
    );
  }

  Widget _buildForumTab() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum,
                size: 80,
                color: SafePlayColors.neutral500,
              ),
              const SizedBox(height: 16),
              Text(
                'Forum Coming Soon',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SafePlayColors.neutral500,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with other learners',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.neutral500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(child) {
    final achievements = [
      {
        'title': 'First Steps',
        'description': 'Complete your first activity',
        'icon': Icons.directions_walk,
        'unlocked': child.achievements.contains('first_activity'),
      },
      {
        'title': 'Week Warrior',
        'description': '7-day streak',
        'icon': Icons.local_fire_department,
        'unlocked': child.streakDays >= 7,
      },
      {
        'title': 'Century Club',
        'description': 'Earn 100 XP',
        'icon': Icons.stars,
        'unlocked': child.xp >= 100,
      },
      {
        'title': 'Perfect Score',
        'description': 'Get 100% on an activity',
        'icon': Icons.emoji_events,
        'unlocked': child.achievements.contains('perfect_score'),
      },
      {
        'title': 'Quick Learner',
        'description': 'Complete 10 activities',
        'icon': Icons.speed,
        'unlocked': child.achievements.contains('10_activities'),
      },
      {
        'title': 'Master Mind',
        'description': 'Reach Level 10',
        'icon': Icons.psychology,
        'unlocked': child.level >= 10,
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final achievement = achievements[index];
            return AchievementBadgeWidget(
              title: achievement['title'] as String,
              description: achievement['description'] as String,
              icon: achievement['icon'] as IconData,
              isUnlocked: achievement['unlocked'] as bool,
              unlockedAt:
                  achievement['unlocked'] as bool ? DateTime.now() : null,
            );
          },
          childCount: achievements.length,
        ),
      ),
    );
  }
}
