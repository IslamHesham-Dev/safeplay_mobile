import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';

/// Onboarding screen for children - fun, colorful, and engaging
class ChildOnboardingScreen extends StatefulWidget {
  const ChildOnboardingScreen({super.key});

  @override
  State<ChildOnboardingScreen> createState() => _ChildOnboardingScreenState();
}

class _ChildOnboardingScreenState extends State<ChildOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  final AudioPlayer _voiceoverPlayer = AudioPlayer();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to SafePlay! 🎉',
      subtitle: 'Your fun learning adventure starts here!',
      description:
          'Play games, learn new things, and have fun while staying safe online!',
      emoji: '🎮',
      color: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFFB74D),
      features: [
        FeatureItem('🎯', 'Fun Games', 'Play exciting learning games'),
        FeatureItem('🪙', 'Earn Coins', 'Collect coins as you play'),
        FeatureItem('📚', 'Read Books', 'Discover amazing stories'),
      ],
    ),
    OnboardingPage(
      title: 'Choose Your Games 🕹️',
      subtitle: 'Lots of fun activities waiting for you!',
      description:
          'Pick from Science, Math, English, and more! Each subject has fun interactive games.',
      emoji: '📚',
      color: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFBA68C8),
      features: [
        FeatureItem('🔬', 'Science', 'Living things, experiments & more'),
        FeatureItem('🧮', 'Math', 'Numbers, shapes & puzzles'),
        FeatureItem('📖', 'English', 'Reading, spelling & words'),
      ],
      mockupType: MockupType.gameCategories,
    ),
    OnboardingPage(
      title: 'Try Cool Simulations! 🧪',
      subtitle: 'Experiment freely and learn by doing!',
      description:
          'Play with real science simulations! Balance scales, mix states of matter, explore electricity, and more—all by yourself!',
      emoji: '⚗️',
      color: const Color(0xFF00BCD4),
      secondaryColor: const Color(0xFF4DD0E1),
      features: [
        FeatureItem('⚖️', 'Balance Scale', 'Make equations equal'),
        FeatureItem('💧', 'States of Matter',
            'See atoms move in solids, liquids & gases'),
        FeatureItem('⚡', 'Static Electricity', 'Watch charges push and pull'),
      ],
      mockupType: MockupType.simulations,
    ),
    OnboardingPage(
      title: 'Stay Safe Online 🛡️',
      subtitle: 'We keep you protected!',
      description:
          'SafePlay makes sure everything you see and do is safe and fun.',
      emoji: '🔒',
      color: SafePlayColors.brandTeal500,
      secondaryColor: SafePlayColors.brandTeal200,
      features: [
        FeatureItem('✅', 'Safe Content', 'Only kid-friendly stuff'),
        FeatureItem('🌐', 'Safe Search', 'Find cool things safely'),
        FeatureItem('💬', 'Safe Chat', 'Talk with teachers safely'),
      ],
      mockupType: MockupType.safetyFeatures,
    ),
    OnboardingPage(
      title: 'Earn Coins! 🪙',
      subtitle: 'See how awesome you are!',
      description:
          'Complete games to earn coins! The more you play, the more coins you collect.',
      emoji: '🚀',
      color: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF81C784),
      features: [
        FeatureItem('🪙', 'Coins', 'Earn coins for every game'),
        FeatureItem('🎯', 'Goals', 'Complete daily tasks'),
        FeatureItem('⬆️', 'Level Up', 'Get better and grow'),
      ],
      mockupType: MockupType.progressTracking,
    ),
    OnboardingPage(
      title: 'How Are You Feeling? 💖',
      subtitle: 'Tell us how you feel!',
      description:
          'We care about you! Share your feelings and we\'ll help you feel great.',
      emoji: '😊',
      color: const Color(0xFFE91E63),
      secondaryColor: const Color(0xFFF48FB1),
      features: [
        FeatureItem('😄', 'Happy', 'Share your happy moments'),
        FeatureItem('🤔', 'Thinking', 'It\'s okay to feel unsure'),
        FeatureItem('🤗', 'Support', 'We\'re here for you'),
      ],
      mockupType: MockupType.wellbeing,
    ),
    OnboardingPage(
      title: 'Ready to Play? 🎊',
      subtitle: 'Let\'s go on an adventure!',
      description: 'Tap the button below to start your fun learning journey!',
      emoji: '🌟',
      color: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF64B5F6),
      features: [
        FeatureItem('🎉', 'Have Fun', 'Enjoy every game'),
        FeatureItem('📖', 'Learn', 'Discover new things'),
        FeatureItem('🌈', 'Explore', 'Try everything!'),
      ],
      isLast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    // Play voiceover for first page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playVoiceoverForPage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    _voiceoverPlayer.dispose();
    super.dispose();
  }

  Future<void> _playVoiceoverForPage(int pageIndex) async {
    try {
      // Stop any currently playing voiceover
      await _voiceoverPlayer.stop();

      // Map page index to voiceover file
      String? voiceoverPath;
      switch (pageIndex) {
        case 0:
          // Path relative to assets/ directory (AssetSource adds 'assets/' automatically)
          voiceoverPath = 'audio/voiceovers/onboarding_screen/1.mp3';
          break;
        case 1:
          voiceoverPath = 'audio/voiceovers/onboarding_screen/2.mp3';
          break;
        case 2:
          voiceoverPath = 'audio/voiceovers/onboarding_screen/3.mp3';
          break;
        case 3:
          voiceoverPath = 'audio/voiceovers/onboarding_screen/4.mp3';
          break;
        case 4:
          voiceoverPath = 'audio/voiceovers/onboarding_screen/5.mp3';
          break;
        case 5:
          voiceoverPath = 'audio/voiceovers/onboarding_screen/6.mp3';
          break;
        case 6:
          voiceoverPath = 'audio/voiceovers/onboarding_screen/7.mp3';
          break;
        // Add more mappings as needed
      }

      if (voiceoverPath != null) {
        // AssetSource automatically adds 'assets/' prefix
        // The path should be: audio/voiceovers/onboarding screen/1.mp3
        // Which becomes: assets/audio/voiceovers/onboarding screen/1.mp3
        await _voiceoverPlayer.play(AssetSource(voiceoverPath));
        debugPrint('✅ Playing voiceover: $voiceoverPath');
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('❌ Error playing voiceover for page $pageIndex: $e');
      debugPrint('   Attempted path: audio/voiceovers/onboarding_screen/1.mp3');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.go(RouteNames.unifiedChildLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].color.withOpacity(0.1),
              _pages[_currentPage].secondaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _pages[_currentPage].color
                                : _pages[_currentPage].color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: _pages[_currentPage].color,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _playVoiceoverForPage(index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _pages[_currentPage].color,
                            side: BorderSide(
                                color: _pages[_currentPage].color, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_rounded,
                                  size: 20, color: _pages[_currentPage].color),
                              const SizedBox(width: 8),
                              Text('Back',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _pages[_currentPage].color)),
                            ],
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentPage == 0 ? 1 : 2,
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _pages[_currentPage].isLast
                                ? Offset(0, -_bounceAnimation.value)
                                : Offset.zero,
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pages[_currentPage].color,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor:
                                    _pages[_currentPage].color.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _pages[_currentPage].isLast
                                        ? "Let's Play! 🎮"
                                        : 'Next',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  if (!_pages[_currentPage].isLast) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 20, color: Colors.white),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Main emoji with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [page.color, page.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: page.color.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      page.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: SafePlayColors.neutral700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 15,
              color: SafePlayColors.neutral600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Mockup or Features
          if (page.mockupType != null)
            _buildMockup(page)
          else
            _buildFeatureCards(page),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(OnboardingPage page) {
    return Column(
      children: page.features.map((feature) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: page.color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: page.color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      Text(feature.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: page.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: SafePlayColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMockup(OnboardingPage page) {
    switch (page.mockupType) {
      case MockupType.gameCategories:
        return _buildGameCategoriesMockup(page);
      case MockupType.simulations:
        return _buildSimulationsMockup(page);
      case MockupType.safetyFeatures:
        return _buildSafetyMockup(page);
      case MockupType.progressTracking:
        return _buildProgressMockup(page);
      case MockupType.wellbeing:
        return _buildWellbeingMockup(page);
      default:
        return _buildFeatureCards(page);
    }
  }

  Widget _buildGameCategoriesMockup(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: page.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildMiniGameCard('🔬', 'Science', const Color(0xFFFF9800)),
              const SizedBox(width: 12),
              _buildMiniGameCard('🧮', 'Math', const Color(0xFF2196F3)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniGameCard('📖', 'English', const Color(0xFF9C27B0)),
              const SizedBox(width: 12),
              _buildMiniGameCard('📚', 'Books', const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGameCard(String emoji, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationsMockup(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: page.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [page.color, page.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🧪', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Try it yourself!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Simulation cards
          _buildSimulationCard(
            '⚖️',
            'Equality Explorer',
            'Balance the scale to solve equations!',
            const Color(0xFF5B9BD5),
          ),
          const SizedBox(height: 10),
          _buildSimulationCard(
            '💧',
            'States of Matter',
            'Watch atoms move in solids, liquids & gases!',
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 10),
          _buildSimulationCard(
            '🎈',
            'Static Electricity',
            'Rub balloons and see charges move!',
            const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationCard(
      String emoji, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: SafePlayColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMockup(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: page.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Safe search bar mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SafePlayColors.neutral50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: page.color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: page.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search safely...',
                    style: TextStyle(color: SafePlayColors.neutral400),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Safe',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCards(page),
        ],
      ),
    );
  }

  Widget _buildProgressMockup(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: page.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Coin display - main focus
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFB300), const Color(0xFFFFD54F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '250',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Coins Earned!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Level progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: page.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: page.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Text('⬆️', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level 5',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: page.color,
                              ),
                            ),
                            Text(
                              '75 coins to next level',
                              style: TextStyle(
                                fontSize: 11,
                                color: SafePlayColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: page.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '75%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: SafePlayColors.neutral200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [page.color, page.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
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

  Widget _buildWellbeingMockup(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: page.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SafePlayColors.neutral700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodOption('🤩', 'Awesome', const Color(0xFF4CAF50)),
              _buildMoodOption('😊', 'Good', const Color(0xFF8BC34A)),
              _buildMoodOption('😐', 'Okay', const Color(0xFFFFEB3B)),
              _buildMoodOption('😔', 'Sad', const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOption(String emoji, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: SafePlayColors.neutral600,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final Color color;
  final Color secondaryColor;
  final List<FeatureItem> features;
  final MockupType? mockupType;
  final bool isLast;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.color,
    required this.secondaryColor,
    required this.features,
    this.mockupType,
    this.isLast = false,
  });
}

class FeatureItem {
  final String emoji;
  final String title;
  final String description;

  FeatureItem(this.emoji, this.title, this.description);
}

enum MockupType {
  gameCategories,
  simulations,
  safetyFeatures,
  progressTracking,
  wellbeing,
}
