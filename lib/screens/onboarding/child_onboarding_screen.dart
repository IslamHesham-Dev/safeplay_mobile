import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to SafePlay! 🎉',
      subtitle: 'Your fun learning adventure starts here!',
      description: 'Play games, learn new things, and have fun while staying safe online!',
      emoji: '🎮',
      color: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFFB74D),
      features: [
        FeatureItem('🎯', 'Fun Games', 'Play exciting learning games'),
        FeatureItem('⭐', 'Earn Stars', 'Collect stars as you play'),
        FeatureItem('🏆', 'Win Badges', 'Get cool badges for achievements'),
      ],
    ),
    OnboardingPage(
      title: 'Choose Your Games 🕹️',
      subtitle: 'Lots of fun activities waiting for you!',
      description: 'Pick from different categories like letters, numbers, animals, and more!',
      emoji: '📚',
      color: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFBA68C8),
      features: [
        FeatureItem('🔤', 'Letters', 'Learn ABCs with fun'),
        FeatureItem('🔢', 'Numbers', 'Count and solve puzzles'),
        FeatureItem('🐾', 'Animals', 'Discover animal friends'),
      ],
      mockupType: MockupType.gameCategories,
    ),
    OnboardingPage(
      title: 'Stay Safe Online 🛡️',
      subtitle: 'We keep you protected!',
      description: 'SafePlay makes sure everything you see and do is safe and fun.',
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
      title: 'Track Your Progress 📊',
      subtitle: 'See how awesome you are!',
      description: 'Watch your coins grow, see your streak, and collect all the badges!',
      emoji: '🚀',
      color: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF81C784),
      features: [
        FeatureItem('🪙', 'Coins', 'Earn coins for playing'),
        FeatureItem('🔥', 'Streaks', 'Play every day for streaks'),
        FeatureItem('📈', 'Level Up', 'Get better and level up'),
      ],
      mockupType: MockupType.progressTracking,
    ),
    OnboardingPage(
      title: 'How Are You Feeling? 💖',
      subtitle: 'Tell us how you feel!',
      description: 'We care about you! Share your feelings and we\'ll help you feel great.',
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            side: BorderSide(color: _pages[_currentPage].color, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: _pages[_currentPage].color.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _pages[_currentPage].isLast ? "Let's Play! 🎮" : 'Next',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  if (!_pages[_currentPage].isLast) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 20),
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
                  child: Text(feature.emoji, style: const TextStyle(fontSize: 24)),
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
              _buildMiniGameCard('🔤', 'Letters', const Color(0xFFE91E63)),
              const SizedBox(width: 12),
              _buildMiniGameCard('🔢', 'Numbers', const Color(0xFF2196F3)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniGameCard('🐾', 'Animals', const Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              _buildMiniGameCard('🎨', 'Colors', const Color(0xFFFF9800)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Safe', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🪙', '250', 'Coins', const Color(0xFFFFB300)),
              _buildStatItem('🔥', '7', 'Streak', const Color(0xFFFF5722)),
              _buildStatItem('⭐', '12', 'Level', const Color(0xFF9C27B0)),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level Progress', style: TextStyle(fontWeight: FontWeight.bold, color: SafePlayColors.neutral700)),
                  Text('75%', style: TextStyle(fontWeight: FontWeight.bold, color: page.color)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: SafePlayColors.neutral100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.75,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [page.color, page.secondaryColor]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: SafePlayColors.neutral500)),
      ],
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
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: SafePlayColors.neutral600, fontWeight: FontWeight.w500)),
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
  safetyFeatures,
  progressTracking,
  wellbeing,
}

