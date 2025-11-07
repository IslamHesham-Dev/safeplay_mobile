import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/activity_service.dart';
import '../../services/child_submission_service.dart';
import '../../models/game_activity.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../design_system/colors.dart';
import '../../widgets/games/junior_games.dart';
import '../../widgets/games/bright_games.dart';
import '../junior/junior_dashboard_screen.dart';

class UnifiedChildDashboardScreen extends StatefulWidget {
  const UnifiedChildDashboardScreen({super.key});

  @override
  State<UnifiedChildDashboardScreen> createState() =>
      _UnifiedChildDashboardScreenState();
}

class _UnifiedChildDashboardScreenState
    extends State<UnifiedChildDashboardScreen> with TickerProviderStateMixin {
  late final ActivityService _activityService;
  late final ChildSubmissionService _submissionService;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  List<GameActivity> _availableActivities = [];
  List<GameActivity> _completedActivities = [];
  List<GameActivity> _inProgressActivities = [];
  ChildProfile? _currentChild;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
    _submissionService = ChildSubmissionService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadDashboardData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final currentUser = auth.currentUser;

      if (currentUser == null ||
          (currentUser.userType != UserType.juniorChild &&
              currentUser.userType != UserType.brightChild)) {
        throw Exception('No child user logged in');
      }

      _currentChild = currentUser as ChildProfile;

      // Load available activities for the child's age group
      final activities = await _activityService
          .getActivitiesForAgeGroup(_currentChild!.ageGroup!);

      // Filter for game activities
      final gameActivities = activities
          .where((activity) => activity is GameActivity)
          .cast<GameActivity>()
          .toList();

      // Load child's progress
      final progress =
          await _submissionService.getChildProgress(_currentChild!.id);

      // Categorize activities
      final completedIds = progress
          .where((p) => p.isCompleted)
          .map((p) => p.gameActivityId)
          .toSet();

      final inProgressIds = progress
          .where((p) => !p.isCompleted)
          .map((p) => p.gameActivityId)
          .toSet();

      setState(() {
        _completedActivities = gameActivities
            .where((activity) => completedIds.contains(activity.id))
            .toList();
        _inProgressActivities = gameActivities
            .where((activity) => inProgressIds.contains(activity.id))
            .toList();
        _availableActivities = gameActivities
            .where((activity) =>
                !completedIds.contains(activity.id) &&
                !inProgressIds.contains(activity.id))
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is a Junior child and use Junior-specific UI
    // Check both _currentChild and current user from AuthProvider
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;

    if ((_currentChild?.ageGroup == AgeGroup.junior) ||
        (currentUser is ChildProfile &&
            currentUser.ageGroup == AgeGroup.junior)) {
      return const JuniorDashboardScreen();
    }

    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading your games...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Games')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Header
              _buildHeader(),

              // Welcome message
              _buildWelcomeMessage(),

              // Quick stats
              _buildQuickStats(),

              // In Progress Activities
              if (_inProgressActivities.isNotEmpty) _buildInProgressSection(),

              // Available Activities
              _buildAvailableActivitiesSection(),

              // Completed Activities
              if (_completedActivities.isNotEmpty) _buildCompletedSection(),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_currentChild?.ageGroup == AgeGroup.junior) {
      return SafePlayColors.juniorPurple.withValues(alpha: 0.05);
    } else {
      return SafePlayColors.brightIndigo.withValues(alpha: 0.05);
    }
  }

  Widget _buildHeader() {
    final isJunior = _currentChild?.ageGroup == AgeGroup.junior;
    final primaryColor =
        isJunior ? SafePlayColors.juniorPurple : SafePlayColors.brightIndigo;
    final accentColor =
        isJunior ? SafePlayColors.juniorPink : SafePlayColors.brightTeal;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      actions: [
        // Logout button
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _showLogoutDialog(),
          tooltip: 'Logout',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                accentColor.withValues(alpha: 0.8),
                primaryColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                right: 60,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentChild?.name ?? 'Explorer'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isJunior ? '🌟 Junior Explorer' : '🚀 Bright Mind',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Gamification elements
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: SafePlayColors.brandOrange500,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: SafePlayColors.brandOrange500
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '1,250 XP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: SafePlayColors.brandTeal500,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: SafePlayColors.brandTeal500
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Level 5',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildWelcomeMessage() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.games,
              size: 48,
              color: _currentChild?.ageGroup == AgeGroup.junior
                  ? SafePlayColors.juniorPurple
                  : SafePlayColors.brightIndigo,
            ),
            const SizedBox(height: 16),
            Text(
              'Ready for some fun learning?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SafePlayColors.neutral700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a game below to start your adventure!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SafePlayColors.neutral600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final completedCount = _completedActivities.length;
    final inProgressCount = _inProgressActivities.length;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Available',
                _availableActivities.length.toString(),
                Icons.play_circle_outline,
                SafePlayColors.brandTeal500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'In Progress',
                inProgressCount.toString(),
                Icons.hourglass_empty,
                SafePlayColors.brandOrange500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                completedCount.toString(),
                Icons.check_circle,
                SafePlayColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SafePlayColors.neutral600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brandOrange500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    color: SafePlayColors.brandOrange500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue Playing',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SafePlayColors.neutral700,
                        fontSize: 22,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_inProgressActivities.length} games',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _inProgressActivities.length,
              itemBuilder: (context, index) {
                final activity = _inProgressActivities[index];
                return _buildActivityCard(activity, isInProgress: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableActivitiesSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brandTeal500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: SafePlayColors.brandTeal500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'New Games',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SafePlayColors.neutral700,
                        fontSize: 22,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_availableActivities.length} games',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _availableActivities.length,
              itemBuilder: (context, index) {
                final activity = _availableActivities[index];
                return _buildActivityCard(activity);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: SafePlayColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Completed Games',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SafePlayColors.neutral700,
                        fontSize: 22,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_completedActivities.length} games',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _completedActivities.length,
              itemBuilder: (context, index) {
                final activity = _completedActivities[index];
                return _buildActivityCard(activity, isCompleted: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(GameActivity activity,
      {bool isInProgress = false, bool isCompleted = false}) {
    final cardColors = _getCardColors(activity.gameConfig.gameType);

    return Container(
      width: 300,
      height: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGame(activity),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and status
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getGameIcon(activity.gameConfig.gameType),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : isInProgress
                                    ? Icons.hourglass_empty
                                    : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted
                                ? 'Done'
                                : isInProgress
                                    ? 'Continue'
                                    : 'New',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Game title
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Game description
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Bottom row with info and play button
                Row(
                  children: [
                    // Game info
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.durationMinutes}m',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.points} pts',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Play button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.replay
                            : isInProgress
                                ? Icons.play_arrow
                                : Icons.play_arrow,
                        color: cardColors[0],
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getCardColors(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
        return [SafePlayColors.brandOrange500, SafePlayColors.brandOrange600];
      case GameType.koalaCounterAdventure:
        return [SafePlayColors.juniorPink, SafePlayColors.juniorPurple];
      case GameType.fractionNavigator:
        return [SafePlayColors.brightTeal, SafePlayColors.brandTeal500];
      case GameType.inverseOperationChain:
        return [SafePlayColors.brightIndigo, SafePlayColors.brightDeepPurple];
      case GameType.ordinalDragOrder:
        return [SafePlayColors.juniorCyan, SafePlayColors.brandTeal500];
      case GameType.patternBuilder:
        return [SafePlayColors.brightAmber, SafePlayColors.brandOrange500];
      case GameType.bubblePopGrammar:
        return [const Color(0xFF64B5F6), const Color(0xFF1976D2)];
      case GameType.seashellQuiz:
        return [const Color(0xFFFFE0B2), const Color(0xFFFFB74D)];
      case GameType.fishTankQuiz:
        return [const Color(0xFF4FC3F7), const Color(0xFF0288D1)];
      case GameType.dataVisualization:
        return [SafePlayColors.juniorLime, SafePlayColors.brightTeal];
      case GameType.cartesianGrid:
        return [SafePlayColors.brightDeepPurple, SafePlayColors.juniorPurple];
      case GameType.memoryMatch:
        return [SafePlayColors.juniorCyan, SafePlayColors.brandTeal500];
      case GameType.wordBuilder:
        return [SafePlayColors.brightAmber, SafePlayColors.brandOrange500];
      case GameType.storySequencer:
        return [SafePlayColors.juniorPink, SafePlayColors.juniorPurple];
    }
  }

  IconData _getGameIcon(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
        return Icons.grid_on;
      case GameType.koalaCounterAdventure:
        return Icons.pets;
      case GameType.ordinalDragOrder:
        return Icons.sort;
      case GameType.patternBuilder:
        return Icons.pattern;
      case GameType.bubblePopGrammar:
        return Icons.bubble_chart;
      case GameType.seashellQuiz:
        return Icons.water_damage;
      case GameType.fishTankQuiz:
        return Icons.set_meal;
      case GameType.fractionNavigator:
        return Icons.calculate;
      case GameType.inverseOperationChain:
        return Icons.link;
      case GameType.dataVisualization:
        return Icons.bar_chart;
      case GameType.cartesianGrid:
        return Icons.grid_3x3;
      case GameType.memoryMatch:
        return Icons.psychology;
      case GameType.wordBuilder:
        return Icons.text_fields;
      case GameType.storySequencer:
        return Icons.menu_book;
    }
  }

  void _startGame(GameActivity activity) {
    // Navigate to the appropriate game based on the game type
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _buildGameWidget(activity),
      ),
    );
  }

  Widget _buildGameWidget(GameActivity activity) {
    final gameType = activity.gameConfig.gameType;

    // Create a callback for handling responses
    void onResponse(GameResponse response) {
      // Save the response to the database
      _submissionService.saveGameResponse(response);
    }

    // Create a callback for game completion
    void onComplete() {
      // Mark the activity as completed
      _submissionService.markActivityCompleted(
        activity.id,
        _currentChild!.id,
      );

      // Show completion dialog
      _showCompletionDialog(activity);
    }

    switch (gameType) {
      case GameType.numberGridRace:
      case GameType.koalaCounterAdventure:
      case GameType.ordinalDragOrder:
      case GameType.patternBuilder:
        return JuniorGameWrapper(
          activity: activity,
          onResponse: onResponse,
          onComplete: onComplete,
        );
      case GameType.fractionNavigator:
      case GameType.inverseOperationChain:
      case GameType.dataVisualization:
      case GameType.cartesianGrid:
        return BrightGameWrapper(
          activity: activity,
          onResponse: onResponse,
          onComplete: onComplete,
        );
      default:
        return Scaffold(
          appBar: AppBar(title: Text(activity.title)),
          body: const Center(
            child: Text('Game not implemented yet'),
          ),
        );
    }
  }

  void _showCompletionDialog(GameActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: SafePlayColors.success,
            ),
            const SizedBox(height: 16),
            Text('You completed "${activity.title}"!'),
            const SizedBox(height: 8),
            Text('You earned ${activity.points} points!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadDashboardData(); // Refresh the dashboard
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: Text(
            'Are you sure you want to logout, ${_currentChild?.name ?? 'Explorer'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle logout process
  Future<void> _logout() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (mounted) {
        // Navigate to the main screen (splash/login)
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Wrapper for Junior games
class JuniorGameWrapper extends StatelessWidget {
  final GameActivity activity;
  final Function(GameResponse) onResponse;
  final VoidCallback onComplete;

  const JuniorGameWrapper({
    super.key,
    required this.activity,
    required this.onResponse,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    switch (activity.gameConfig.gameType) {
      case GameType.numberGridRace:
        return NumberGridRaceGame(
          gameConfig: activity.gameConfig,
          questions: activity.questions,
          onResponse: onResponse,
          onComplete: onComplete,
        );
      case GameType.koalaCounterAdventure:
        return KoalaCounterAdventureGame(
          gameConfig: activity.gameConfig,
          questions: activity.questions,
          onResponse: onResponse,
          onComplete: onComplete,
        );
      default:
        return Scaffold(
          appBar: AppBar(title: Text(activity.title)),
          body: const Center(
            child: Text('This game is coming soon!'),
          ),
        );
    }
  }
}

/// Wrapper for Bright games
class BrightGameWrapper extends StatelessWidget {
  final GameActivity activity;
  final Function(GameResponse) onResponse;
  final VoidCallback onComplete;

  const BrightGameWrapper({
    super.key,
    required this.activity,
    required this.onResponse,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    switch (activity.gameConfig.gameType) {
      case GameType.fractionNavigator:
        return FractionNavigatorGame(
          gameConfig: activity.gameConfig,
          questions: activity.questions,
          onResponse: onResponse,
          onComplete: onComplete,
        );
      case GameType.inverseOperationChain:
        return InverseOperationChainGame(
          gameConfig: activity.gameConfig,
          questions: activity.questions,
          onResponse: onResponse,
          onComplete: onComplete,
        );
      default:
        return Scaffold(
          appBar: AppBar(title: Text(activity.title)),
          body: const Center(
            child: Text('This game is coming soon!'),
          ),
        );
    }
  }
}
