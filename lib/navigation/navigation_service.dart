import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Navigation service for programmatic navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a route
  void navigateTo(String route, {Object? extra}) {
    if (context != null) {
      context!.go(route, extra: extra);
    }
  }

  /// Push a route
  void push(String route, {Object? extra}) {
    if (context != null) {
      context!.push(route, extra: extra);
    }
  }

  /// Pop the current route
  void pop<T>([T? result]) {
    if (context != null && context!.canPop()) {
      context!.pop(result);
    }
  }

  /// Navigate back to a specific route
  void popUntil(String route) {
    while (context != null && context!.canPop()) {
      final currentRoute = GoRouterState.of(context!).uri.path;
      if (currentRoute == route) {
        break;
      }
      pop();
    }
  }

  /// Replace current route
  void replace(String route, {Object? extra}) {
    if (context != null) {
      context!.replace(route, extra: extra);
    }
  }

  // Convenience navigation methods

  /// Navigate to login page
  void goToLogin() => navigateTo(RouteNames.login);

  /// Navigate to parent dashboard
  void goToParentDashboard() => navigateTo(RouteNames.parentDashboard);

  /// Navigate to junior dashboard
  void goToJuniorDashboard() => navigateTo(RouteNames.juniorDashboard);

  /// Navigate to bright dashboard
  void goToBrightDashboard() => navigateTo(RouteNames.brightDashboard);

  /// Navigate to child selector
  void goToChildSelector() => navigateTo(RouteNames.childSelector);

  /// Navigate to activity detail
  void goToActivityDetail(String activityId) {
    navigateTo(RouteNames.activityDetailPath(activityId));
  }

  /// Navigate to activity player
  void goToActivityPlayer(String activityId) {
    navigateTo(RouteNames.activityPlayerPath(activityId));
  }

  /// Navigate to parent child detail
  void goToParentChildDetail(String childId) {
    navigateTo(RouteNames.parentChildDetailPath(childId));
  }

  /// Navigate to settings
  void goToSettings() => navigateTo(RouteNames.settings);

  /// Show bottom sheet
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    if (context == null) return null;

    return showModalBottomSheet<T>(
      context: context!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  /// Show dialog
  Future<T?> showDialogBox<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    if (context == null) return null;

    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  /// Show snackbar
  void showSnackBar(String message,
      {Duration? duration, Color? backgroundColor}) {
    if (context == null) return;

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show success message
  void showSuccess(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  /// Show error message
  void showError(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Show info message
  void showInfo(String message) {
    showSnackBar(message, backgroundColor: Colors.blue);
  }
}

