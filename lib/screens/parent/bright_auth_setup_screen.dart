import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../models/user_profile.dart';
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
  final List<String> _availablePictures = [
    'Aria',
    'Diego',
    'Emma',
    'Liam',
    'Sofia',
    'James',
    'Maya',
    'Jennifer',
    'Michael',
    'Sarah',
  ];

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
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty && confirmPin.isEmpty) {
      return 'Enter a 4-digit PIN and confirm it';
    }

    if (pin.length < 4) {
      return 'PIN must be 4 digits';
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN must contain only numbers';
    }

    if (confirmPin.isEmpty) {
      return 'Please confirm your PIN';
    }

    if (confirmPin.length < 4) {
      return 'Confirm PIN must be 4 digits';
    }

    if (pin != confirmPin) {
      return 'PINs do not match';
    }

    return 'PIN is valid!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup ${widget.child.name}\'s Login'),
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
                        child: const Text('Back'),
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
          'Setup ${widget.child.name}\'s Login',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Help your child create a secure login with pictures and a PIN.',
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
                    'How it works:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SafePlayColors.brandOrange500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('1. Choose 3 pictures your child likes'),
              const Text('2. Create a 4-digit PIN number'),
              const Text('3. Your child will use both to login'),
              const Text('4. Make sure they can remember both!'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPictureSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose 3 Pictures',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select 3 pictures that ${widget.child.name} will use to login.',
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
                  'Selected (${_selectedPictures.length}/3):',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create PIN',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a 4-digit PIN that ${widget.child.name} can remember.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // PIN input
        TextFormField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: '4-Digit PIN',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
            helperText: 'Enter a 4-digit number (e.g., 1234)',
          ),
          validator: (value) {
            if (value == null || value.length != 4) {
              return 'PIN must be exactly 4 digits';
            }
            if (!RegExp(r'^\d{4}$').hasMatch(value)) {
              return 'PIN must contain only numbers';
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
          decoration: const InputDecoration(
            labelText: 'Confirm PIN',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != _pinController.text) {
              return 'PINs do not match';
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
                  'Make sure ${widget.child.name} can remember this PIN!',
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
          'This is what ${widget.child.name} will use to login:',
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
                'Selected Pictures:',
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
                'PIN:',
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
    switch (_currentStep) {
      case 0:
        return 'Select Pictures';
      case 1:
        return 'Create PIN';
      case 2:
        return 'Review Setup';
      case 3:
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login setup completed successfully!'),
            backgroundColor: SafePlayColors.success,
          ),
        );
        context.pop();
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
