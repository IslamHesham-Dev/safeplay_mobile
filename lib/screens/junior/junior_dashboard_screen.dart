import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../models/lesson.dart';
import '../../models/children_progress.dart';
import '../../design_system/junior_theme.dart';
// Services removed for mock data demonstration
import '../../widgets/junior/junior_avatar_widget.dart';
import '../../widgets/junior/junior_task_card.dart';
import '../../widgets/junior/junior_progress_bar.dart';
import '../../widgets/junior/junior_bottom_navigation.dart';
import '../../widgets/junior/junior_confetti.dart';
import '../../widgets/question_template_exporter.dart';
import 'games/number_hunt_games.dart';
import 'games/koala_jumps_games.dart';
import 'games/pattern_wizard_games.dart';
import 'games/math_adventures_games.dart';
import 'games/reading_adventures_games.dart';
import 'games/science_adventures_games.dart';
import 'package:go_router/go_router.dart';

/// Junior (6-8) specific dashboard screen with age-appropriate UI
class JuniorDashboardScreen extends StatefulWidget {
  const JuniorDashboardScreen({super.key});

  @override
  State<JuniorDashboardScreen> createState() => _JuniorDashboardScreenState();
}

class _JuniorDashboardScreenState extends State<JuniorDashboardScreen>
    with TickerProviderStateMixin {
  // Services removed for mock data demonstration
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  List<Lesson> _todaysTasks = [];
  List<Lesson> _completedTasks = [];
  List<Lesson> _availableTasks = [];
  ChildrenProgress? _childProgress;
  ChildProfile? _currentChild;
  bool _loading = false;
  String? _error;
  int _currentBottomNavIndex = 0; // Home is active by default
  bool _showCelebration = false;

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
      final currentChild = auth.currentChild;
      ChildProfile? child;

      // Prefer currentUser if type matches, else use currentChild
      if (currentUser != null && currentUser.userType == UserType.juniorChild) {
        child = currentUser as ChildProfile;
      } else if (currentChild != null &&
          currentChild.ageGroup == AgeGroup.junior) {
        child = currentChild;
      }

      if (child == null) {
        setState(() {
          _error = 'No junior child is logged in.';
          _loading = false;
        });
        return;
      }

      _currentChild = child;
      _createMockData(); // keep your demo tasks etc.

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() => _error = e.toString());
      setState(() => _loading = false);
    }
  }

  void _createMockData() {
    // Create mock lessons for today's tasks
    _todaysTasks = [
      Lesson(
        id: 'lesson_1',
        title: 'Count to 10',
        description: 'Learn to count from 1 to 10',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.multipleChoice,
        mappedGameType: MappedGameType.quizGame,
        rewardPoints: 25,
        subject: 'math',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Count numbers 1-10', 'Recognize number symbols'],
        skills: ['counting', 'number recognition'],
        isActive: true,
        createdBy: 'teacher_123',
        metadata: {'color': 'blue'},
      ),
      Lesson(
        id: 'lesson_2',
        title: 'ABC Song',
        description: 'Sing along with the alphabet',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.flashcard,
        mappedGameType: MappedGameType.tapGame,
        rewardPoints: 30,
        subject: 'reading',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Learn alphabet order', 'Letter recognition'],
        skills: ['alphabet', 'singing', 'memory'],
        isActive: true,
        createdBy: 'teacher_123',
        metadata: {'color': 'green'},
      ),
      Lesson(
        id: 'lesson_3',
        title: 'Shapes Puzzle',
        description: 'Match shapes with their names',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.puzzle,
        mappedGameType: MappedGameType.dragDrop,
        rewardPoints: 35,
        subject: 'math',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Identify basic shapes', 'Shape matching'],
        skills: ['shapes', 'matching', 'problem solving'],
        isActive: true,
        createdBy: 'teacher_123',
        metadata: {'color': 'purple'},
      ),
      Lesson(
        id: 'lesson_4',
        title: 'Animal Sounds',
        description: 'Learn what sounds animals make',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.multipleChoice,
        mappedGameType: MappedGameType.quizGame,
        rewardPoints: 20,
        subject: 'science',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Animal identification', 'Sound recognition'],
        skills: ['animals', 'listening', 'memory'],
        isActive: true,
        createdBy: 'teacher_123',
        metadata: {'color': 'orange'},
      ),
      Lesson(
        id: 'lesson_5',
        title: 'Color Mixing',
        description: 'Discover how colors mix together',
        ageGroupTarget: ['6-8'],
        exerciseType: ExerciseType.flashcard,
        mappedGameType: MappedGameType.tapGame,
        rewardPoints: 40,
        subject: 'art',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        learningObjectives: ['Primary colors', 'Color mixing basics'],
        skills: ['colors', 'creativity', 'observation'],
        isActive: true,
        createdBy: 'teacher_123',
        metadata: {'color': 'pink'},
      ),
    ];

    // Create mock progress
    _childProgress = ChildrenProgress(
      id: 'progress_123',
      childId: _currentChild!.id,
      completedLessons: ['lesson_1', 'lesson_2'], // 2 completed
      earnedPoints: 150,
      lastActiveDate: DateTime.now().subtract(const Duration(hours: 2)),
    );

    // Categorize tasks
    final completedLessonIds = _childProgress!.completedLessons;

    _completedTasks = _todaysTasks
        .where((task) => completedLessonIds.contains(task.id))
        .toList();
    _availableTasks = _todaysTasks
        .where((task) => !completedLessonIds.contains(task.id))
        .toList();
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
                              child: Text(
                                '🪙 coins collected',
                                textAlign: TextAlign.center,
                                style: JuniorTheme.bodySmall.copyWith(
                                  color: JuniorTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
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
        Text(
          'Ready for a new adventure today? 🌈✨',
          textAlign: TextAlign.left,
          style: JuniorTheme.bodyLarge.copyWith(
            color: JuniorTheme.primaryOrange,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
          Text(
            '🪙 coins collected',
            style: JuniorTheme.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
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
    return Column(
      children: [
        // Available tasks
        ..._availableTasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
              child: JuniorTaskCard(
                lesson: task,
                onPlay: () => _playTask(task),
                isCompleted: false,
                isLocked: false,
              ),
            )),

        // Completed tasks
        ..._completedTasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: JuniorTheme.spacingSmall),
              child: JuniorTaskCard(
                lesson: task,
                onPlay: () => _playTask(task),
                isCompleted: true,
                isLocked: false,
              ),
            )),
      ],
    );
  }

  Widget _buildAchievementsScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Achievements',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),

            // Achievement badges
            _buildAchievementBadges(),

            const SizedBox(height: JuniorTheme.spacingLarge),

            // Stats summary
            _buildStatsSummary(),

            const SizedBox(height: JuniorTheme.spacingLarge),

            // Developer export button (temporary)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionTemplateExporter(),
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Export Questions to JSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JuniorTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: JuniorTheme.spacingMedium,
                  vertical: JuniorTheme.spacingSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  '🎯', 'First Task', 'Complete your first lesson'),
              _buildAchievementBadge(
                  '⭐', 'Math Star', 'Complete 5 math lessons'),
              _buildAchievementBadge(
                  '📚', 'Reader', 'Complete 3 reading lessons'),
              _buildAchievementBadge('🎨', 'Artist', 'Complete 2 art lessons'),
              _buildAchievementBadge(
                  '🔬', 'Scientist', 'Complete 2 science lessons'),
              _buildAchievementBadge(
                  '🏆', 'Champion', 'Complete 10 lessons total'),
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
              _buildStatItem('📚', '${_completedTasks.length}', 'Lessons'),
              _buildStatItem('⭐', '${_childProgress?.earnedPoints ?? 0}', 'XP'),
              _buildStatItem('🔥', '7', 'Day Streak'),
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
                  icon: '🧮',
                  color: JuniorTheme.primaryBlue,
                  onTap: () => _navigateToCategory('Math Adventures'),
                ),
                _buildGameCategoryCard(
                  title: 'Reading Adventures',
                  subtitle: '5 Games',
                  icon: '📚',
                  color: JuniorTheme.primaryPurple,
                  onTap: () => _navigateToCategory('Reading Adventures'),
                ),
                _buildGameCategoryCard(
                  title: 'Science Adventures',
                  subtitle: '5 Games',
                  icon: '🔬',
                  color: JuniorTheme.primaryOrange,
                  onTap: () => _navigateToCategory('Science Adventures'),
                ),
                _buildGameCategoryCard(
                  title: 'Number Hunt',
                  subtitle: '3 Games',
                  icon: '🔍',
                  color: JuniorTheme.primaryYellow,
                  onTap: () => _navigateToCategory('Number Hunt'),
                ),
                _buildGameCategoryCard(
                  title: 'Koala Jumps',
                  subtitle: '3 Games',
                  icon: '🐨',
                  color: JuniorTheme.primaryGreen,
                  onTap: () => _navigateToCategory('Koala Jumps'),
                ),
                _buildGameCategoryCard(
                  title: 'Pattern Wizard',
                  subtitle: '5 Games',
                  icon: '🪄',
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
      onTap: onTap,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(JuniorTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rewards & Achievements',
              style: JuniorTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: JuniorTheme.spacingLarge),

            // XP Progress
            if (_childProgress != null)
              JuniorXPProgressBar(
                currentXP: _childProgress!.earnedPoints,
                maxXP: 1000, // Example max XP
                label: 'Your Progress',
              ),

            const SizedBox(height: JuniorTheme.spacingLarge),

            // Placeholder for achievements
            Container(
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
                    Icons.emoji_events,
                    size: 48.0,
                    color: JuniorTheme.accentGold,
                  ),
                  const SizedBox(height: JuniorTheme.spacingMedium),
                  Text(
                    'Achievements Coming Soon!',
                    style: JuniorTheme.headingSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: JuniorTheme.spacingSmall),
                  Text(
                    'Keep learning to unlock amazing rewards!',
                    style: JuniorTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
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
          ],
        );
    }
  }

  void _playTask(Lesson task) {
    // Show celebration if task is completed
    if (_completedTasks.contains(task)) {
      _showTaskCompletionCelebration(task);
    } else {
      // Navigate to task/lesson screen
      // This would typically navigate to the actual lesson/game screen
      _showTaskStartMessage(task);
    }
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
                  onTap: () => Navigator.of(context).pop(),
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
