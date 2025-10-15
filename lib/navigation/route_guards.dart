import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user_profile.dart';
import '../models/user_type.dart';
import '../providers/auth_provider.dart';
import 'route_names.dart';

/// Authentication guard that checks if user is authenticated
class AuthGuard {
  AuthGuard(this.authProvider);

  final AuthProvider authProvider;

  /// Check if user is authenticated
  Future<String?> checkAuth(BuildContext context, GoRouterState state) async {
    if (!authProvider.isAuthenticated) {
      return RouteNames.login;
    }
    return null;
  }

  /// Check if user is a parent
  Future<String?> checkParentAuth(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authRedirect = await checkAuth(context, state);
    if (authRedirect != null) return authRedirect;

    final user = authProvider.currentUser;
    if (user == null || !user.userType.isAdult) {
      return _defaultDestination();
    }

    return null;
  }

  /// Check if user is a child
  Future<String?> checkChildAuth(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authRedirect = await checkAuth(context, state);
    if (authRedirect != null) return authRedirect;

    if (!authProvider.hasChildSession) {
      return _defaultDestination();
    }

    return null;
  }

  /// Check if user is a junior child (6-8)
  Future<String?> checkJuniorAuth(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authRedirect = await checkChildAuth(context, state);
    if (authRedirect != null) return authRedirect;

    final child = authProvider.currentChild;
    if (child == null) {
      return RouteNames.login;
    }

    if (child.userType != UserType.juniorChild &&
        child.ageGroup != AgeGroup.junior) {
      return _childDashboard(child);
    }

    return null;
  }

  /// Check if user is a bright child (9-12)
  Future<String?> checkBrightAuth(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authRedirect = await checkChildAuth(context, state);
    if (authRedirect != null) return authRedirect;

    final child = authProvider.currentChild;
    if (child == null) {
      return RouteNames.login;
    }

    if (child.userType != UserType.brightChild &&
        child.ageGroup != AgeGroup.bright) {
      return _childDashboard(child);
    }

    return null;
  }

  /// Check if user is NOT authenticated (for login/signup pages)
  Future<String?> checkGuestOnly(
    BuildContext context,
    GoRouterState state,
  ) async {
    if (authProvider.isAuthenticated) {
      return _defaultDestination();
    }

    return null;
  }

  String _defaultDestination() {
    if (authProvider.hasChildSession) {
      return _childDashboard(authProvider.currentChild);
    }
    return _parentDashboard(authProvider.currentUser);
  }

  String _childDashboard(ChildProfile? child) {
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

  String _parentDashboard(UserProfile? user) {
    switch (user?.userType) {
      case UserType.parent:
      case UserType.teacher:
      case UserType.counselor:
      case UserType.admin:
        return RouteNames.parentDashboard;
      case UserType.juniorChild:
        return RouteNames.juniorDashboard;
      case UserType.brightChild:
        return RouteNames.brightDashboard;
      case UserType.guest:
      case null:
        return RouteNames.login;
    }
  }
}

/// Parent control guard for content restrictions
class ParentControlGuard {
  ParentControlGuard(this.authProvider);

  final AuthProvider authProvider;

  /// Check if child can access specific content
  Future<bool> canAccessContent(String childId, String contentId) async {
    // TODO: Implement content filtering logic
    // Check parental controls, age restrictions, etc.
    return true;
  }

  /// Check if child has screen time available
  Future<bool> hasScreenTimeAvailable(String childId) async {
    // TODO: Implement screen time checking
    return true;
  }

  /// Check if current time is within allowed schedule
  Future<bool> isWithinAllowedSchedule(String childId) async {
    // TODO: Implement schedule checking
    return true;
  }
}

