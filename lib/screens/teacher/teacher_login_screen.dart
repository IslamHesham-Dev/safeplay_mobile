import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';

/// Teacher login screen with email/password
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    print('🔐 Starting teacher login process...');
    print('🔐 Email: ${_emailController.text.trim()}');
    print('🔐 Password length: ${_passwordController.text.length}');

    bool success = false;
    try {
      success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      print('🔐 Login result: $success');
      print('🔐 Current user: ${authProvider.currentUser?.name}');
      print('🔐 Current user ID: ${authProvider.currentUser?.id}');
      print('🔐 Has teacher session: ${authProvider.hasTeacherSession}');
      print('🔐 Auth error: ${authProvider.error}');
      print('🔐 Auth loading: ${authProvider.isLoading}');
    } catch (e, stackTrace) {
      print('🔐 Login exception: $e');
      print('🔐 Stack trace: $stackTrace');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (success) {
      print('🔐 Login successful, waiting for state to stabilize...');

      // Wait a moment for state to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Check final authentication state
      final hasTeacher = authProvider.hasTeacherSession;
      final currentUser = authProvider.currentUser;

      print(
          '🔐 Final state - hasTeacher: $hasTeacher, user: ${currentUser?.name}');

      if (mounted) {
        print('🔐 Navigating to teacher dashboard...');
        try {
          // Use context.go with the full path
          context.go(RouteNames.teacherDashboard);
        } catch (e) {
          print('🔐 Navigation failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Login successful but navigation failed. Please restart the app.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      print('🔐 Login failed, showing error...');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.school,
                  size: 80,
                  color: SafePlayColors.brandTeal500,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  key: const Key('teacher_login_email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  key: const Key('teacher_login_password_field'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Login'),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Sign up link
                TextButton(
                  onPressed: () => context.push(RouteNames.teacherSignup),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
