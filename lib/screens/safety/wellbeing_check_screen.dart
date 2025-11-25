import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

class WellbeingCheckScreen extends StatefulWidget {
  const WellbeingCheckScreen({super.key});

  @override
  State<WellbeingCheckScreen> createState() => _WellbeingCheckScreenState();
}

class _WellbeingCheckScreenState extends State<WellbeingCheckScreen> {
  int? _selectedMoodIndex;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '🤩', 'label': 'Awesome', 'color': JuniorTheme.primaryGreen},
    {'emoji': '🙂', 'label': 'Good', 'color': JuniorTheme.primaryBlue},
    {'emoji': '😐', 'label': 'Okay', 'color': JuniorTheme.primaryYellow},
    {'emoji': '😔', 'label': 'Sad', 'color': JuniorTheme.primaryOrange},
    {'emoji': '😫', 'label': 'Bad', 'color': JuniorTheme.primaryPink},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuniorTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: JuniorTheme.shadowMedium,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: JuniorTheme.primaryPink,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Weekly Check-in',
                  style: JuniorTheme.headingMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'How are you feeling today?',
                  style: JuniorTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(_moods.length, (index) {
                    final mood = _moods[index];
                    final isSelected = _selectedMoodIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMoodIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? (mood['color'] as Color) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected ? JuniorTheme.shadowMedium : JuniorTheme.shadowLight,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              mood['emoji'] as String,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood['label'] as String,
                              style: JuniorTheme.bodyMedium.copyWith(
                                color: isSelected ? Colors.white : JuniorTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                if (_selectedMoodIndex != null) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: JuniorTheme.shadowLight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anything you want to share?',
                          style: JuniorTheme.headingSmall.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write here...',
                            hintStyle: JuniorTheme.bodyMedium.copyWith(color: JuniorTheme.textLight),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: JuniorTheme.textLight.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: JuniorTheme.textLight.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: JuniorTheme.primaryBlue, width: 2),
                            ),
                            filled: true,
                            fillColor: JuniorTheme.backgroundLight.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thanks for sharing!')),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JuniorTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Submit Check-in',
                        style: JuniorTheme.buttonText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

