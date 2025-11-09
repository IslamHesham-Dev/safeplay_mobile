import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';

/// Main login screen with role selection
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Icon(
                Icons.security,
                size: 80,
                color: SafePlayColors.brandTeal500,
              ),
              const SizedBox(height: 16),
              Text(
                'SafePlay Portal',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: SafePlayColors.brandTeal500,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Push the cards down but keep buttons visible on shorter screens
              const Spacer(flex: 5),

              // Parent Login Button
              ElevatedButton(
                onPressed: () => context.push(RouteNames.parentLogin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafePlayColors.brandTeal500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Parent Login',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Child Login Button
              ElevatedButton(
                onPressed: () => context.push(RouteNames.unifiedChildLogin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafePlayColors.brandOrange500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.child_care, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Child Login',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Teacher Login Button
              ElevatedButton(
                onPressed: () => context.push(RouteNames.teacherLogin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafePlayColors.brightDeepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Teacher Login',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Sign up links
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => context.push(RouteNames.parentSignup),
                    child: const Text(
                      'Parent Sign Up',
                      style: TextStyle(color: SafePlayColors.brandTeal500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.teacherSignup),
                    child: const Text(
                      'Teacher Sign Up',
                      style: TextStyle(color: SafePlayColors.brandTeal500),
                    ),
                  ),
                ],
              ),

              // Smaller spacer beneath the cards/sign ups
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
