import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../widgets/auth/picture_password_grid.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';

/// Picture password login screen for Junior Explorer
class JuniorPicturePasswordLogin extends StatefulWidget {
  final String childId;
  final String childName;

  const JuniorPicturePasswordLogin({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<JuniorPicturePasswordLogin> createState() =>
      _JuniorPicturePasswordLoginState();
}

class _JuniorPicturePasswordLoginState
    extends State<JuniorPicturePasswordLogin> {
  final List<String> _pictures = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐔',
  ];

  bool _isLoading = false;
  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onSequenceComplete(List<String> sequence) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInChildWithPicturePassword(
        widget.childId,
        sequence,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${widget.childName}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Junior dashboard
        context.go(RouteNames.juniorDashboard);
      } else {
        setState(() {
          _attemptCount++;
        });

        // No lockout - children can try unlimited times

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Oops! That\'s not right. Try again! (${3 - _attemptCount} attempts left)',
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
        backgroundColor: SafePlayColors.juniorPurple,
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
                        backgroundColor: SafePlayColors.juniorPurple,
                        child: const Icon(
                          Icons.child_care,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Welcome message
                    Text(
                      'Hi ${widget.childName}!',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: SafePlayColors.juniorPurple,
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Select your 4 pictures to log in',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 32),

                    // Picture grid
                    PicturePasswordGrid(
                      pictures: _pictures,
                      sequenceLength: 4,
                      onSequenceComplete: _onSequenceComplete,
                    ),

                    const SizedBox(height: 24),

                    // Help button
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Need Help?'),
                            content: const Text(
                              'Ask your parent to help you log in or reset your picture password.',
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
}
