import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../widgets/auth/picture_password_grid.dart';
import '../../widgets/auth/pin_entry_widget.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';

/// Picture + PIN setup screen for Bright Minds
class BrightPicturePinSetup extends StatefulWidget {
  final String childId;

  const BrightPicturePinSetup({
    super.key,
    required this.childId,
  });

  @override
  State<BrightPicturePinSetup> createState() => _BrightPicturePinSetupState();
}

class _BrightPicturePinSetupState extends State<BrightPicturePinSetup> {
  final List<String> _pictures = [
    '🎨',
    '📚',
    '⚽',
    '🎮',
    '🎵',
    '🎬',
    '🌟',
    '🚀',
    '🌈',
    '⚡',
    '🔬',
    '🎯',
  ];

  int _currentStep = 0; // 0: Picture selection, 1: PIN entry, 2: Confirm PIN
  List<String>? _selectedPictures;
  String? _firstPin;
  String? _secondPin;
  bool _isLoading = false;

  void _onPicturesSelected(List<String> pictures) {
    setState(() {
      _selectedPictures = pictures;
      _currentStep = 1;
    });
  }

  void _onFirstPinComplete(String pin) {
    // Validate PIN strength
    if (_isWeakPin(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please choose a stronger PIN (avoid 1111, 1234, etc.)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _firstPin = pin;
      _currentStep = 2;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great! Now enter the same PIN again to confirm'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _onSecondPinComplete(String pin) async {
    setState(() {
      _secondPin = pin;
    });

    // Check if PINs match
    if (_firstPin == _secondPin) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().setPicturePin(
          widget.childId,
          _selectedPictures!,
          _firstPin!,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picture + PIN set successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pop();
          }
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // PINs don't match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs don\'t match! Please try again'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _firstPin = null;
        _secondPin = null;
        _currentStep = 1;
      });
    }
  }

  bool _isWeakPin(String pin) {
    // Check for repeating digits
    if (pin == pin[0] * 4) return true;

    // Check for sequential digits
    const sequences = ['0123', '1234', '2345', '3456', '4567', '5678', '6789'];
    if (sequences.contains(pin) ||
        sequences.contains(pin.split('').reversed.join())) {
      return true;
    }

    return false;
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        if (_currentStep == 0) {
          _selectedPictures = null;
        } else if (_currentStep == 1) {
          _firstPin = null;
        }
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Picture + PIN'),
          backgroundColor: SafePlayColors.brightIndigo,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step indicator
                      _buildStepIndicator(),

                      const SizedBox(height: 32),

                      // Content based on current step
                      if (_currentStep == 0) _buildPictureSelectionStep(),
                      if (_currentStep == 1) _buildFirstPinStep(),
                      if (_currentStep == 2) _buildConfirmPinStep(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, _currentStep >= 0),
        Expanded(
            child: Divider(
                color: _currentStep >= 1
                    ? SafePlayColors.brightIndigo
                    : Colors.grey)),
        _buildStepCircle(2, _currentStep >= 1),
        Expanded(
            child: Divider(
                color: _currentStep >= 2
                    ? SafePlayColors.brightIndigo
                    : Colors.grey)),
        _buildStepCircle(3, _currentStep >= 2),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? SafePlayColors.brightIndigo : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPictureSelectionStep() {
    return Column(
      children: [
        Icon(
          Icons.image,
          size: 80,
          color: SafePlayColors.brightIndigo,
        ),
        const SizedBox(height: 16),
        Text(
          'Step 1: Select 3 Pictures',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: SafePlayColors.brightIndigo,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose 3 pictures that you can remember',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        PicturePasswordGrid(
          pictures: _pictures,
          sequenceLength: 3,
          onSequenceComplete: _onPicturesSelected,
        ),
      ],
    );
  }

  Widget _buildFirstPinStep() {
    return Column(
      children: [
        Icon(
          Icons.pin,
          size: 80,
          color: SafePlayColors.brightIndigo,
        ),
        const SizedBox(height: 16),
        Text(
          'Step 2: Create a PIN',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: SafePlayColors.brightIndigo,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter a 4-digit PIN',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        PinEntryWidget(
          onPinComplete: _onFirstPinComplete,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SafePlayColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: SafePlayColors.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Avoid simple PINs like 1111 or 1234',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPinStep() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: 80,
          color: SafePlayColors.brightIndigo,
        ),
        const SizedBox(height: 16),
        Text(
          'Step 3: Confirm PIN',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: SafePlayColors.brightIndigo,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the same PIN again',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        PinEntryWidget(
          onPinComplete: _onSecondPinComplete,
        ),
      ],
    );
  }
}

