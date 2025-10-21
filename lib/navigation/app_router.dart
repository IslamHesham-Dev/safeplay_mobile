import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user_type.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/child_selector_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/parent_login_screen.dart';
import '../screens/auth/parent_signup_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/auth/delete_account_screen.dart';
import '../screens/bright/bright_dashboard_screen.dart';
import '../screens/junior/junior_dashboard_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/parent/incident_detail_screen.dart';
import '../screens/parent/add_child_screen.dart';
import '../screens/parent/edit_child_screen.dart';
import '../screens/parent/junior_auth_setup_screen.dart';
import '../screens/parent/bright_auth_setup_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/teacher_login_screen.dart';
import '../screens/teacher/teacher_signup_screen.dart';
import '../models/user_profile.dart';
import '../screens/splash_screen.dart';
import 'route_names.dart';

/// Main app router configuration
class AppRouter {
  AppRouter(this.authProvider);

  final AuthProvider authProvider;
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigatorKey => _rootNavigatorKey;

  GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: RouteNames.splash,
        debugLogDiagnostics: true,
        refreshListenable: authProvider,
        redirect: _handleRedirect,
        routes: [
          GoRoute(
            path: RouteNames.splash,
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: RouteNames.login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: RouteNames.parentLogin,
            builder: (context, state) => const ParentLoginScreen(),
          ),
          GoRoute(
            path: RouteNames.parentSignup,
            builder: (context, state) => const ParentSignupScreen(),
          ),
          GoRoute(
            path: RouteNames.teacherLogin,
            builder: (context, state) => const TeacherLoginScreen(),
          ),
          GoRoute(
            path: RouteNames.teacherSignup,
            builder: (context, state) => const TeacherSignupScreen(),
          ),
          GoRoute(
            path: RouteNames.forgotPassword,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: RouteNames.emailVerification,
            builder: (context, state) => const EmailVerificationScreen(),
          ),
          GoRoute(
            path: RouteNames.changePassword,
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: RouteNames.deleteAccount,
            builder: (context, state) => const DeleteAccountScreen(),
          ),
          GoRoute(
            path: RouteNames.childSelector,
            builder: (context, state) => const ChildSelectorScreen(),
          ),
          GoRoute(
            path: RouteNames.juniorDashboard,
            builder: (context, state) => const JuniorDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.brightDashboard,
            builder: (context, state) => const BrightDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.parentDashboard,
            builder: (context, state) => const ParentDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.teacherDashboard,
            builder: (context, state) => const TeacherDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.parentIncidentDetail,
            builder: (context, state) => IncidentDetailScreen(
              incidentData: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: RouteNames.parentAddChild,
            builder: (context, state) => const AddChildScreen(),
          ),
          GoRoute(
            path: RouteNames.parentEditChild,
            builder: (context, state) => EditChildScreen(
              child: state.extra as ChildProfile,
            ),
          ),
          GoRoute(
            path: RouteNames.juniorAuthSetup,
            builder: (context, state) => JuniorAuthSetupScreen(
              child: state.extra as ChildProfile,
            ),
          ),
          GoRoute(
            path: RouteNames.brightAuthSetup,
            builder: (context, state) => BrightAuthSetupScreen(
              child: state.extra as ChildProfile,
            ),
          ),
          GoRoute(
            path: RouteNames.parentChangePassword,
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: RouteNames.parentDeleteAccount,
            builder: (context, state) => const DeleteAccountScreen(),
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page not found: ${state.uri.path}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final hasParent = authProvider.hasParentSession;
    final hasChild = authProvider.hasChildSession;
    final hasTeacher = authProvider.hasTeacherSession;

    print('🔄 Router: Handling redirect for $location');
    print(
        '🔄 Router: hasParent=$hasParent, hasChild=$hasChild, hasTeacher=$hasTeacher');
    print('🔄 Router: currentUser=${authProvider.currentUser?.name}');

    if (location == RouteNames.splash) {
      print('🔄 Router: At splash screen, no redirect');
      return null;
    }

    if (!_requiresAuth(location)) {
      print('🔄 Router: Public route, checking if user is authenticated');
      if (hasParent || hasChild || hasTeacher) {
        final destination = _defaultDestination();
        print('🔄 Router: User authenticated, redirecting to $destination');
        return destination;
      }
      print('🔄 Router: Public route, no redirect needed');
      return null;
    }

    // Special handling for change password route - only allow authenticated parents
    if (location == RouteNames.changePassword) {
      if (!hasParent) {
        print(
            '🔄 Router: Change password requires parent authentication, redirecting to login');
        return RouteNames.login;
      }
      print(
          '🔄 Router: Parent authenticated for change password, allowing access');
      return null;
    }

    if (!hasParent && !hasChild && !hasTeacher) {
      print('🔄 Router: No authentication, redirecting to login');
      return RouteNames.login;
    }

    if (hasParent && _isChildArea(location)) {
      print(
          '🔄 Router: Parent trying to access child area, redirecting to parent dashboard');
      return RouteNames.parentDashboard;
    }

    if (hasChild && (_isParentArea(location) || _isTeacherArea(location))) {
      final destination = _childDashboardRoute();
      print(
          '🔄 Router: Child trying to access parent/teacher area, redirecting to $destination');
      return destination;
    }

    if (hasTeacher && (_isParentArea(location) || _isChildArea(location))) {
      print(
          '🔄 Router: Teacher trying to access parent/child area, redirecting to teacher dashboard');
      return RouteNames.teacherDashboard;
    }

    if (hasParent && _isTeacherArea(location)) {
      print(
          '🔄 Router: Parent trying to access teacher area, redirecting to parent dashboard');
      return RouteNames.parentDashboard;
    }

    print('🔄 Router: No redirect needed');
    return null;
  }

  bool _requiresAuth(String path) => !_publicRoutes.contains(path);

  bool _isChildArea(String path) =>
      path.startsWith(RouteNames.juniorDashboard) ||
      path.startsWith(RouteNames.brightDashboard) ||
      path.startsWith('/bright/') ||
      path.startsWith('/junior/');

  bool _isParentArea(String path) =>
      path.startsWith(RouteNames.parentDashboard) ||
      path.startsWith('/parent/');

  bool _isTeacherArea(String path) =>
      path.startsWith(RouteNames.teacherDashboard) ||
      path.startsWith('/teacher/');

  String _childDashboardRoute() {
    final child = authProvider.currentChild;
    if (child == null) {
      return RouteNames.login;
    }

    switch (child.userType) {
      case UserType.juniorChild:
        return RouteNames.juniorDashboard;
      case UserType.brightChild:
        return RouteNames.brightDashboard;
      default:
        return child.ageGroup == AgeGroup.bright
            ? RouteNames.brightDashboard
            : RouteNames.juniorDashboard;
    }
  }

  String _defaultDestination() {
    if (authProvider.hasChildSession) {
      return _childDashboardRoute();
    }
    if (authProvider.hasTeacherSession) {
      return RouteNames.teacherDashboard;
    }
    return RouteNames.parentDashboard;
  }

  static const Set<String> _publicRoutes = {
    RouteNames.login,
    RouteNames.parentLogin,
    RouteNames.parentSignup,
    RouteNames.teacherLogin,
    RouteNames.teacherSignup,
    RouteNames.forgotPassword,
    RouteNames.emailVerification,
    RouteNames.deleteAccount,
    RouteNames.childSelector,
  };
}
