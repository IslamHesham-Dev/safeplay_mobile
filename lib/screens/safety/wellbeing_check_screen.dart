import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/wellbeing_moods.dart';
import '../../design_system/junior_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wellbeing_provider.dart';

class WellbeingCheckScreen extends StatefulWidget {
  const WellbeingCheckScreen({
    super.key,
    this.isCompact = false,
  });

  final bool isCompact;

  @override
  State<WellbeingCheckScreen> createState() => _WellbeingCheckScreenState();
}

class _WellbeingCheckScreenState extends State<WellbeingCheckScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showThankYou = false;
  bool _isSubmitting = false;

  final List<WellbeingMoodDefinition> _moods = kWellbeingMoods;
  static const List<String> _quickResponses = [
    'Had fun today!',
    'Made a new friend',
    'Learned something cool',
    'Feeling tired',
    'I miss my friends',
    'Excited for tomorrow',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showThankYou) {
      return _buildThankYouScreen();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JuniorTheme.primaryPink.withOpacity(0.1),
            JuniorTheme.backgroundLight,
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(widget.isCompact ? 16 : 24),
          child: Column(
            children: [
              if (!widget.isCompact) ...[
                _buildHeader(),
                const SizedBox(height: 32),
              ],
              _buildMoodQuestion(),
              const SizedBox(height: 24),
              _buildMoodSelector(),
              if (_selectedMoodIndex != null) ...[
                const SizedBox(height: 32),
                _buildQuickResponses(),
                const SizedBox(height: 24),
                _buildNoteSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JuniorTheme.primaryPink,
                  JuniorTheme.primaryPurple,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: JuniorTheme.primaryPink.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                JuniorTheme.primaryPink,
                JuniorTheme.primaryPurple,
              ],
            ).createShader(bounds),
            child: const Text(
              'Weekly Check-in',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s see how you\'re doing!',
            style: JuniorTheme.bodyLarge.copyWith(
              color: JuniorTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodQuestion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: JuniorTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'How are you feeling?',
                style: JuniorTheme.headingSmall.copyWith(
                  fontSize: 20,
                  color: JuniorTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the emoji that matches your mood',
            style: JuniorTheme.bodyMedium.copyWith(
              color: JuniorTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(_moods.length, (index) {
        final mood = _moods[index];
        final isSelected = _selectedMoodIndex == index;
        final gradientColors = mood.gradient;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedMoodIndex = index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: isSelected ? 100 : 90,
            padding: EdgeInsets.all(isSelected ? 16 : 12),
            decoration: BoxDecoration(
              gradient:
                  isSelected ? LinearGradient(colors: gradientColors) : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? mood.color.withOpacity(0.4)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: isSelected ? 16 : 10,
                  offset: Offset(0, isSelected ? 8 : 4),
                ),
              ],
              border: isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
                  : Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(fontSize: isSelected ? 44 : 36),
                  child: Text(mood.emoji),
                ),
                const SizedBox(height: 8),
                Text(
                  mood.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : JuniorTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickResponses() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want to share more?',
            style: JuniorTheme.headingSmall.copyWith(
              color: JuniorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickResponses
                .map(
                  (text) => _buildQuickResponseChip(text),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickResponseChip(String text) {
    final isSelected = _noteController.text.trim() == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _noteController.text = text;
          _noteController.selection = TextSelection.fromPosition(
            TextPosition(offset: _noteController.text.length),
          );
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? JuniorTheme.primaryPink.withOpacity(0.15)
              : JuniorTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? JuniorTheme.primaryPink
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected ? JuniorTheme.primaryPink : JuniorTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anything else you want to share?',
            style: JuniorTheme.headingSmall.copyWith(
              color: JuniorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a quick note...',
              filled: true,
              fillColor: JuniorTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final selectedIndex = _selectedMoodIndex;
    final isDisabled = selectedIndex == null || _isSubmitting;
    final gradientColors = selectedIndex != null
        ? _moods[selectedIndex].gradient
        : [
            JuniorTheme.primaryPurple,
            JuniorTheme.primaryPink,
          ];

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: isDisabled ? null : _submitCheckin,
        child: Opacity(
          opacity: isDisabled ? 0.7 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isSubmitting ? 'Sending...' : 'Submit Check-in',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouScreen() {
    final childName = context.read<AuthProvider>().currentChild?.name;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JuniorTheme.primaryGreen.withOpacity(0.1),
            JuniorTheme.backgroundLight,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            JuniorTheme.primaryGreen,
                            JuniorTheme.primaryBlue,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: JuniorTheme.primaryGreen.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Thank you!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: JuniorTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                childName == null
                    ? 'Your check-in has been recorded.'
                    : '${childName.split(' ').first}, your check-in has been recorded.',
                textAlign: TextAlign.center,
                style: JuniorTheme.bodyLarge.copyWith(
                  color: JuniorTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep being awesome!',
                style: JuniorTheme.bodyMedium.copyWith(
                  color: JuniorTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (widget.isCompact) {
                    Navigator.of(context).maybePop();
                  } else {
                    setState(() {
                      _showThankYou = false;
                      _selectedMoodIndex = null;
                      _noteController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JuniorTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCheckin() async {
    final moodIndex = _selectedMoodIndex;
    if (moodIndex == null || _isSubmitting) return;

    final authProvider = context.read<AuthProvider>();
    final child = authProvider.currentChild;
    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You need to be signed in as a child to submit a check-in.'),
        ),
      );
      return;
    }

    final wellbeingProvider = context.read<WellbeingProvider>();
    final mood = _moods[moodIndex];
    final note = _noteController.text.trim();

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await wellbeingProvider.submitEntry(
        childId: child.id,
        moodLabel: mood.label,
        moodEmoji: mood.emoji,
        moodScore: mood.score,
        moodIndex: moodIndex,
        notes: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showThankYou = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit check-in: $error'),
        ),
      );
    }
  }
}

class WellbeingCheckWidget extends StatelessWidget {
  const WellbeingCheckWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              JuniorTheme.primaryPink,
              JuniorTheme.primaryPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: JuniorTheme.primaryPink.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Take a quick check-in',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: JuniorTheme.primaryPink,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
