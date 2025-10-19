/// Route names for the SafePlay app
///
/// All routes are defined as constants to avoid typos and enable
/// easy refactoring.
class RouteNames {
  // Root routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication routes
  static const String login = '/login';
  static const String parentLogin = '/parent-login';
  static const String parentSignup = '/parent-signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String changePassword = '/change-password';
  static const String deleteAccount = '/delete-account';

  // Child authentication
  static const String childSelector = '/child-selector';
  static const String juniorLogin = '/junior-login';
  static const String brightLogin = '/bright-login';

  // Junior Explorer routes
  static const String juniorDashboard = '/junior';
  static const String juniorExplore = '/junior/explore';
  static const String juniorGames = '/junior/games';
  static const String juniorStories = '/junior/stories';
  static const String juniorMath = '/junior/math';
  static const String juniorCreate = '/junior/create';
  static const String juniorRewards = '/junior/rewards';

  // Bright Minds routes
  static const String brightDashboard = '/bright';
  static const String brightProfile = '/bright/profile';
  static const String brightForum = '/bright/forum';
  static const String brightMood = '/bright/mood';
  static const String brightGames = '/bright/games';

  // Activity routes
  static const String activityDetail = '/activity/:id';
  static const String activityPlayer = '/activity/:id/play';

  // Parent routes
  static const String parentDashboard = '/parent';
  static const String parentIncidentDetail = '/parent/incident';
  static const String parentChildren = '/parent/children';
  static const String parentChildDetail = '/parent/children/:id';
  static const String parentAddChild = '/parent/children/add';
  static const String parentEditChild = '/parent/children/edit';
  static const String juniorAuthSetup = '/parent/children/junior-auth-setup';
  static const String brightAuthSetup = '/parent/children/bright-auth-setup';
  static const String parentAnalytics = '/parent/analytics';
  static const String parentSettings = '/parent/settings';
  static const String parentNotifications = '/parent/notifications';
  static const String parentChangePassword = '/parent/change-password';
  static const String parentDeleteAccount = '/parent/delete-account';

  // Common routes
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';

  // Helper methods
  static String activityDetailPath(String id) => '/activity/$id';
  static String activityPlayerPath(String id) => '/activity/$id/play';
  static String parentChildDetailPath(String id) => '/parent/children/$id';
}
