import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../models/lesson.dart';
import '../../models/children_progress.dart';
import '../../models/activity.dart';
import '../../design_system/junior_theme.dart';
// Services removed for mock data demonstration
import '../../widgets/junior/junior_avatar_widget.dart';
import '../../widgets/junior/junior_task_card.dart';
import '../../widgets/junior/junior_progress_bar.dart';
import '../../widgets/junior/junior_bottom_navigation.dart';
import '../../widgets/junior/junior_confetti.dart';
import '../../widgets/question_template_exporter.dart';
import '../../services/junior_game_launcher.dart';
import '../junior/games/number_hunt_games.dart';
import '../junior/games/koala_jumps_games.dart';
import '../junior/games/pattern_wizard_games.dart';
import '../junior/games/math_adventures_games.dart';
import '../junior/games/reading_adventures_games.dart';
import '../junior/games/science_adventures_games.dart';
import '../../navigation/route_names.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../widgets/book_card.dart';
import '../child/book_reader_screen.dart';
import '../../models/simulation.dart' as sim;
import '../../services/simulation_service.dart';
import '../../widgets/bright/simulation_card.dart';
import 'simulation_detail_screen.dart';
import 'package:go_router/go_router.dart';

/// Bright (9-12) dashboard screen that reuses the junior UI for consistency
class BrightDashboardScreen extends StatefulWidget {
  const BrightDashboardScreen({super.key});

  @override
  State<BrightDashboardScreen> createState() => _BrightDashboardScreenState();
}

