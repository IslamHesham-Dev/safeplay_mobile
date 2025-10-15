import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';

/// Email verification screen for parents
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isEmailVerified = authProvider.isEmailVerified();

    return Scaffold(
      backgroundColor: SafePlayColors.neutral50,
      appBar: AppBar(
        backgroundColor: SafePlayColors.neutral50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SafePlayColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Verify Email',
          style: TextStyle(
            color: SafePlayColors.neutral900,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Email icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: SafePlayColors.brandTeal500.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: SafePlayColors.brandTeal500,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: SafePlayColors.neutral900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                isEmailVerified
                    ? 'Your email has been verified! You can now access all features.'
                    : 'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                style: const TextStyle(
                  fontSize: 16,
                  color: SafePlayColors.neutral500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEmailVerified
                      ? SafePlayColors.success.withOpacity(0.1)
                      : SafePlayColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEmailVerified
                        ? SafePlayColors.success
                        : SafePlayColors.warning,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEmailVerified ? Icons.check_circle : Icons.access_time,
                      color: isEmailVerified
                          ? SafePlayColors.success
                          : SafePlayColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEmailVerified
                            ? 'Email Verified'
                            : 'Verification Pending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isEmailVerified
                              ? SafePlayColors.success
                              : SafePlayColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              if (isEmailVerified) ...[
                // Continue button when verified
                ElevatedButton(
                  onPressed: () => context.go(RouteNames.parentDashboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SafePlayColors.brandTeal500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue to Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                // Resend button when not verified
                ElevatedButton(
                  onPressed: _isResending ? null : _resendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SafePlayColors.brandTeal500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: 12),

                // Check verification button
                OutlinedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SafePlayColors.brandTeal500,
                    side: const BorderSide(color: SafePlayColors.brandTeal500),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                SafePlayColors.brandTeal500),
                          ),
                        )
                      : const Text(
                          'I\'ve Verified My Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],

              const SizedBox(height: 24),

              // Help text
              Text(
                'Having trouble? Check your spam folder or contact support.',
                style: TextStyle(
                  fontSize: 14,
                  color: SafePlayColors.neutral500.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendEmailVerification();

    if (!mounted) return;

    setState(() => _isResending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: SafePlayColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.error ?? 'Failed to send verification email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    final authProvider = context.read<AuthProvider>();
    await authProvider.reloadUser();

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (authProvider.isEmailVerified()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: SafePlayColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Email not yet verified. Please check your email and click the verification link.'),
          backgroundColor: SafePlayColors.warning,
        ),
      );
    }
  }
}
