import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';

/// Professional onboarding screen for parents
class ParentOnboardingScreen extends StatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  State<ParentOnboardingScreen> createState() => _ParentOnboardingScreenState();
}

class _ParentOnboardingScreenState extends State<ParentOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<ParentOnboardingPage> _pages = [
    ParentOnboardingPage(
      title: 'Welcome to SafePlay',
      subtitle: 'Your Child\'s Safety is Our Priority',
      description: 'SafePlay provides a secure, engaging learning environment where your children can explore, learn, and grow safely online.',
      icon: Icons.family_restroom_rounded,
      color: SafePlayColors.brandTeal500,
      highlights: [
        'Age-appropriate content for all children',
        'AI-powered safety monitoring',
        'Educational games and activities',
        'Complete parental oversight',
      ],
    ),
    ParentOnboardingPage(
      title: 'Manage Child Profiles',
      subtitle: 'Create & Customize Profiles',
      description: 'Add multiple children with personalized profiles. Set age groups, configure login methods, and track individual progress.',
      icon: Icons.people_alt_rounded,
      color: SafePlayColors.brightIndigo,
      highlights: [
        'Support for Junior (3-6) and Bright (7-10) age groups',
        'Customizable avatars and names',
        'Individual progress tracking',
        'Easy login setup for each child',
      ],
      mockupType: ParentMockupType.childProfiles,
    ),
    ParentOnboardingPage(
      title: 'Browser Controls',
      subtitle: 'Safe Internet Browsing',
      description: 'Configure comprehensive browser controls to ensure your children only access safe, age-appropriate content online.',
      icon: Icons.shield_rounded,
      color: const Color(0xFF7E57C2),
      highlights: [
        'Safe search filtering enabled by default',
        'Block ads, social media, and harmful content',
        'Custom blocked keywords',
        'Whitelist trusted websites',
      ],
      mockupType: ParentMockupType.browserControls,
    ),
    ParentOnboardingPage(
      title: 'Wellbeing Monitoring',
      subtitle: 'Track Emotional Health',
      description: 'Stay connected with your child\'s emotional wellbeing through regular check-ins and mood tracking reports.',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFE91E63),
      highlights: [
        'Weekly wellbeing check-ins',
        'Mood tracking and history',
        'Emotional health insights',
        'Early concern detection',
      ],
      mockupType: ParentMockupType.wellbeing,
    ),
    ParentOnboardingPage(
      title: 'Messaging Safety',
      subtitle: 'AI-Powered Protection',
      description: 'Our advanced AI monitors all messaging between students and teachers, instantly flagging any concerning content.',
      icon: Icons.security_rounded,
      color: SafePlayColors.error,
      highlights: [
        'Real-time message monitoring',
        'Profanity and bullying detection',
        'Instant parent notifications',
        'Complete conversation transparency',
      ],
      mockupType: ParentMockupType.messagingSafety,
    ),
    ParentOnboardingPage(
      title: 'Activity Tracking',
      subtitle: 'Stay Informed',
      description: 'Monitor your child\'s learning journey with detailed activity reports, achievements, and progress metrics.',
      icon: Icons.insights_rounded,
      color: const Color(0xFF4CAF50),
      highlights: [
        'Daily activity summaries',
        'Learning progress reports',
        'Achievement tracking',
        'Time spent analytics',
      ],
      mockupType: ParentMockupType.activityTracking,
    ),
    ParentOnboardingPage(
      title: 'Get Started',
      subtitle: 'You\'re All Set!',
      description: 'You\'re ready to create a safe learning environment for your children. Sign in to access your parent dashboard.',
      icon: Icons.rocket_launch_rounded,
      color: SafePlayColors.brandTeal500,
      highlights: [
        'Add your first child profile',
        'Configure safety settings',
        'Monitor progress anytime',
        'Support available 24/7',
      ],
      isLast: true,
    ),
  ];

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
    context.go(RouteNames.parentLogin);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip and progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress indicator
                  Row(
                    children: [
                      Text(
                        '${_currentPage + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _pages[_currentPage].color,
                        ),
                      ),
                      Text(
                        ' / ${_pages.length}',
                        style: TextStyle(
                          fontSize: 16,
                          color: SafePlayColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                  // Progress bar
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _pages.length,
                        backgroundColor: SafePlayColors.neutral100,
                        valueColor: AlwaysStoppedAnimation(_pages[_currentPage].color),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: SafePlayColors.neutral500,
                        fontWeight: FontWeight.w600,
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
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
                          foregroundColor: SafePlayColors.neutral600,
                          side: BorderSide(color: SafePlayColors.neutral300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _pages[_currentPage].isLast ? 'Get Started' : 'Continue',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(ParentOnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Icon header
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: page.color,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: SafePlayColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: page.color,
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
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Mockup or highlights
          if (page.mockupType != null)
            _buildMockup(page)
          else
            _buildHighlights(page),
        ],
      ),
    );
  }

  Widget _buildHighlights(ParentOnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SafePlayColors.neutral100),
      ),
      child: Column(
        children: page.highlights.map((highlight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: page.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 14, color: page.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    highlight,
                    style: TextStyle(
                      fontSize: 14,
                      color: SafePlayColors.neutral700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMockup(ParentOnboardingPage page) {
    switch (page.mockupType) {
      case ParentMockupType.childProfiles:
        return _buildChildProfilesMockup(page);
      case ParentMockupType.browserControls:
        return _buildBrowserControlsMockup(page);
      case ParentMockupType.wellbeing:
        return _buildWellbeingMockup(page);
      case ParentMockupType.messagingSafety:
        return _buildMessagingSafetyMockup(page);
      case ParentMockupType.activityTracking:
        return _buildActivityTrackingMockup(page);
      default:
        return _buildHighlights(page);
    }
  }

  Widget _buildChildProfilesMockup(ParentOnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMockChildCard('Emma', 'Junior (Age 5)', '👧', SafePlayColors.juniorPurple, true),
          const SizedBox(height: 12),
          _buildMockChildCard('Liam', 'Bright (Age 8)', '👦', SafePlayColors.brightIndigo, false),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: page.color.withOpacity(0.2), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: page.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Add Child Profile',
                  style: TextStyle(color: page.color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockChildCard(String name, String ageGroup, String emoji, Color color, bool hasSetup) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafePlayColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(ageGroup, style: TextStyle(color: SafePlayColors.neutral500, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasSetup ? SafePlayColors.success.withOpacity(0.1) : SafePlayColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasSetup ? Icons.check_circle : Icons.pending,
                  size: 14,
                  color: hasSetup ? SafePlayColors.success : SafePlayColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  hasSetup ? 'Ready' : 'Setup',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: hasSetup ? SafePlayColors.success : SafePlayColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowserControlsMockup(ParentOnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggleRow('Safe Search', true, page.color),
          const Divider(height: 24),
          _buildToggleRow('Block Ads', true, page.color),
          const Divider(height: 24),
          _buildToggleRow('Block Social Media', true, page.color),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SafePlayColors.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SafePlayColors.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.block, color: SafePlayColors.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Blocked Keywords', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ['violence', 'gambling'].map((k) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: SafePlayColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(k, style: TextStyle(fontSize: 11, color: SafePlayColors.error)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: SafePlayColors.neutral700)),
        Container(
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            color: value ? color : SafePlayColors.neutral300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWellbeingMockup(ParentOnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Overall score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [SafePlayColors.success, SafePlayColors.success.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('😊', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Overall Wellbeing', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('Good', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('85%', style: TextStyle(color: SafePlayColors.success, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Weekly mood
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMoodDay('Mon', '🤩'),
              _buildMiniMoodDay('Tue', '😊'),
              _buildMiniMoodDay('Wed', '😊'),
              _buildMiniMoodDay('Thu', '😐'),
              _buildMiniMoodDay('Fri', '🤩'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMoodDay(String day, String emoji) {
    return Column(
      children: [
        Text(day, style: TextStyle(fontSize: 10, color: SafePlayColors.neutral400)),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SafePlayColors.neutral50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
        ),
      ],
    );
  }

  Widget _buildMessagingSafetyMockup(ParentOnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // AI Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SafePlayColors.brightIndigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SafePlayColors.brightIndigo.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.smart_toy_rounded, color: SafePlayColors.brightIndigo, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('AI Safety Guard', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Alert example
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SafePlayColors.warning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SafePlayColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SafePlayColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warning_rounded, color: SafePlayColors.warning, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inappropriate Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Detected 3h ago', style: TextStyle(color: SafePlayColors.neutral500, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SafePlayColors.warning,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTrackingMockup(ParentOnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatBox('3', 'Children', SafePlayColors.brandTeal500)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox('7d', 'Streak', SafePlayColors.brandOrange500)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox('100%', 'Safety', SafePlayColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          // Activity item
          Container(
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
                    color: SafePlayColors.juniorPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school_rounded, color: SafePlayColors.juniorPurple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Letter Sound Adventure', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Emma • 2h ago', style: TextStyle(color: SafePlayColors.neutral500, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('85%', style: TextStyle(color: SafePlayColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: SafePlayColors.neutral500)),
        ],
      ),
    );
  }
}

class ParentOnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> highlights;
  final ParentMockupType? mockupType;
  final bool isLast;

  ParentOnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.highlights,
    this.mockupType,
    this.isLast = false,
  });
}

enum ParentMockupType {
  childProfiles,
  browserControls,
  wellbeing,
  messagingSafety,
  activityTracking,
}

