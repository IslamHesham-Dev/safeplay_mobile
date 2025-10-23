import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/authentication_options.dart';
import '../../design_system/colors.dart';
import '../../models/user_profile.dart';
import '../../navigation/route_names.dart';
import '../../providers/child_provider.dart';

/// Junior Explorer authentication setup screen
class JuniorAuthSetupScreen extends StatefulWidget {
  final ChildProfile child;

  const JuniorAuthSetupScreen({
    super.key,
    required this.child,
  });

  @override
  State<JuniorAuthSetupScreen> createState() => _JuniorAuthSetupScreenState();
}

class _JuniorAuthSetupScreenState extends State<JuniorAuthSetupScreen> {
  final List<String> _selectedEmojis = [];
  final List<String> _availableEmojis = juniorEmojiOptions;

  bool _isLoading = false;
  int _currentStep = 0; // 0: Instructions, 1: Selection, 2: Confirmation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup ${widget.child.name}\'s Login'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: SafePlayColors.neutral200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    SafePlayColors.brandTeal500),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: _buildCurrentStep(),
              ),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SafePlayColors.brandTeal500,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_getNextButtonText()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildInstructionsStep();
      case 1:
        return _buildSelectionStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInstructionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.child_care,
          size: 80,
          color: SafePlayColors.brandTeal500,
        ),
        const SizedBox(height: 24),
        Text(
          'Setup ${widget.child.name}\'s Login',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Help your child create a picture password they can remember easily.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SafePlayColors.brandTeal500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SafePlayColors.brandTeal500),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: SafePlayColors.brandTeal500),
                  const SizedBox(width: 8),
                  Text(
                    'How it works:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SafePlayColors.brandTeal500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('1. Choose 4 emoji pictures your child likes'),
              const Text('2. Remember the order you select them'),
              const Text('3. Your child will use this sequence to login'),
              const Text('4. Make sure it\'s something they can remember!'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose 4 Emojis',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select 4 emoji pictures that ${widget.child.name} will use to login.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        // Selected emojis display
        if (_selectedEmojis.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SafePlayColors.neutral100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SafePlayColors.neutral300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected (${_selectedEmojis.length}/4):',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedEmojis
                      .map((emoji) => Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SafePlayColors.brandTeal500,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Emoji grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _availableEmojis[index];
              final isSelected = _selectedEmojis.contains(emoji);
              final canSelect = _selectedEmojis.length < 4;

              return InkWell(
                onTap:
                    canSelect || isSelected ? () => _toggleEmoji(emoji) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SafePlayColors.brandTeal500
                        : SafePlayColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? SafePlayColors.brandTeal500
                          : SafePlayColors.neutral300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: SafePlayColors.success,
        ),
        const SizedBox(height: 24),
        Text(
          'Confirm ${widget.child.name}\'s Login',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'This is the sequence ${widget.child.name} will use to login:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),

        // Password sequence display
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SafePlayColors.neutral50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SafePlayColors.neutral300),
          ),
          child: Column(
            children: [
              Text(
                'Login Sequence',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _selectedEmojis.asMap().entries.map((entry) {
                  final index = entry.key;
                  final emoji = entry.value;
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SafePlayColors.brandTeal500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SafePlayColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SafePlayColors.warning),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: SafePlayColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Make sure ${widget.child.name} can remember this sequence!',
                  style: TextStyle(color: SafePlayColors.warning),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleEmoji(String emoji) {
    setState(() {
      if (_selectedEmojis.contains(emoji)) {
        _selectedEmojis.remove(emoji);
      } else if (_selectedEmojis.length < 4) {
        _selectedEmojis.add(emoji);
      }
    });
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _selectedEmojis.length == 4;
      case 2:
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Start Selection';
      case 1:
        return 'Confirm Selection';
      case 2:
        return _isLoading ? 'Saving...' : 'Save Login';
      default:
        return 'Next';
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _saveAuthentication();
    }
  }

  Future<void> _saveAuthentication() async {
    setState(() => _isLoading = true);

    try {
      final childProvider = context.read<ChildProvider>();
      await childProvider.setPicturePassword(widget.child.id, _selectedEmojis);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login setup completed successfully!'),
            backgroundColor: SafePlayColors.success,
          ),
        );
        // Navigate to parent dashboard instead of going back
        context.go(RouteNames.parentDashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
