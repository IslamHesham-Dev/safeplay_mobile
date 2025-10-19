import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../widgets/auth/picture_password_grid.dart';
import '../../widgets/auth/pin_entry_widget.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
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

  bool _pictureStepComplete = false;
  List<String>? _selectedPictures;
  bool _isLoading = false;
  int _attemptCount = 0;
  bool _isLockedOut = false;
  Duration? _lockoutRemaining;

  @override
  void initState() {
    super.initState();
    _checkLockoutStatus();
  }

  Future<void> _checkLockoutStatus() async {
    final authService = AuthService();
    final isLocked = await authService.isChildLockedOut(widget.childId);

    if (isLocked) {
      final remaining =
          await authService.getRemainingLockoutTime(widget.childId);
      setState(() {
        _isLockedOut = true;
        _lockoutRemaining = remaining;
      });

      if (remaining != null) {
        _startLockoutTimer(remaining);
      }
    }
  }

  void _startLockoutTimer(Duration duration) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final remaining = duration - const Duration(seconds: 1);
      if (remaining.inSeconds > 0) {
        setState(() {
          _lockoutRemaining = remaining;
        });
        _startLockoutTimer(remaining);
      } else {
        setState(() {
          _isLockedOut = false;
          _lockoutRemaining = null;
          _attemptCount = 0;
        });
      }
    });
  }

  void _onPicturesSelected(List<String> selectedPictures) {
    setState(() {
      _selectedPictures = selectedPictures;
      _pictureStepComplete = true;
    });
  }

  Future<void> _onPinComplete(String pin) async {
    if (_isLockedOut || _selectedPictures == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInChildWithPicturePin(
        widget.childId,
        _selectedPictures!,
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

        // Navigate to Bright dashboard
        context.go(RouteNames.brightDashboard);
      } else {
        setState(() {
          _attemptCount++;
          _pictureStepComplete = false;
          _selectedPictures = null;
        });

        if (_attemptCount >= 5) {
          await _checkLockoutStatus();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Incorrect credentials. ${5 - _attemptCount} attempts left',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in: $e'),
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
        child: _isLockedOut
            ? _buildLockedOutView()
            : _isLoading
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
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _pictureStepComplete = false;
                                _selectedPictures = null;
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

  Widget _buildLockedOutView() {
    final minutes = _lockoutRemaining?.inMinutes ?? 0;
    final seconds = (_lockoutRemaining?.inSeconds ?? 0) % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              size: 100,
              color: SafePlayColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Account Locked',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SafePlayColors.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Too many failed attempts. Please wait $minutes:${seconds.toString().padLeft(2, '0')} before trying again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SafePlayColors.brandTeal500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
