import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

class WellbeingCheckScreen extends StatefulWidget {
  final bool isCompact;
  
  const WellbeingCheckScreen({
    super.key,
    this.isCompact = false,
  });

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

  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '🤩',
      'label': 'Amazing',
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
    },
    {
      'emoji': '😊',
      'label': 'Happy',
      'color': const Color(0xFF2196F3),
      'gradient': [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
    },
    {
      'emoji': '🙂',
      'label': 'Good',
      'color': const Color(0xFF00BCD4),
      'gradient': [const Color(0xFF00BCD4), const Color(0xFF26C6DA)],
    },
    {
      'emoji': '😐',
      'label': 'Okay',
      'color': const Color(0xFFFF9800),
      'gradient': [const Color(0xFFFF9800), const Color(0xFFFFA726)],
    },
    {
      'emoji': '😔',
      'label': 'Sad',
      'color': const Color(0xFF9C27B0),
      'gradient': [const Color(0xFF9C27B0), const Color(0xFFAB47BC)],
    },
    {
      'emoji': '😢',
      'label': 'Upset',
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFEC407A)],
    },
  ];

  final List<Map<String, dynamic>> _quickResponses = [
    {'text': 'Had fun today!', 'emoji': '🎉'},
    {'text': 'Made a new friend', 'emoji': '👋'},
    {'text': 'Learned something cool', 'emoji': '💡'},
    {'text': 'Feeling tired', 'emoji': '😴'},
    {'text': 'Miss my friends', 'emoji': '💭'},
    {'text': 'Excited for tomorrow', 'emoji': '⭐'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
              colors: [JuniorTheme.primaryPink, JuniorTheme.primaryPurple],
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
            'Let\'s see how you\'re doing! 💫',
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
        final gradientColors = mood['gradient'] as List<Color>;

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
              gradient: isSelected
                  ? LinearGradient(colors: gradientColors)
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? (mood['color'] as Color).withOpacity(0.4)
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
                  child: Text(mood['emoji'] as String),
                ),
                const SizedBox(height: 8),
                Text(
                  mood['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : JuniorTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSelected ? 14 : 12,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: JuniorTheme.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick responses',
                style: JuniorTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: JuniorTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickResponses.map((response) {
            final isSelected = _noteController.text.contains(response['text']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _noteController.text = _noteController.text
                        .replaceAll('${response['text']} ', '')
                        .replaceAll(response['text'], '');
                  } else {
                    if (_noteController.text.isNotEmpty) {
                      _noteController.text += ' ';
                    }
                    _noteController.text += response['text'];
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? JuniorTheme.primaryBlue.withOpacity(0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? JuniorTheme.primaryBlue
                        : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(response['emoji'], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      response['text'],
                      style: TextStyle(
                        color: isSelected
                            ? JuniorTheme.primaryBlue
                            : JuniorTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: JuniorTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Want to share more?',
                style: JuniorTheme.headingSmall.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: JuniorTheme.bodySmall.copyWith(
                  color: JuniorTheme.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: JuniorTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Tell us about your day...',
              hintStyle: JuniorTheme.bodyMedium.copyWith(
                color: JuniorTheme.textLight,
              ),
              filled: true,
              fillColor: JuniorTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: JuniorTheme.primaryPurple,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final selectedMood = _selectedMoodIndex != null ? _moods[_selectedMoodIndex!] : null;
    final gradientColors = selectedMood != null
        ? selectedMood['gradient'] as List<Color>
        : [JuniorTheme.primaryGreen, JuniorTheme.primaryBlue];

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _submitCheckin,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Submit Check-in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouScreen() {
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
              const Text(
                'Thank You! 🎉',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: JuniorTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your check-in has been recorded',
                style: JuniorTheme.bodyLarge.copyWith(
                  color: JuniorTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep being awesome! 💪',
                style: JuniorTheme.bodyMedium.copyWith(
                  color: JuniorTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  void _submitCheckin() {
    setState(() {
      _showThankYou = true;
    });
  }
}

/// Compact wellbeing widget for dashboard
class WellbeingCheckWidget extends StatelessWidget {
  final VoidCallback onTap;
  
  const WellbeingCheckWidget({super.key, required this.onTap});

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
