import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/screen_time_limit_provider.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../models/lesson.dart';
import '../../models/children_progress.dart';
import '../../models/screen_time_limit_settings.dart';
import '../../design_system/junior_theme.dart';
// Services removed for mock data demonstration
import '../../widgets/junior/junior_avatar_widget.dart';
import '../../widgets/junior/junior_task_card.dart';
import '../../widgets/junior/junior_progress_bar.dart';
import '../../widgets/junior/junior_bottom_navigation.dart';
import '../../widgets/junior/junior_confetti.dart';
import '../../widgets/question_template_exporter.dart';
import '../../widgets/screen_time_limit_popup.dart';
import '../../services/activity_session_service.dart';
import '../../services/junior_games_service.dart';
import '../../services/junior_game_launcher.dart';
import '../../services/simple_template_service.dart';
import '../../services/activity_session_service.dart';
import '../../navigation/route_names.dart';
import 'games/number_hunt_games.dart';
import 'games/koala_jumps_games.dart';
import 'games/pattern_wizard_games.dart';
import 'games/math_adventures_games.dart';
import 'games/reading_adventures_games.dart';
import 'games/science_adventures_games.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../widgets/book_card.dart';
import '../child/book_reader_screen.dart';
import 'package:go_router/go_router.dart';
import '../../models/web_game.dart';
import '../../services/web_game_service.dart';
import '../../widgets/junior/web_game_card.dart';
import 'web_game_detail_screen.dart';
import '../safety/safe_search_screen.dart';
import '../safety/wellbeing_check_screen.dart';
import '../child/child_messages_screen.dart';
import '../../widgets/screen_time_limit_popup.dart';

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
  final JuniorGamesService _gamesService = JuniorGamesService();
  final JuniorGameLauncher _gameLauncher = JuniorGameLauncher();
  final SimpleTemplateService _templateService = SimpleTemplateService();
  final ActivitySessionService _activitySessionService =
      ActivitySessionService();

  List<Lesson> _todaysTasks = [];
  List<Lesson> _completedTasks = [];
  List<Lesson> _availableTasks = [];
  ChildrenProgress? _childProgress;
  ChildProfile? _currentChild;
  bool _loading = false;
  String? _error;
  int _currentBottomNavIndex = 0; // Home is active by default
  bool _showCelebration = false;
  bool _screenLimitDialogShown = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<Book> _books = [];
  final BookService _bookService = BookService();
  List<WebGame> _scienceWebGames = [];
  List<WebGame> _mathWebGames = [];
  List<WebGame> _englishWebGames = [];
  final WebGameService _webGameService = WebGameService();

  // Category filter states
  String _selectedScienceCategory = 'All';
  String _selectedMathCategory = 'All';
  String _selectedEnglishCategory = 'All';

  // Audio player for background music
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Audio player for click sounds
  final AudioPlayer _clickSoundPlayer = AudioPlayer();
  // Audio player dedicated to the back-to-dashboard reward cue
  final AudioPlayer _rewardSoundPlayer = AudioPlayer();
  // Audio player for the welcome voiceover cue
  final AudioPlayer _voiceoverPlayer = AudioPlayer();
  // Background music state
  bool _isMusicMuted = false;
  final double _backgroundMusicVolume = 0.7;
  StreamSubscription<ScreenTimeLimitSettings>? _screenTimeSub;

  // Animation bookkeeping for the coin counter
  int _coinAnimationStartValue = 0;
  int _coinAnimationTargetValue = 0;
  int _coinAnimationKey = 0;

  String _sanitizeGender(String? gender) {
    if (gender == null) return 'female';
    final normalized = gender.toLowerCase();
    if (normalized == 'male' || normalized == 'boy') return 'male';
    if (normalized == 'female' || normalized == 'girl') return 'female';
    return 'female';
  }

  /// Shows the screen time limit popup when the daily limit is reached
  /// Call this method when your time tracking logic detects the limit has been reached
  void _showScreenTimeLimitPopup() {
    if (_currentChild == null) return;
    final childName = _currentChild!.name;
    // Default to 2 hours (120 minutes) - replace with actual limit from parent settings
    const dailyLimitMinutes = 120;

    ScreenTimeLimitPopup.show(
      context,
      childName: childName,
      dailyLimitMinutes: dailyLimitMinutes,
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
        if (!mounted) return;
        context.go(RouteNames.childSelector);
      },
    );
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
    _loadScienceWebGames();
    _loadMathWebGames();
    _loadEnglishWebGames();
    _animationController.forward();
    _scrollController.addListener(_handleScroll);
    // Start background music
    _playBackgroundMusic();
    // Play welcome voiceover after first frame to ensure assets are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_playWelcomeVoiceover());
      unawaited(_initializeScreenTimeLimit());
    });
  }

  Future<void> _playBackgroundMusic() async {
    try {
      // Configure background music player to use media player mode for proper looping
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer
          .setVolume(_isMusicMuted ? 0 : _backgroundMusicVolume); // Set volume
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

  Future<void> _playRewardSound() async {
    final wasBackgroundPlaying = _audioPlayer.state == PlayerState.playing;
    if (wasBackgroundPlaying) {
      try {
        await _audioPlayer.pause();
      } catch (_) {
        // Ignore pause errors; we'll restart later if needed
      }
    }

    try {
      await _rewardSoundPlayer.stop();
      await _rewardSoundPlayer.setPlayerMode(PlayerMode.lowLatency);

      Future<void> _playSource(String assetPath) async {
        await _rewardSoundPlayer.play(AssetSource(assetPath));
      }

      try {
        await _playSource(
            'audio/sound effects/sound effects/back to dashboard.mp3');
      } catch (_) {
        await _playSource(
            'audio/sound effects/sound effects/back to dashboard.wav');
      }

      try {
        await _rewardSoundPlayer.onPlayerComplete.first
            .timeout(const Duration(seconds: 5));
      } on TimeoutException {
        // Ignore timeout and resume music anyway
      }
    } catch (e) {
      debugPrint('Error playing reward sound: $e');
    } finally {
      if (wasBackgroundPlaying) {
        await _ensureBackgroundMusicPlaying();
      }
    }
  }

  Future<void> _toggleBackgroundMusic() async {
    _playClickSound();
    final targetMuted = !_isMusicMuted;
    try {
      if (targetMuted) {
        await _audioPlayer.setVolume(0);
      } else {
        await _audioPlayer.setVolume(_backgroundMusicVolume);
        if (_audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.resume();
        }
      }
      if (mounted) {
        setState(() => _isMusicMuted = targetMuted);
      }
    } catch (e) {
      debugPrint('Error toggling background music: $e');
    }
  }

  Future<void> _stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  Future<void> _resumeBackgroundMusicIfNeeded() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // ignore stop errors
    }
    await _playBackgroundMusic();
  }

  Future<void> _ensureBackgroundMusicPlaying() async {
    try {
      final state = _audioPlayer.state;
      if (state == PlayerState.playing) {
        return;
      }
      if (state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _playBackgroundMusic();
      }
    } catch (_) {
      await _playBackgroundMusic();
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final newOffset = _scrollController.offset.clamp(0, 160).toDouble();
    if (newOffset != _scrollOffset) {
      setState(() => _scrollOffset = newOffset);
    }
  }

  double get _collapseProgress {
    final progress = _scrollOffset / 140.0;
    if (progress <= 0) return 0;
    if (progress >= 1) return 1;
    return progress;
  }

  ChildrenProgress _progressOrPlaceholder() {
    if (_childProgress != null) {
      return _childProgress!;
    }
    final childId = _currentChild?.id ?? 'local_child';
    return ChildrenProgress(
      id: 'progress_$childId',
      childId: childId,
      completedLessons: const [],
      earnedPoints: 0,
      lastActiveDate: DateTime.now(),
    );
  }

  void _updateCoinAnimationTarget(int newValue, {required bool animate}) {
    if (!animate) {
      _coinAnimationStartValue = newValue;
    } else {
      _coinAnimationStartValue = _coinAnimationTargetValue;
    }
    _coinAnimationTargetValue = newValue;
    _coinAnimationKey++;
  }

  Widget _buildAnimatedCoinValue({
    required TextStyle textStyle,
    required String keyPrefix,
    TextAlign textAlign = TextAlign.center,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$keyPrefix$_coinAnimationKey'),
      tween: Tween<double>(
        begin: _coinAnimationStartValue.toDouble(),
        end: _coinAnimationTargetValue.toDouble(),
      ),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Text(
        value.toInt().toString(),
        style: textStyle,
        textAlign: textAlign,
      ),
    );
  }

  Future<void> _applyMinutesReward({
    required int minutes,
    required String sourceTitle,
  }) async {
    if (minutes <= 0) return;
    final rewardPoints = minutes * 2;
    final baseProgress = _progressOrPlaceholder();
    final updatedProgress = baseProgress.copyWith(
      earnedPoints: baseProgress.earnedPoints + rewardPoints,
      lastActiveDate: DateTime.now(),
    );

    setState(() {
      _childProgress = updatedProgress;
      _updateCoinAnimationTarget(updatedProgress.earnedPoints, animate: true);
    });

    await _playRewardSound();
    debugPrint(
        'Reward applied from $sourceTitle: +$rewardPoints coins (minutes: $minutes)');
    await _recordScreenTimeUsage(minutes);
  }

  Future<void> _openWebGame(WebGame game) async {
    final result = await _pushWithMusicResume<bool>(
      MaterialPageRoute(
        builder: (context) => WebGameDetailScreen(
          game: game,
        ),
      ),
    );
    if (!mounted) return;
    // Only apply reward if game was actually played (result == true)
    if (result == true) {
      _logWebGameSession(game);
      await _applyMinutesReward(
        minutes: game.estimatedMinutes,
        sourceTitle: game.title,
      );
    }
  }

  Future<T?> _pushWithMusicResume<T>(Route<T> route) async {
    final wasPlaying = _audioPlayer.state == PlayerState.playing;
    if (wasPlaying) {
      try {
        await _audioPlayer.stop();
      } catch (_) {}
    }

    final result = await Navigator.of(context).push(route);

    if (mounted && wasPlaying) {
      await _playBackgroundMusic();
    }
    return result;
  }

  void _logWebGameSession(WebGame game) {
    final authProvider = context.read<AuthProvider>();
    final child = authProvider.currentChild;
    if (child == null) return;
    unawaited(
      _activitySessionService.logSession(
        childId: child.id,
        activityId: game.id,
        title: game.title,
        subject: game.subject,
        durationMinutes: game.estimatedMinutes,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopBackgroundMusic();
    _audioPlayer.dispose();
    _clickSoundPlayer.dispose();
    _rewardSoundPlayer.dispose();
    _voiceoverPlayer.dispose();
    _screenTimeSub?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _playWelcomeVoiceover() async {
    final wasBackgroundPlaying = _audioPlayer.state == PlayerState.playing;
    if (wasBackgroundPlaying) {
      try {
        await _audioPlayer.pause();
      } catch (_) {}
    }
    try {
      await _voiceoverPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _voiceoverPlayer.setReleaseMode(ReleaseMode.stop);
      await _voiceoverPlayer.setVolume(1.0);
      await _voiceoverPlayer.stop();
      await _voiceoverPlayer.play(
        AssetSource('audio/voiceovers/welcome.mp3'),
      );
      await _voiceoverPlayer.onPlayerComplete.first
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      debugPrint('Playing welcome voiceover for junior dashboard');
    } catch (e, stack) {
      debugPrint('Error playing welcome voiceover: $e');
      debugPrint('$stack');
    } finally {
      await _ensureBackgroundMusicPlaying();
    }
  }

  Future<void> _initializeScreenTimeLimit() async {
    final authProvider = context.read<AuthProvider>();
    final child = authProvider.currentChild;
    if (child == null) return;
    await context.read<ScreenTimeLimitProvider>().loadSettings(child.id);
    _subscribeToScreenTimeLimit(child.id);
    if (!mounted) return;
    _maybeShowScreenTimeLimitPopup();
  }

  void _subscribeToScreenTimeLimit(String childId) {
    _screenTimeSub?.cancel();
    if (childId.isEmpty) return;
    final provider = context.read<ScreenTimeLimitProvider>();
    _screenTimeSub = provider.watchSettings(childId).listen((settings) {
      if (!mounted) return;
      if (!settings.shouldLock && _screenLimitDialogShown) {
        Navigator.of(context, rootNavigator: true).maybePop();
        _screenLimitDialogShown = false;
      }
      if (settings.shouldLock) {
        final childName = _currentChild?.name ?? 'Learner';
        _showScreenTimeLimitDialog(settings, childName);
      }
    });
  }

  void _maybeShowScreenTimeLimitPopup() {
    final child = _currentChild;
    if (child == null) return;
    final provider = context.read<ScreenTimeLimitProvider>();
    final settings = provider.settingsFor(child.id);
    if (settings == null) return;
    if (settings.shouldLock) {
      _showScreenTimeLimitDialog(settings, child.name);
    } else {
      _screenLimitDialogShown = false;
    }
  }

  Future<void> _recordScreenTimeUsage(int minutes) async {
    if (minutes <= 0) return;
    final child = _currentChild ?? context.read<AuthProvider>().currentChild;
    if (child == null) return;
    final provider = context.read<ScreenTimeLimitProvider>();
    final updated = await provider.recordUsage(child.id, minutes);
    if (!mounted) return;
    if (updated != null && updated.shouldLock) {
      _showScreenTimeLimitDialog(updated, child.name);
    }
  }

  void _showScreenTimeLimitDialog(
    ScreenTimeLimitSettings settings,
    String childName,
  ) {
    if (_screenLimitDialogShown) return;
    _screenLimitDialogShown = true;
    ScreenTimeLimitPopup.show(
      context,
      childName: childName,
      dailyLimitMinutes: settings.dailyLimitMinutes,
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop();
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
        if (!mounted) return;
        context.go(RouteNames.childSelector);
      },
    );
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

  /// Load games from Firebase question templates
  Future<void> _loadGamesFromTemplates() async {
    try {
      debugPrint('🎮 Loading junior games from Firebase templates...');

      // Load games from question templates
      final games = await _gamesService.loadJuniorGames();

      if (games.isEmpty) {
        debugPrint('⚠️ No games found, using empty list');
        setState(() {
          _todaysTasks = [];
          _availableTasks = [];
          _completedTasks = [];
        });
        return;
      }

      debugPrint('✅ Loaded ${games.length} games from templates');

      // Load child progress to determine completed tasks
      // For now, create a mock progress if not available
      final progress = ChildrenProgress(
        id: 'progress_${_currentChild!.id}',
        childId: _currentChild!.id,
        completedLessons: [], // Start with no completed lessons
        earnedPoints: 0,
        lastActiveDate: DateTime.now(),
      );

      // Categorize tasks
      final completedLessonIds = progress.completedLessons;

      final availableTasks =
          games.where((task) => !completedLessonIds.contains(task.id)).toList();
      final completedTasks =
          games.where((task) => completedLessonIds.contains(task.id)).toList();

      debugPrint(
          '📊 Dashboard: Setting state - Total games: ${games.length}, Available: ${availableTasks.length}, Completed: ${completedTasks.length}');

      setState(() {
        _childProgress = progress;
        _todaysTasks = games;
        _completedTasks = completedTasks;
        _availableTasks = availableTasks;
        _updateCoinAnimationTarget(progress.earnedPoints, animate: false);
      });

      debugPrint(
          '✅ Dashboard: State updated - _todaysTasks: ${_todaysTasks.length}, _availableTasks: ${_availableTasks.length}, _completedTasks: ${_completedTasks.length}');
    } catch (e) {
      debugPrint('❌ Error loading games from templates: $e');
      setState(() {
        _error = 'Error loading games: $e';
        _todaysTasks = [];
        _availableTasks = [];
        _completedTasks = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final screenTimeProvider = context.watch<ScreenTimeLimitProvider>();
    final lockedChildId = _currentChild?.id;
    if (lockedChildId != null) {
      final limitSettings = screenTimeProvider.settingsFor(lockedChildId);
      final shouldLock = limitSettings?.shouldLock ?? false;
      if (shouldLock && !_screenLimitDialogShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showScreenTimeLimitDialog(
            limitSettings!,
            _currentChild?.name ?? 'Explorer',
          );
        });
      } else if (!shouldLock && _screenLimitDialogShown) {
        _screenLimitDialogShown = false;
      }
    }
    final collapseProgress = _collapseProgress;
    final baseTop = height * 0.40 - 50;
    final dynamicTop = math.max(baseTop - 70 * collapseProgress, baseTop - 70);
    // Slight movement on scroll (small parallax) without scaling
    final avatarAlignmentY = -0.60 - 0.18 * collapseProgress;
    final avatarSize = height * 0.15 + 40; // keep size fixed
    final coinYOffset = -10.0 - 5 * collapseProgress;
    final coinLabelTop = 54.0 - 5 * collapseProgress;
    const coinScale = 1.0;

    // For Messages (Notifications), show full-screen content with navbar
    if (_currentBottomNavIndex == 1) {
      return Scaffold(
        backgroundColor: JuniorTheme.backgroundLight,
        body: Stack(
          children: [
            // Full-screen content for Messages
            Positioned.fill(
              bottom: 80, // Leave space for nav bar
              child: const ChildMessagesScreen(),
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
                      icon: Icons.mail,
                      activeIcon: Icons.mail,
                      label: 'Messages',
                    ),
                    JuniorNavigationItem(
                      icon: Icons.public,
                      activeIcon: Icons.public,
                      label: 'Search',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For Search, show full-screen content with navbar
    if (_currentBottomNavIndex == 2) {
      return Scaffold(
        backgroundColor: JuniorTheme.backgroundLight,
        body: Stack(
          children: [
            // Full-screen content for Search
            Positioned.fill(
              bottom: 80, // Leave space for nav bar
              child: SafeArea(
                bottom: false,
                child: SafeSearchScreen(childId: _currentChild?.id),
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
                      icon: Icons.mail,
                      activeIcon: Icons.mail,
                      label: 'Messages',
                    ),
                    JuniorNavigationItem(
                      icon: Icons.public,
                      activeIcon: Icons.public,
                      label: 'Search',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default Home dashboard layout
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
                // Mute button in top-left corner (mirrors logout style)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: JuniorTheme.spacingXSmall,
                        left: JuniorTheme.spacingMedium,
                        right: JuniorTheme.spacingMedium,
                        bottom: JuniorTheme.spacingMedium,
                      ),
                      child: _buildMuteButton(),
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
                  alignment: Alignment(0, avatarAlignmentY),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: JuniorAvatarWidget(
                          childId: _currentChild?.id ?? '',
                          size: avatarSize,
                          gender: _sanitizeGender(_currentChild?.gender),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Transform.translate(
                        offset: Offset(0, coinYOffset),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            _buildAnimatedCoinValue(
                              keyPrefix: 'hero_',
                              textStyle: JuniorTheme.headingLarge.copyWith(
                                color: JuniorTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 52 * coinScale,
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
                              top: coinLabelTop,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: JuniorTheme.accentGold,
                                    size: 20 * coinScale,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'coins collected',
                                    textAlign: TextAlign.center,
                                    style: JuniorTheme.bodySmall.copyWith(
                                      color: JuniorTheme.textPrimary,
                                      fontSize: 18 * coinScale,
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
            top: dynamicTop, // Start slightly before background ends
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
                    controller: _scrollController,
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
                    icon: Icons.mail,
                    activeIcon: Icons.mail,
                    label: 'Messages',
                  ),
                  JuniorNavigationItem(
                    icon: Icons.public,
                    activeIcon: Icons.public,
                    label: 'Search',
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
          style: JuniorTheme.headingMedium,
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
          _buildAnimatedCoinValue(
            keyPrefix: 'card_',
            textStyle: JuniorTheme.headingLarge.copyWith(
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
        '📋 _buildTodaysTasksSection: _availableTasks=${_availableTasks.length}, _completedTasks=${_completedTasks.length}');

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

  Future<void> _loadScienceWebGames() async {
    try {
      final games = await _webGameService.getWebGames(
          ageGroup: 'junior', subject: 'science');
      if (mounted) {
        setState(() {
          _scienceWebGames = games;
        });
      }
    } catch (e) {
      debugPrint('Error loading science web games: $e');
    }
  }

  Future<void> _loadMathWebGames() async {
    try {
      final games = await _webGameService.getWebGames(
          ageGroup: 'junior', subject: 'math');
      if (mounted) {
        setState(() {
          _mathWebGames = games;
        });
      }
    } catch (e) {
      debugPrint('Error loading math web games: $e');
    }
  }

  Future<void> _loadEnglishWebGames() async {
    try {
      final games = await _webGameService.getWebGames(
          ageGroup: 'junior', subject: 'english');
      if (mounted) {
        setState(() {
          _englishWebGames = games;
        });
      }
    } catch (e) {
      debugPrint('Error loading english web games: $e');
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
            height: 240, // Increased height for better visibility
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8), // Extra bottom padding
                  child: Semantics(
                    label: 'Book: ${book.title}',
                    child: BookCard(
                      book: book,
                      onTap: () async {
                        await _pushWithMusicResume(
                          MaterialPageRoute(
                            builder: (context) => BookReaderScreen(book: book),
                          ),
                        );
                      },
                    ),
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
        '📋 _buildTasksList: Building ${_availableTasks.length} available + ${_completedTasks.length} completed tasks');

    if (_availableTasks.isEmpty && _completedTasks.isEmpty) {
      debugPrint('⚠️ _buildTasksList: Both lists are empty!');
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Available tasks
        ..._availableTasks.map((task) {
          debugPrint('📋 Rendering task: ${task.title}');
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
          debugPrint('📋 Rendering completed task: ${task.title}');
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
    // Messages from teachers screen
    return const ChildMessagesScreen();
  }

  Future<void> _exportQuestionsFromDatabase() async {
    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Use SimpleTemplateService to fetch templates (handles permissions better)
      final templates = await _templateService.getAllTemplates();

      if (templates.isEmpty) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions found in the database'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Convert templates to JSON-serializable format
      final List<Map<String, dynamic>> questionsData = [];

      for (final template in templates) {
        // Convert template to JSON
        final templateJson = template.toJson();

        // Ensure id is included
        final convertedData = <String, dynamic>{
          'id': template.id,
          ...templateJson,
        };

        questionsData.add(convertedData);
      }

      // Create the export object
      final exportData = {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'totalTemplates': questionsData.length,
          'source': 'curriculumQuestionTemplates',
        },
        'templates': questionsData,
      };

      // Convert to JSON with pretty printing
      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Exported ${questionsData.length} questions! JSON copied to clipboard.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        String errorMessage = 'Error exporting questions';
        if (e.code == 'permission-denied') {
          errorMessage =
              'Permission denied. You need to be logged in as a teacher to export questions.';
        } else {
          errorMessage = 'Error: ${e.message ?? e.code}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('Error exporting questions: $e');
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error exporting questions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      debugPrint('Error exporting questions: $e');
    }
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

  Future<void> _navigateToCategory(String category) async {
    _playClickSound();
    switch (category) {
      case 'Math Adventures':
        await _pushWithMusicResume(
          MaterialPageRoute(
            builder: (context) => const MathAdventuresGamesScreen(),
          ),
        );
        break;
      case 'Reading Adventures':
        await _pushWithMusicResume(
          MaterialPageRoute(
            builder: (context) => const ReadingAdventuresGamesScreen(),
          ),
        );
        break;
      case 'Science Adventures':
        await _pushWithMusicResume(
          MaterialPageRoute(
            builder: (context) => const ScienceAdventuresGamesScreen(),
          ),
        );
        break;
      case 'Number Hunt':
        await _pushWithMusicResume(
          MaterialPageRoute(
            builder: (context) => const NumberHuntGamesScreen(),
          ),
        );
        break;
      case 'Koala Jumps':
        await _pushWithMusicResume(
          MaterialPageRoute(
            builder: (context) => const KoalaJumpsGamesScreen(),
          ),
        );
        break;
      case 'Pattern Wizard':
        await _pushWithMusicResume(
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
      // Map: 0 = Home, 1 = Notifications (Achievements), 2 = Search
      _currentBottomNavIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
    // Handle Home and Notifications (Search is handled in build())
    if (_currentBottomNavIndex == 1) {
      return _buildAchievementsScreen();
    }
    // Default: Home dashboard content
    return Column(
      children: [
        _buildDailyTasksProgress(),
        const SizedBox(height: JuniorTheme.spacingLarge),
        // Wellbeing Check Widget
        WellbeingCheckWidget(
          onTap: () {
            _pushWithMusicResume(
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: WellbeingCheckScreen(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: JuniorTheme.spacingLarge),
        _buildTodaysTasksSection(),
        const SizedBox(height: JuniorTheme.spacingLarge),
        _buildScienceGamesSection(),
        const SizedBox(height: JuniorTheme.spacingLarge),
        _buildMathGamesSection(),
        const SizedBox(height: JuniorTheme.spacingLarge),
        _buildEnglishGamesSection(),
        const SizedBox(height: JuniorTheme.spacingLarge),
        _buildBooksSection(),
        const SizedBox(
            height: 80), // Extra space at bottom for floating nav bar
      ],
    );
  }

  String _getCategoryIcon(String category) {
    // Science categories
    if (category == 'Living Things') return '🌱';
    if (category == 'Physical Processes') return '⚡';
    if (category == 'Solids, Liquids & Gases') return '💧';

    // Math categories
    if (category == 'Arithmetic Games') return '➕';
    if (category == 'Geometry Games') return '📐';
    if (category == 'Number Games') return '🔢';
    if (category == 'Statistics Games') return '📊';

    // English categories
    if (category == 'Reading Games') return '📖';
    if (category == 'Grammar Games') return '✍️';
    if (category == 'Writing Games') return '📝';
    if (category == 'Word Games') return '🎯';
    if (category == 'Spelling Games') return '🔤';

    // Default
    return '✨';
  }

  Color _getCategoryColor(String category) {
    // Science categories
    if (category == 'Living Things') return JuniorTheme.primaryGreen;
    if (category == 'Physical Processes') return JuniorTheme.primaryOrange;
    if (category == 'Solids, Liquids & Gases') return JuniorTheme.primaryBlue;

    // Math categories
    if (category == 'Arithmetic Games') return JuniorTheme.primaryPurple;
    if (category == 'Geometry Games') return JuniorTheme.primaryBlue;
    if (category == 'Number Games') return JuniorTheme.primaryYellow;
    if (category == 'Statistics Games') return JuniorTheme.primaryPink;

    // English categories
    if (category == 'Reading Games') return JuniorTheme.primaryBlue;
    if (category == 'Grammar Games') return JuniorTheme.primaryPurple;
    if (category == 'Writing Games') return JuniorTheme.primaryOrange;
    if (category == 'Word Games') return JuniorTheme.primaryGreen;
    if (category == 'Spelling Games') return JuniorTheme.primaryPink;

    // Default (All)
    return JuniorTheme.primaryBlue;
  }

  Widget _buildCategoryChips({
    required List<String> categories,
    required String selectedCategory,
    required Function(String) onCategorySelected,
  }) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final categoryColor = _getCategoryColor(category);
          final categoryIcon = _getCategoryIcon(category);

          return AnimatedContainer(
            duration: JuniorTheme.animationFast,
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onCategorySelected(category);
                  _playClickSound();
                },
                borderRadius: BorderRadius.circular(JuniorTheme.radiusLarge),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              categoryColor.withOpacity(0.8),
                              categoryColor.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : JuniorTheme.backgroundCard,
                    borderRadius:
                        BorderRadius.circular(JuniorTheme.radiusLarge),
                    border: Border.all(
                      color: isSelected
                          ? categoryColor
                          : JuniorTheme.textLight.withOpacity(0.3),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : JuniorTheme.shadowLight,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category != 'All') ...[
                        Text(
                          categoryIcon,
                          style: TextStyle(
                            fontSize: isSelected ? 18 : 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: isSelected ? 15 : 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : JuniorTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScienceGamesSection() {
    final filteredGames = _webGameService.filterGamesByCategory(
      _scienceWebGames,
      _selectedScienceCategory == 'All' ? null : _selectedScienceCategory,
    );
    final categories = _webGameService.getCategoriesForSubject('science');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactive Science Games',
          style: JuniorTheme.headingMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Text(
          'Play fun games to learn about nature!',
          style: JuniorTheme.bodyLarge.copyWith(
            color: JuniorTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        _buildCategoryChips(
          categories: categories,
          selectedCategory: _selectedScienceCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedScienceCategory = category;
            });
          },
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        if (_scienceWebGames.isEmpty)
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
                'Loading games...',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (filteredGames.isEmpty)
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
                'No games found in this category.',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return SizedBox(
                  width: 260,
                  child: Semantics(
                    label: 'Game: ${game.title}',
                    child: WebGameCard(
                      game: game,
                      onTap: () async {
                        _playClickSound();
                        await _openWebGame(game);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMathGamesSection() {
    final filteredGames = _webGameService.filterGamesByCategory(
      _mathWebGames,
      _selectedMathCategory == 'All' ? null : _selectedMathCategory,
    );
    final categories = _webGameService.getCategoriesForSubject('math');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactive Math Games',
          style: JuniorTheme.headingMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Text(
          'Play fun games to master math skills!',
          style: JuniorTheme.bodyLarge.copyWith(
            color: JuniorTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        _buildCategoryChips(
          categories: categories,
          selectedCategory: _selectedMathCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedMathCategory = category;
            });
          },
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        if (_mathWebGames.isEmpty)
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
                'Loading games...',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (filteredGames.isEmpty)
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
                'No games found in this category.',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return SizedBox(
                  width: 260,
                  child: Semantics(
                    label: 'Game: ${game.title}',
                    child: WebGameCard(
                      game: game,
                      onTap: () async {
                        _playClickSound();
                        await _openWebGame(game);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEnglishGamesSection() {
    final filteredGames = _webGameService.filterGamesByCategory(
      _englishWebGames,
      _selectedEnglishCategory == 'All' ? null : _selectedEnglishCategory,
    );
    final categories = _webGameService.getCategoriesForSubject('english');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactive English Games',
          style: JuniorTheme.headingMedium,
        ),
        const SizedBox(height: JuniorTheme.spacingSmall),
        Text(
          'Play fun games to improve your English skills!',
          style: JuniorTheme.bodyLarge.copyWith(
            color: JuniorTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        _buildCategoryChips(
          categories: categories,
          selectedCategory: _selectedEnglishCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedEnglishCategory = category;
            });
          },
        ),
        const SizedBox(height: JuniorTheme.spacingMedium),
        if (_englishWebGames.isEmpty)
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
                'Loading games...',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (filteredGames.isEmpty)
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
                'No games found in this category.',
                style: JuniorTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return SizedBox(
                  width: 260,
                  child: Semantics(
                    label: 'Game: ${game.title}',
                    child: WebGameCard(
                      game: game,
                      onTap: () async {
                        _playClickSound();
                        await _openWebGame(game);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _playTask(Lesson task) async {
    final wasPlaying = _audioPlayer.state == PlayerState.playing;
    if (wasPlaying) {
      try {
        await _audioPlayer.stop();
      } catch (_) {}
    }
    await _gameLauncher.launchGame(
      context: context,
      lesson: task,
      onGameClosed: _resumeBackgroundMusicIfNeeded,
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

  /// Build logout button with accessibility standards for junior children
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

  /// Build mute toggle button with same styling as logout
  Widget _buildMuteButton() {
    return Semantics(
      label: _isMusicMuted
          ? 'Unmute background music'
          : 'Mute background music',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleBackgroundMusic,
          borderRadius: BorderRadius.circular(JuniorTheme.radiusMedium),
          child: Container(
            width: 56,
            height: 56,
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
                _isMusicMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle logout process with confirmation for junior children
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
