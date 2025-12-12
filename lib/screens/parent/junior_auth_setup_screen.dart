import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/authentication_options.dart';
import '../../design_system/colors.dart';
import '../../localization/app_localizations.dart';
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
    final loc = context.loc;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.t('auth.setup.title').replaceFirst('{name}', widget.child.name),
        ),
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
                        child: Text(loc.t('auth.setup.back')),
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
    final loc = context.loc;
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
          loc.t('auth.setup.title').replaceFirst('{name}', widget.child.name),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.t('auth.setup.instructions_emoji'),
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
                    loc.t('auth.setup.how_it_works'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SafePlayColors.brandTeal500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('1. ${loc.t('auth.setup.emoji.step1')}'),
              Text('2. ${loc.t('auth.setup.emoji.step2')}'),
              Text('3. ${loc.t('auth.setup.emoji.step3')}'),
              Text('4. ${loc.t('auth.setup.emoji.step4')}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionStep() {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('auth.setup.choose_emojis_title'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          loc
              .t('auth.setup.choose_emojis_subtitle')
              .replaceFirst('{name}', widget.child.name),
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
                  loc.t('auth.setup.selected_count').replaceFirst(
                        '{current}',
                        '${_selectedEmojis.length}',
                      ).replaceFirst('{total}', '4'),
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
    final loc = context.loc;
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
          loc.t('auth.setup.confirm_title').replaceFirst(
                '{name}',
                widget.child.name,
              ),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.t('auth.setup.confirm_sequence_subtitle').replaceFirst(
                '{name}',
                widget.child.name,
              ),
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
                loc.t('auth.setup.login_sequence'),
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
                  loc.t('auth.setup.remember_sequence').replaceFirst(
                        '{name}',
                        widget.child.name,
                      ),
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
    final loc = context.loc;
    switch (_currentStep) {
      case 0:
        return loc.t('auth.setup.start_selection');
      case 1:
        return loc.t('auth.setup.confirm_selection');
      case 2:
        return _isLoading
            ? loc.t('auth.setup.saving')
            : loc.t('auth.setup.save_login');
      default:
        return loc.t('auth.setup.next');
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
          SnackBar(
            content: Text(context.loc.t('auth.setup.success')),
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
            content: Text(
                '${context.loc.t('auth.setup.error_prefix')}${e.toString()}'),
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