class _BrightDashboardScreenState extends State<BrightDashboardScreen>
    with TickerProviderStateMixin {
  // Services removed for mock data demonstration
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final JuniorGameLauncher _gameLauncher = JuniorGameLauncher();

  List<Lesson> _todaysTasks = [];
  List<Lesson> _completedTasks = [];
  List<Lesson> _availableTasks = [];
  ChildrenProgress? _childProgress;
  ChildProfile? _currentChild;
  bool _loading = false;
  String? _error;
  List<Book> _books = [];
  final BookService _bookService = BookService();
  List<sim.Simulation> _simulations = [];
  final SimulationService _simulationService = SimulationService();
  int _currentBottomNavIndex = 0; // Home is active by default
  bool _showCelebration = false;

  // Audio player for background music
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Audio player for click sounds
  final AudioPlayer _clickSoundPlayer = AudioPlayer();

  String _sanitizeGender(String? gender) {
    if (gender == null) return 'female';
    final normalized = gender.toLowerCase();
    if (normalized == 'male' || normalized == 'boy') return 'male';
    if (normalized == 'female' || normalized == 'girl') return 'female';
    return 'female';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: JuniorTheme.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: JuniorTheme.smoothCurve),
    );
    _loadDashboardData();
    _loadBooks();
    _loadSimulations();
    _animationController.forward();
    // Start background music
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      // Configure background music player to use media player mode for proper looping
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.7); // Set volume to 70%
      await _audioPlayer.play(AssetSource('audio/third.mp3'));
      debugPrint('✅ Background music started: third.mp3');

      // Verify player state after a short delay
      Future.delayed(const Duration(milliseconds: 500), () async {
        final state = _audioPlayer.state;
        debugPrint('📊 Audio player state: $state');
      });
    } catch (e) {
      debugPrint('❌ Error playing background music: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _playClickSound() async {
    try {
      // Configure click sound player to not interfere with background music
      await _clickSoundPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _clickSoundPlayer
          .play(AssetSource('audio/sound effects/sound effects/click.mp3'));
    } catch (e) {
      debugPrint('Error playing click sound: $e');
    }
  }

  Future<void> _stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopBackgroundMusic();
    _audioPlayer.dispose();
    _clickSoundPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final currentUser = auth.currentUser;
      final currentChild = auth.currentChild;
      ChildProfile? child;

      // Prefer currentUser if type matches, else use currentChild
      if (currentUser != null && currentUser.userType == UserType.brightChild) {
        child = currentUser as ChildProfile;
      } else if (currentChild != null &&
          currentChild.ageGroup == AgeGroup.bright) {
        child = currentChild;
      }

      if (child == null) {
        setState(() {
          _error = 'No bright child is logged in.';
          _loading = false;
        });
        return;
      }

      _currentChild = child;

      // Load games from Firebase question templates
      await _loadGamesFromTemplates();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() => _error = e.toString());
      setState(() => _loading = false);
    }
  }

  /// Load bright activities from the shared activity provider

  Future<void> _loadGamesFromTemplates() async {
    try {
      final child = _currentChild;

      if (child == null) {
        debugPrint('?s??,? No bright child available for activity load');

        return;
      }

      debugPrint('dYZr Loading bright activities for dashboard...');

      final activityProvider = context.read<ActivityProvider>();

      await activityProvider.loadActivitiesForChild(child);

      final activities = activityProvider.activities;

      if (activities.isEmpty) {
        debugPrint('?s??,? No activities found for bright child');

        setState(() {
          _todaysTasks = [];

          _availableTasks = [];

          _completedTasks = [];
        });

        return;
      }

      final lessons = activities.map(_lessonFromActivity).toList();

      final progressMap = activityProvider.progressByActivity;

      final completedIds = progressMap.entries
          .where((entry) => entry.value.isCompleted)
          .map((entry) => entry.key)
          .toSet();

      final completedTasks =
          lessons.where((lesson) => completedIds.contains(lesson.id)).toList();

      final availableTasks =
          lessons.where((lesson) => !completedIds.contains(lesson.id)).toList();

      final earnedPoints = progressMap.values.fold<int>(
        0,
        (sum, progress) => sum + progress.pointsEarned,
      );

      _childProgress = ChildrenProgress(
        id: 'progress_',
        childId: child.id,
        completedLessons: completedIds.toList(),
        earnedPoints: earnedPoints,
        lastActiveDate: DateTime.now(),
      );

      setState(() {
        _todaysTasks = lessons;

        _completedTasks = completedTasks;

        _availableTasks = availableTasks;
      });

      debugPrint(
          '?o. Dashboard: State updated - total: , available: , completed: ');
    } catch (e) {
      debugPrint('??O Error loading bright activities: ');

      setState(() {
        _error = 'Error loading games: ';

        _todaysTasks = [];

        _availableTasks = [];

        _completedTasks = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: JuniorTheme.backgroundLight,
      body: Stack(
        children: [
          // Extended background image (extends into notch area)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.40 + 80, // Extended to cover notch area
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image with fallback
                Image.asset(
                  'assets/images/bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          JuniorTheme.primaryBlue,
                          JuniorTheme.backgroundLight
                        ],
                      ),
                    ),
                  ),
                ),
                // Logout button in top-right corner (accessible placement)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: JuniorTheme.spacingXSmall,
                        right: JuniorTheme.spacingMedium,
                        bottom: JuniorTheme.spacingMedium,
                        left: JuniorTheme.spacingMedium,
                      ),
                      child: _buildLogoutButton(),
                    ),
                  ),
                ),
                // Avatar + coins grouped so coins are guaranteed below avatar
                Align(
                  alignment: const Alignment(
                      0, -0.50), // Moved down from -0.70 to -0.50
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: JuniorAvatarWidget(
                          childId: _currentChild?.id ?? '',
                          size: height * 0.15 + 40,
                          gender: _sanitizeGender(_currentChild?.gender),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Text(
                              '${_childProgress?.earnedPoints ?? 0}',
                              textAlign: TextAlign.center,
                              style: JuniorTheme.headingLarge.copyWith(
                                color: JuniorTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 52,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 54, // lowered a bit more for extra spacing
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: JuniorTheme.accentGold,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'coins collected',
                                    textAlign: TextAlign.center,
                                    style: JuniorTheme.bodySmall.copyWith(
                                      color: JuniorTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.white
                                              .withValues(alpha: 0.4),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // White content area with notched divider (allows background to show through notch)
          Positioned(
            top: height * 0.40 - 50, // Start slightly before background ends
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: NotchedDividerClipper(),
              child: CustomPaint(
                painter: NotchedWhitePainter(),
                child: RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: JuniorTheme.spacingMedium,
                      right: JuniorTheme.spacingMedium,
                      top: 80, // Start below notched divider
                      bottom: 100, // Extra padding for floating nav bar
                    ),
                    child: Column(
                      children: [
                        // GREETING (below background section, left-aligned)
                        if (_currentChild != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 32, top: 12, bottom: 18),
                            child: _buildWelcomeMessage(_currentChild!.name),
                          ),
                        ],
                        // BODY CONTENT (varies by navigation index)
                        _buildCurrentScreen(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Floating navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: JuniorBottomNavigation(
                currentIndex: _currentBottomNavIndex,
                onTap: _handleBottomNavTap,
                items: const [
                  JuniorNavigationItem(
                    icon: Icons.home,
                    activeIcon: Icons.home,
                    label: 'Home',
                  ),
                  JuniorNavigationItem(
                    icon: Icons.notifications,
                    activeIcon: Icons.notifications,
                    label: 'Notifications',
                  ),
                  JuniorNavigationItem(
                    icon: Icons.card_giftcard,
                    activeIcon: Icons.card_giftcard,
                    label: 'Rewards',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(String childName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $childName!',
          textAlign: TextAlign.left,
          style: JuniorTheme.headingLarge.copyWith(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: JuniorTheme.textPrimary,
            shadows: [
              Shadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(1, 2))
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Ready for a new adventure today?',
                textAlign: TextAlign.left,
                style: JuniorTheme.bodyLarge.copyWith(
                  color: JuniorTheme.primaryOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    final gender = _sanitizeGender(_currentChild?.gender);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: JuniorTheme.primaryGradient,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowHeavy,
      ),
      child: Column(
        children: [
          // Character avatar
          JuniorAvatarWidget(
            childId: _currentChild?.id ?? '',
            size: JuniorTheme.avatarSizeXLarge,
            gender: gender,
          ),

          const SizedBox(height: JuniorTheme.spacingMedium),

          // Points display - large number
          Text(
            '${_childProgress?.earnedPoints ?? 0}',
            style: JuniorTheme.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),

          const SizedBox(height: JuniorTheme.spacingXSmall),

          // Coins text - small and thin
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on,
                color: JuniorTheme.accentGold,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'coins collected',
                style: JuniorTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasksProgress() {
    final completedCount = _completedTasks.length;
    final totalCount = _todaysTasks.length;

    return JuniorDailyTasksProgressBar(
      completedTasks: completedCount,
      totalTasks: totalCount,
      label: 'Today\'s Adventures',
    );
  }

  Widget _buildTodaysTasksSection() {
    debugPrint(
        'ðŸ“‹ _buildTodaysTasksSection: _availableTasks=${_availableTasks.length}, _completedTasks=${_completedTasks.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Tasks',
          style: JuniorTheme.headingMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        if (_availableTasks.isEmpty && _completedTasks.isEmpty)
          _buildNoTasksMessage()
        else
          _buildTasksList(),
      ],
    );
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      if (mounted) {
        setState(() {
          _books = books;
        });
      }
    } catch (e) {
      debugPrint('Error loading books: $e');
    }
  }

  Future<void> _loadSimulations() async {
    try {
      final simulations =
          await _simulationService.getSimulations(ageGroup: 'bright');
      if (mounted) {
        setState(() {
          _simulations = simulations;
        });
      }
    } catch (e) {
      debugPrint('Error loading simulations: $e');
    }
  }

  Widget _buildBooksSection() {
    final childName = _currentChild?.name ?? 'Student';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$childName\'s Library',
          style: JuniorTheme.headingMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        if (_books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowMedium,
            ),
            child: Center(
              child: Text(
                'Loading books...',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Semantics(
                  label: 'Book: ${book.title}',
                  child: BookCard(
                    book: book,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookReaderScreen(book: book),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNoTasksMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48.0,
            color: JuniorTheme.primaryGreen,
          ),
          const SizedBox(height: JuniorTheme.spacingMedium),
          Text(
            'All done for today!',
            style: JuniorTheme.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: JuniorTheme.spacingSmall),
          Text(
            'Great job completing all your tasks!',
            style: JuniorTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    debugPrint(
        'ðŸ“‹ _buildTasksList: Building ${_availableTasks.length} available + ${_completedTasks.length} completed tasks');

    if (_availableTasks.isEmpty && _completedTasks.isEmpty) {
      debugPrint('âš ï¸ _buildTasksList: Both lists are empty!');
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Available tasks
        ..._availableTasks.map((task) {
          debugPrint('ðŸ“‹ Rendering task: ${task.title}');
          return Padding(
            padding: const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
            child: JuniorTaskCard(
              lesson: task,
              onPlay: () => _playTask(task),
              isCompleted: false,
              isLocked: false,
            ),
          );
        }),

        // Completed tasks
        ..._completedTasks.map((task) {
          debugPrint('ðŸ“‹ Rendering completed task: ${task.title}');
          return Padding(
            padding: const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
            child: JuniorTaskCard(
              lesson: task,
              onPlay: () => _playTask(task),
              isCompleted: true,
              isLocked: false,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAchievementsScreen() {
    // Empty notification/achievements page
    return const SizedBox.shrink();
  }

  Widget _buildAchievementBadges() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        color: JuniorTheme.backgroundCard,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: Column(
        children: [
          Text(
            'Badges Earned',
            style: JuniorTheme.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: JuniorTheme.spacingMedium),

          // Achievement grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: JuniorTheme.spacingSmall,
            mainAxisSpacing: JuniorTheme.spacingSmall,
            children: [
              _buildAchievementBadge(
                  'ðŸŽ¯', 'First Task', 'Complete your first lesson'),
              _buildAchievementBadge(
                  'â­', 'Math Star', 'Complete 5 math lessons'),
              _buildAchievementBadge(
                  'ðŸ“š', 'Reader', 'Complete 3 reading lessons'),
              _buildAchievementBadge(
                  'ðŸŽ¨', 'Artist', 'Complete 2 art lessons'),
              _buildAchievementBadge(
                  'ðŸ”¬', 'Scientist', 'Complete 2 science lessons'),
              _buildAchievementBadge(
                  'ðŸ†', 'Champion', 'Complete 10 lessons total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
      String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(JuniorTheme.spacingSmall),
      decoration: BoxDecoration(
        color: JuniorTheme.primaryYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
        border: Border.all(
          color: JuniorTheme.primaryYellow,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32.0),
          ),
          const SizedBox(height: JuniorTheme.spacingXSmall),
          Text(
            title,
            style: JuniorTheme.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      decoration: BoxDecoration(
        gradient: JuniorTheme.primaryGradient,
        borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        boxShadow: JuniorTheme.shadowMedium,
      ),
      child: Column(
        children: [
          Text(
            'Your Progress',
            style: JuniorTheme.headingSmall.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: JuniorTheme.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('ðŸ“š', '${_completedTasks.length}', 'Lessons'),
              _buildStatItem(
                  'â­', '${_childProgress?.earnedPoints ?? 0}', 'XP'),
              _buildStatItem('ðŸ”¥', '7', 'Day Streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: JuniorTheme.spacingXSmall),
        Text(
          value,
          style: JuniorTheme.headingMedium.copyWith(
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: JuniorTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGamesScreen() {
    return _buildGamesGrid();
  }

  Widget _buildGamesGrid() {
    return Padding(
      padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
      child: Column(
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingMedium),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowLight,
            ),
            child: Text(
              'Math Adventures!',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: JuniorTheme.spacingLarge),

          // Games grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: JuniorTheme.spacingMedium,
              mainAxisSpacing: JuniorTheme.spacingMedium,
              childAspectRatio: 0.8,
              children: [
                _buildGameCategoryCard(
                  title: 'Math Adventures',
                  subtitle: '5 Games',
                  icon: 'ðŸ§®',
                  color: JuniorTheme.primaryBlue,
                  onTap: () => _navigateToCategory('Math Adventures'),
                ),
                _buildGameCategoryCard(
                  title: 'Reading Adventures',
                  subtitle: '5 Games',
                  icon: 'ðŸ“š',
                  color: JuniorTheme.primaryPurple,
                  onTap: () => _navigateToCategory('Reading Adventures'),
                ),
                _buildGameCategoryCard(
                  title: 'Science Adventures',
                  subtitle: '5 Games',
                  icon: 'ðŸ”¬',
                  color: JuniorTheme.primaryOrange,
                  onTap: () => _navigateToCategory('Science Adventures'),
                ),
                _buildGameCategoryCard(
                  title: 'Number Hunt',
                  subtitle: '3 Games',
                  icon: 'ðŸ”',
                  color: JuniorTheme.primaryYellow,
                  onTap: () => _navigateToCategory('Number Hunt'),
                ),
                _buildGameCategoryCard(
                  title: 'Koala Jumps',
                  subtitle: '3 Games',
                  icon: 'ðŸ¨',
                  color: JuniorTheme.primaryGreen,
                  onTap: () => _navigateToCategory('Koala Jumps'),
                ),
                _buildGameCategoryCard(
                  title: 'Pattern Wizard',
                  subtitle: '5 Games',
                  icon: 'ðŸª„',
                  color: JuniorTheme.primaryPink,
                  onTap: () => _navigateToCategory('Pattern Wizard'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCategoryCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _playClickSound();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
          border: Border.all(
            color: color,
            width: 2.0,
          ),
          boxShadow: JuniorTheme.shadowMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(JuniorTheme.radiusCircular),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),

            const SizedBox(height: JuniorTheme.spacingMedium),

            // Title
            Text(
              title,
              style: JuniorTheme.headingSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: JuniorTheme.spacingXSmall),

            // Subtitle
            Text(
              subtitle,
              style: JuniorTheme.bodySmall.copyWith(
                color: JuniorTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: JuniorTheme.spacingMedium),

            // Play button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingMedium,
                vertical: JuniorTheme.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
                boxShadow: JuniorTheme.shadowLight,
              ),
              child: Text(
                'Start',
                style: JuniorTheme.buttonText.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(String category) {
    _playClickSound();
    switch (category) {
      case 'Math Adventures':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MathAdventuresGamesScreen(),
          ),
        );
        break;
      case 'Reading Adventures':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReadingAdventuresGamesScreen(),
          ),
        );
        break;
      case 'Science Adventures':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ScienceAdventuresGamesScreen(),
          ),
        );
        break;
      case 'Number Hunt':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NumberHuntGamesScreen(),
          ),
        );
        break;
      case 'Koala Jumps':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const KoalaJumpsGamesScreen(),
          ),
        );
        break;
      case 'Pattern Wizard':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PatternWizardGamesScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $category games...'),
            backgroundColor: JuniorTheme.primaryGreen,
          ),
        );
    }
  }

  Widget _buildRewardsScreen() {
    // Empty rewards page
    return const SizedBox.shrink();
  }

  void _handleBottomNavTap(int index) {
    _playClickSound();
    setState(() {
      // Map: 0 = Home, 1 = Notifications (Achievements), 2 = Rewards
      _currentBottomNavIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentBottomNavIndex) {
      case 0: // Home - Dashboard
        return Column(
          children: [
            _buildDailyTasksProgress(),
            const SizedBox(height: JuniorTheme.spacingLarge),
            _buildTodaysTasksSection(),
            const SizedBox(height: JuniorTheme.spacingLarge),
            _buildSimulationsSection(),
            const SizedBox(height: JuniorTheme.spacingLarge),
            _buildBooksSection(),
          ],
        );
      case 1: // Notifications - Show Achievements
        return _buildAchievementsScreen();
      case 2: // Rewards - Show Rewards screen
        return _buildRewardsScreen();
      default:
        return Column(
          children: [
            _buildDailyTasksProgress(),
            const SizedBox(height: JuniorTheme.spacingLarge),
            _buildTodaysTasksSection(),
            const SizedBox(height: JuniorTheme.spacingLarge),
            _buildSimulationsSection(),
            const SizedBox(height: JuniorTheme.spacingLarge),
            _buildBooksSection(),
          ],
        );
    }
  }

  Widget _buildSimulationsSection() {
    final childName = _currentChild?.name ?? 'Student';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Interactive Simulations',
              style: JuniorTheme.headingMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: JuniorTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.science,
                    size: 14,
                    color: JuniorTheme.primaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PhET',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: JuniorTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Text(
          'Explore science concepts through interactive experiments',
          style: JuniorTheme.bodySmall.copyWith(
            color: JuniorTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        if (_simulations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
            decoration: BoxDecoration(
              color: JuniorTheme.backgroundCard,
              borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
              boxShadow: JuniorTheme.shadowMedium,
            ),
            child: Center(
              child: Text(
                'Loading simulations...',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _simulations.length,
            itemBuilder: (context, index) {
              final simulation = _simulations[index];
              final colors = [
                const Color(0xFF5B9BD5), // Blue
                const Color(0xFFFDB462), // Orange
                JuniorTheme.primaryGreen,
                JuniorTheme.primaryPurple,
              ];
              final color = colors[index % colors.length];

              return Semantics(
                label: 'Simulation: ${simulation.title}',
                child: SimulationCard(
                  simulation: simulation,
                  color: color,
                  onTap: () {
                    _playClickSound();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SimulationDetailScreen(
                          simulation: simulation,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Lesson _lessonFromActivity(Activity activity) {
    final exerciseType = _mapExerciseType(activity);
    final mappedGameType = _mapMappedGameType(exerciseType);
    final questionIds = activity.questions.map((q) => q.id).toList();
    final ageLabel = activity.ageGroup == AgeGroup.junior ? '6-8' : '9-12';

    return Lesson(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      ageGroupTarget: [ageLabel],
      exerciseType: exerciseType,
      mappedGameType: mappedGameType,
      rewardPoints: activity.points,
      subject: activity.subject.name.toLowerCase(),
      difficulty: activity.difficulty.name,
      learningObjectives: activity.learningObjectives,
      skills: activity.skills,
      content: {
        'questionTemplateIds': questionIds,
        'templateCount': questionIds.length,
        'questionCount': activity.questions.length,
        'activityId': activity.id,
      },
      isActive: activity.published,
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
      metadata: {
        'activityId': activity.id,
      },
    );
  }

  ExerciseType _mapExerciseType(Activity activity) {
    if (activity.questions.any((q) => q.type == QuestionType.dragDrop)) {
      return ExerciseType.puzzle;
    }

    if (activity.questions.any((q) =>
        q.type == QuestionType.matching || q.type == QuestionType.sequencing)) {
      return ExerciseType.flashcard;
    }

    return ExerciseType.multipleChoice;
  }

  MappedGameType _mapMappedGameType(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.puzzle:
        return MappedGameType.dragDrop;
      case ExerciseType.flashcard:
        return MappedGameType.tapGame;
      case ExerciseType.multipleChoice:
        return MappedGameType.quizGame;
    }
  }

  void _playTask(Lesson task) {
    // Launch the game
    _gameLauncher.launchGame(
      context: context,
      lesson: task,
    );
  }

  void _showTaskCompletionCelebration(Lesson task) {
    setState(() {
      _showCelebration = true;
    });
  }

  void _showTaskStartMessage(Lesson task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64.0,
              color: JuniorTheme.primaryGreen,
            ),
            const SizedBox(height: JuniorTheme.spacingMedium),
            Text(
              'Ready to start?',
              style: JuniorTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingSmall),
            Text(
              task.title,
              style: JuniorTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _playClickSound();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JuniorTheme.spacingMedium,
                      vertical: JuniorTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryPink,
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusMedium),
                    ),
                    child: const Text(
                      'Not Now',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    // Start the task
                    _playClickSound();
                    _startTask(task);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JuniorTheme.spacingMedium,
                      vertical: JuniorTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryGreen,
                      borderRadius:
                          BorderRadius.circular(JuniorTheme.radiusMedium),
                    ),
                    child: const Text(
                      'Let\'s Go!',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startTask(Lesson task) {
    // This would typically navigate to the actual lesson/game screen
    // For now, we'll just show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${task.title}...'),
        backgroundColor: JuniorTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Build logout button with accessibility standards for bright children
  /// WCAG 2.1 compliant: minimum 44x44 point touch target (7-10mm)
  Widget _buildLogoutButton() {
    return Semantics(
      label: 'Log out and return to login screen',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
          // Minimum touch target size: 44x44 points (WCAG 2.1)
          // Adding padding to ensure adequate touch area
          child: Container(
            width: 56, // Large enough for children (44+ padding)
            height: 56, // Large enough for children (44+ padding)
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.logout,
                color: Colors.white,
                size: 28, // Clear visual size for children
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle logout process with confirmation for bright children
  Future<void> _handleLogout() async {
    _playClickSound();
    // Show confirmation dialog to prevent accidental logout
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Require explicit choice
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: JuniorTheme.primaryOrange,
              size: 28,
            ),
            const SizedBox(width: JuniorTheme.spacingSmall),
            Text(
              'Log Out?',
              style: JuniorTheme.headingSmall,
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: JuniorTheme.bodyMedium,
        ),
        actions: [
          // Cancel button (large touch target)
          TextButton(
            onPressed: () {
              _playClickSound();
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 48), // Large touch target
              padding: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingMedium,
                vertical: JuniorTheme.spacingSmall,
              ),
            ),
            child: Text(
              'No, Stay',
              style: JuniorTheme.buttonText.copyWith(
                color: JuniorTheme.primaryPink,
              ),
            ),
          ),
          // Confirm button (large touch target)
          ElevatedButton(
            onPressed: () {
              _playClickSound();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JuniorTheme.primaryOrange,
              minimumSize: const Size(100, 48), // Large touch target
              padding: const EdgeInsets.symmetric(
                horizontal: JuniorTheme.spacingMedium,
                vertical: JuniorTheme.spacingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
              ),
            ),
            child: Text(
              'Yes, Log Out',
              style: JuniorTheme.buttonText.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();

        if (mounted) {
          // Navigate to login screen
          context.go(RouteNames.login);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

/// Custom painter for white content area with a single smooth, ROUND dip
/// and rounded top corners.
class NotchedWhitePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // The Y-level of the "flat" parts of the top edge
    final double topEdgeY = 50.0;

    // The depth of the central dip
    final double dipDepth = 20.0;

    // The radius for the top-left and top-right corners
    final double cornerRadius = 30.0;

    // Define the dip's coordinates
    final double dipStartX = size.width * 0.35;
    final double dipEndX = size.width * 0.65;
    final double dipCenterX = size.width * 0.5;
    final double dipBottomY = topEdgeY + dipDepth;

    // --- Bezier control points for a ROUND dip (use cubic for smooth roundness) ---
    // Control points are chosen such that they make a circular arc in the dip.

    // For left dip
    final double cp1X = dipStartX + (dipCenterX - dipStartX) * 0.32;
    final double cp1Y = topEdgeY;
    final double cp2X = dipCenterX - (dipCenterX - dipStartX) * 0.32;
    final double cp2Y = dipBottomY;

    // For right dip
    final double cp3X = dipCenterX + (dipEndX - dipCenterX) * 0.32;
    final double cp3Y = dipBottomY;
    final double cp4X = dipEndX - (dipEndX - dipCenterX) * 0.32;
    final double cp4Y = topEdgeY;

    final path = Path();

    // Start from the bottom-left corner and go up
    path.moveTo(0, size.height);
    path.lineTo(0, topEdgeY + cornerRadius);

    // Top-left rounded corner
    path.quadraticBezierTo(
      0,
      topEdgeY,
      cornerRadius,
      topEdgeY,
    );

    // Flat left part to dip
    path.lineTo(dipStartX, topEdgeY);

    // Smooth, ROUND dip using cubic Bezier curves
    path.cubicTo(
      cp1X, cp1Y, // control point 1 (left going down)
      cp2X, cp2Y, // control point 2 (left bottom side of dip)
      dipCenterX, dipBottomY, // tip of dip
    );
    path.cubicTo(
      cp3X, cp3Y, // control point 1 (right bottom side of dip)
      cp4X, cp4Y, // control point 2 (right coming up)
      dipEndX, topEdgeY, // back on top flat
    );

    // Flat right part
    path.lineTo(size.width - cornerRadius, topEdgeY);

    // Top-right rounded corner
    path.quadraticBezierTo(
      size.width,
      topEdgeY,
      size.width,
      topEdgeY + cornerRadius,
    );

    // Down right edge to bottom
    path.lineTo(size.width, size.height);

    // Close the path (draw the bottom edge)
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom clipper for white content area with a single smooth, ROUND dip
/// and rounded top corners. Matches the shape of NotchedWhitePainter.
class NotchedDividerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // The Y-level of the "flat" parts of the top edge
    final double topEdgeY = 50.0;

    // The depth of the central dip
    final double dipDepth = 20.0;

    // The radius for the top-left and top-right corners
    final double cornerRadius = 30.0;

    // Define the dip's coordinates
    final double dipStartX = size.width * 0.35;
    final double dipEndX = size.width * 0.65;
    final double dipCenterX = size.width * 0.5;
    final double dipBottomY = topEdgeY + dipDepth;

    // --- Bezier control points for a ROUND dip (use cubic for smooth roundness) ---
    // Control points are chosen such that they make a circular arc in the dip.

    // For left dip
    final double cp1X = dipStartX + (dipCenterX - dipStartX) * 0.32;
    final double cp1Y = topEdgeY;
    final double cp2X = dipCenterX - (dipCenterX - dipStartX) * 0.32;
    final double cp2Y = dipBottomY;

    // For right dip
    final double cp3X = dipCenterX + (dipEndX - dipCenterX) * 0.32;
    final double cp3Y = dipBottomY;
    final double cp4X = dipEndX - (dipEndX - dipCenterX) * 0.32;
    final double cp4Y = topEdgeY;

    final path = Path();

    // Start from the bottom-left corner and go up
    path.moveTo(0, size.height);
    path.lineTo(0, topEdgeY + cornerRadius);

    // Top-left rounded corner
    path.quadraticBezierTo(
      0,
      topEdgeY,
      cornerRadius,
      topEdgeY,
    );

    // Flat left part to dip
    path.lineTo(dipStartX, topEdgeY);

    // Smooth, ROUND dip using cubic Bezier curves
    path.cubicTo(
      cp1X, cp1Y, // control point 1 (left going down)
      cp2X, cp2Y, // control point 2 (left bottom side of dip)
      dipCenterX, dipBottomY, // tip of dip
    );
    path.cubicTo(
      cp3X, cp3Y, // control point 1 (right bottom side of dip)
      cp4X, cp4Y, // control point 2 (right coming up)
      dipEndX, topEdgeY, // back on top flat
    );

    // Flat right part
    path.lineTo(size.width - cornerRadius, topEdgeY);

    // Top-right rounded corner
    path.quadraticBezierTo(
      size.width,
      topEdgeY,
      size.width,
      topEdgeY + cornerRadius,
    );

    // Down right edge to bottom
    path.lineTo(size.width, size.height);

    // Close the path (draw the bottom edge)
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
