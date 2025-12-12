import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/authentication_options.dart';
import '../../design_system/colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../navigation/route_names.dart';
import '../../providers/child_provider.dart';
import '../../widgets/avatar_widget.dart';

/// Bright Minds authentication setup screen
class BrightAuthSetupScreen extends StatefulWidget {
  final ChildProfile child;

  const BrightAuthSetupScreen({
    super.key,
    required this.child,
  });

  @override
  State<BrightAuthSetupScreen> createState() => _BrightAuthSetupScreenState();
}

class _BrightAuthSetupScreenState extends State<BrightAuthSetupScreen> {
  final List<String> _selectedPictures = [];
  final List<String> _availablePictures = brightPictureOptions;

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0; // 0: Instructions, 1: Pictures, 2: PIN, 3: Confirmation

  @override
  void initState() {
    super.initState();
    // Add listeners to update state when PIN fields change
    _pinController.addListener(_onPinChanged);
    _confirmPinController.addListener(_onPinChanged);
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _confirmPinController.removeListener(_onPinChanged);
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _onPinChanged() {
    setState(() {
      // Trigger rebuild when PIN fields change
    });
  }

  bool _isPinValid() {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    return pin.length == 4 &&
        confirmPin.length == 4 &&
        pin == confirmPin &&
        RegExp(r'^\d{4}$').hasMatch(pin);
  }

  String _getPinValidationMessage() {
    final loc = context.loc;
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty && confirmPin.isEmpty) {
      return loc.t('auth.setup.pin_validation_prompt');
    }

    if (pin.length < 4) {
      return loc.t('auth.setup.pin_validation_short');
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return loc.t('auth.setup.pin_validation_numeric');
    }

    if (confirmPin.isEmpty) {
      return loc.t('auth.setup.pin_validation_confirm_prompt');
    }

    if (confirmPin.length < 4) {
      return loc.t('auth.setup.pin_validation_confirm_short');
    }

    if (pin != confirmPin) {
      return loc.t('auth.setup.pin_validation_mismatch');
    }

    return loc.t('auth.setup.pin_validation_valid');
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.t('auth.setup.title').replaceFirst('{name}', widget.child.name),
        ),
        backgroundColor: SafePlayColors.brandOrange500,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: SafePlayColors.neutral200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    SafePlayColors.brandOrange500),
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
                        backgroundColor: SafePlayColors.brandOrange500,
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
        return _buildPictureSelectionStep();
      case 2:
        return _buildPinStep();
      case 3:
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
          Icons.school,
          size: 80,
          color: SafePlayColors.brandOrange500,
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
          loc.t('auth.setup.instructions_bright'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SafePlayColors.brandOrange500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SafePlayColors.brandOrange500),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: SafePlayColors.brandOrange500),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('auth.setup.how_it_works'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SafePlayColors.brandOrange500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('1. ${loc.t('auth.setup.pictures.step1')}'),
              Text('2. ${loc.t('auth.setup.pictures.step2')}'),
              Text('3. ${loc.t('auth.setup.pictures.step3')}'),
              Text('4. ${loc.t('auth.setup.pictures.step4')}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPictureSelectionStep() {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('auth.setup.choose_pictures_title'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          loc
              .t('auth.setup.choose_pictures_subtitle')
              .replaceFirst('{name}', widget.child.name),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        // Selected pictures display
        if (_selectedPictures.isNotEmpty) ...[
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
                        '${_selectedPictures.length}',
                      ).replaceFirst('{total}', '3'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedPictures
                      .map((picture) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: SafePlayColors.brandOrange500,
                                  width: 2),
                            ),
                            child: AvatarWidget(
                              name: picture,
                              size: 60,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Picture grid
        Expanded(
          child: AvatarGridWidget(
            avatarNames: _availablePictures,
            selectedAvatars: _selectedPictures,
            maxSelections: 3,
            onAvatarSelected: _togglePicture,
            avatarSize: 80,
            crossAxisCount: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildPinStep() {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('auth.setup.pin_title'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.t('auth.setup.pin_subtitle').replaceFirst(
                '{name}',
                widget.child.name,
              ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // PIN input
        TextFormField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: loc.t('auth.setup.pin_label'),
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            helperText: loc.t('auth.setup.pin_helper'),
          ),
          validator: (value) {
            if (value == null || value.length != 4) {
              return loc.t('auth.setup.pin_error_length');
            }
            if (!RegExp(r'^\d{4}$').hasMatch(value)) {
              return loc.t('auth.setup.pin_error_numeric');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Confirm PIN input
        TextFormField(
          controller: _confirmPinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: loc.t('auth.setup.pin_confirm_label'),
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != _pinController.text) {
              return loc.t('auth.setup.pin_error_mismatch');
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // PIN validation status
        if (_pinController.text.isNotEmpty ||
            _confirmPinController.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isPinValid()
                  ? SafePlayColors.success.withValues(alpha: 0.1)
                  : SafePlayColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isPinValid()
                    ? SafePlayColors.success
                    : SafePlayColors.warning,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isPinValid() ? Icons.check_circle : Icons.info,
                  color: _isPinValid()
                      ? SafePlayColors.success
                      : SafePlayColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPinValidationMessage(),
                    style: TextStyle(
                      color: _isPinValid()
                          ? SafePlayColors.success
                          : SafePlayColors.warning,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

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
                  loc.t('auth.setup.remember_pin').replaceFirst(
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
          loc.t('auth.setup.confirm_login_subtitle').replaceFirst(
                '{name}',
                widget.child.name,
              ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),

        // Pictures display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SafePlayColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SafePlayColors.neutral300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('auth.setup.confirm_selected_pictures'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _selectedPictures
                    .map((picture) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                                color: SafePlayColors.brandOrange500, width: 2),
                          ),
                          child: AvatarWidget(
                            name: picture,
                            size: 80,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // PIN display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SafePlayColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SafePlayColors.neutral300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('auth.setup.confirm_pin_label'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _pinController.text,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 8,
                      color: SafePlayColors.brandOrange500,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _togglePicture(String picture) {
    setState(() {
      if (_selectedPictures.contains(picture)) {
        _selectedPictures.remove(picture);
      } else if (_selectedPictures.length < 3) {
        _selectedPictures.add(picture);
      }
    });
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _selectedPictures.length == 3;
      case 2:
        final pin = _pinController.text.trim();
        final confirmPin = _confirmPinController.text.trim();
        return pin.length == 4 &&
            confirmPin.length == 4 &&
            pin == confirmPin &&
            RegExp(r'^\d{4}$').hasMatch(pin);
      case 3:
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    final loc = context.loc;
    switch (_currentStep) {
      case 0:
        return loc.t('auth.setup.select_pictures');
      case 1:
        return loc.t('auth.setup.create_pin');
      case 2:
        return loc.t('auth.setup.review_setup');
      case 3:
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
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _saveAuthentication();
    }
  }

  Future<void> _saveAuthentication() async {
    setState(() => _isLoading = true);

    try {
      final childProvider = context.read<ChildProvider>();
      await childProvider.setPicturePin(
        widget.child.id,
        _selectedPictures,
        _pinController.text,
      );

      if (mounted) {
        final loc = context.loc;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('auth.setup.success')),
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
