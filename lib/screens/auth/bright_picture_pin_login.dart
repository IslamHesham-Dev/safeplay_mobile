import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/authentication_options.dart';
import '../../design_system/colors.dart';
import '../../widgets/auth/picture_password_grid.dart';
import '../../widgets/auth/pin_entry_widget.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';

/// Picture + PIN login screen for Bright Minds
class BrightPicturePinLogin extends StatefulWidget {
  final String childId;
  final String childName;

  const BrightPicturePinLogin({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<BrightPicturePinLogin> createState() => _BrightPicturePinLoginState();
}

class _BrightPicturePinLoginState extends State<BrightPicturePinLogin> {
  final List<String> _pictures = brightPictureOptions;

  bool _pictureStepComplete = false;
  List<String>? _selectedPictures;
  bool _isLoading = false;
  String? _enteredPin;

  void _onPicturesSelected(List<String> selectedPictures) {
    final picturesCopy = List<String>.from(selectedPictures);
    setState(() {
      _selectedPictures = picturesCopy;
      _pictureStepComplete = true;
    });
    unawaited(_attemptLoginIfReady());
  }

  Future<void> _onPinComplete(String pin) async {
    setState(() {
      _enteredPin = pin;
    });
    await _attemptLoginIfReady();
  }

  Future<void> _attemptLoginIfReady() async {
    if (_selectedPictures == null || _enteredPin == null) return;
    final pictures = List<String>.from(_selectedPictures!);
    final pin = _enteredPin!;

    if (pin.length != 4 || pictures.length != 3) return;

    // Run the auth flow only when both pieces are ready
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      print(
          '[BrightPicturePinLogin]: Authenticating ${widget.childId} with pictures $_selectedPictures');
      final success = await authProvider.signInChildWithPicturePin(
        widget.childId,
        pictures,
        pin,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${widget.childName}!'),
            backgroundColor: Colors.green,
          ),
        );

        context.go(RouteNames.brightDashboard);
      } else {
        setState(() {
          _pictureStepComplete = false;
          _selectedPictures = null;
          _enteredPin = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That combination didn\'t match. Try again!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[BrightPicturePinLogin]: Authentication error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login as ${widget.childName}'),
        backgroundColor: SafePlayColors.brightIndigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                        // Avatar
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: SafePlayColors.brightIndigo,
                            child: const Icon(
                              Icons.psychology,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Welcome message
                        Text(
                          'Welcome back, ${widget.childName}!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: SafePlayColors.brightIndigo,
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        const SizedBox(height: 32),

                        // Step indicator
                        Row(
                          children: [
                            Expanded(
                              child: _buildStepCard(
                                '1',
                                'Pictures',
                                _pictureStepComplete,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStepCard(
                                '2',
                                'PIN',
                                false,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Content based on step
                        if (!_pictureStepComplete) ...[
                          Text(
                            'Select your 3 pictures',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                        PicturePasswordGrid(
                          pictures: _pictures,
                          sequenceLength: 3,
                          onSequenceComplete: _onPicturesSelected,
                          useAvatarStyle: true,
                          selectionColor: SafePlayColors.brightIndigo,
                        ),
                        ] else ...[
                          Text(
                            'Enter your 4-digit PIN',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          PinEntryWidget(
                            onPinComplete: _onPinComplete,
                            onClear: () => setState(() => _enteredPin = null),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _pictureStepComplete = false;
                                _selectedPictures = null;
                                _enteredPin = null;
                              });
                            },
                            child: const Text('Change Pictures'),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Help button
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Need Help?'),
                                content: const Text(
                                  'Ask your parent to help you log in or reset your authentication.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.help),
                          label: const Text('Need Help?'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStepCard(String step, String label, bool isComplete) {
    return Card(
      color: isComplete
          ? SafePlayColors.brightIndigo.withOpacity(0.1)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isComplete
                    ? SafePlayColors.success
                    : SafePlayColors.neutral200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
                        step,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }


}
