import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/child_provider.dart';
import '../../widgets/junior/activity_card_widget.dart';
import '../../widgets/junior/progress_ring_widget.dart';
import '../../widgets/junior/streak_display_widget.dart';
import '../../widgets/junior/mascot_widget.dart';

/// Junior Explorer dashboard (ages 6-8)
class JuniorDashboardScreen extends StatefulWidget {
  const JuniorDashboardScreen({super.key});

  @override
  State<JuniorDashboardScreen> createState() => _JuniorDashboardScreenState();
}

class _JuniorDashboardScreenState extends State<JuniorDashboardScreen> {
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer3<AuthProvider, ActivityProvider, ChildProvider>(
          builder: (context, authProvider, activityProvider, childProvider, _) {
            final child = authProvider.currentChild;
            if (child == null) {
              return const Center(child: Text('No child logged in'));
            }

            final activities = activityProvider.activities;
            final todayProgress = 0.65; // TODO: Calculate from actual progress

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SafePlayColors.juniorPurple,
                          SafePlayColors.juniorPink,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                children: [
                                  Text(
                                    '${_getGreeting()}, ${child.name}!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Level ${child.level} • ${child.xp} XP',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Progress and Streak Row
                        Row(
                          children: [
                            // Progress Ring
                            Expanded(
                              child: ProgressRingWidget(
                                progress: todayProgress,
                                size: 100,
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(todayProgress * 100).round()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Streak Display
                            Expanded(
                              flex: 2,
                              child: StreakDisplayWidget(
                                streakDays: child.streakDays,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Mascot Message
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: MascotWidget(
                      message:
                          'Hi ${child.name}! Ready for today\'s adventure? Pick an activity below!',
                    ),
                  ),
                ),

                // Section Title
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Activities',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Activity Grid
                activityProvider.isLoading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : activities.isEmpty
                        ? SliverFillRemaining(
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
                                    'No activities available yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: SafePlayColors.neutral500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final activity = activities[index];
                                  return JuniorActivityCard(
                                    activity: activity,
                                    onTap: () {
                                      // TODO: Navigate to activity detail
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Opening ${activity.title}...'),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: activities.length,
                              ),
                            ),
                          ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: SafePlayColors.juniorPurple,
        unselectedItemColor: SafePlayColors.neutral500,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }
}
