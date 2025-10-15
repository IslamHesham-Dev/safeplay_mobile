import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/route_names.dart';

/// Push notification service using Firebase Cloud Messaging
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _fcmTokenKey = 'fcm_token';
  GlobalKey<NavigatorState>? _navigatorKey;
  Map<String, dynamic>? _pendingNavigationPayload;

  /// Initialize notification service
  Future<void> initialize() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('Notification permission not granted');
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const incidentChannel = AndroidNotificationChannel(
      'safeplay_channel',
      'SafePlay Notifications',
      description: 'Notifications for SafePlay app',
      importance: Importance.high,
    );
    const reminderChannel = AndroidNotificationChannel(
      'safeplay_reminders',
      'SafePlay Reminders',
      description: 'Learning reminders and scheduled notifications',
      importance: Importance.high,
    );

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(incidentChannel);
      await androidImplementation.createNotificationChannel(reminderChannel);
    }

    final token = await _fcm.getToken();
    if (token != null) {
      await _saveFCMToken(token);
      debugPrint('FCM Token: $token');
    }

    _fcm.onTokenRefresh.listen(_saveFCMToken);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpenedApp(initialMessage);
    }
  }

  /// Register navigator key for deep links
  void registerNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    if (_pendingNavigationPayload != null) {
      final payload = _pendingNavigationPayload!;
      _pendingNavigationPayload = null;
      Future.microtask(() => _navigateToPayload(payload));
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showLocalNotification(
        message.notification!.title ?? 'SafePlay',
        message.notification!.body ?? '',
        message.data,
      );
    }
  }

  /// Handle notification when app is opened via tap
  void _handleNotificationOpenedApp(RemoteMessage message) {
    _navigateToPayload(message.data);
  }

  /// Show local notification
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'safeplay_channel',
      'SafePlay Notifications',
      channelDescription: 'Notifications for SafePlay app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Demo helper: show an incident alert for parents
  Future<void> showIncidentAlert({
    required String incidentId,
    required String childName,
    required String summary,
  }) async {
    final data = {
      'type': 'incident',
      'incidentId': incidentId,
      'childName': childName,
      'summary': summary,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _showLocalNotification(
      'Incident reported',
      '$childName: $summary',
      data,
    );
  }

  /// Schedule local notification (placeholder implementation)
  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'safeplay_reminders',
      'SafePlay Reminders',
      channelDescription: 'Learning reminders and scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleAchievementNotification(String achievementName) async {
    await _showLocalNotification(
      'Achievement unlocked!',
      "You've earned: $achievementName",
      {'type': 'achievement', 'achievement': achievementName},
    );
  }

  Future<void> scheduleStreakReminder() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final reminderTime =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
    await scheduleNotification(
      'Keep your streak!',
      'Complete an activity today to maintain your learning streak.',
      reminderTime,
    );
  }

  Future<void> scheduleDailyReminder(int hour) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final reminderTime =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour);
    await scheduleNotification(
      'Time to learn!',
      "Ready for today's learning adventure?",
      reminderTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payloadString = response.payload;
    if (payloadString == null || payloadString.isEmpty) {
      return;
    }

    try {
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;
      _navigateToPayload(payload);
    } catch (error) {
      debugPrint('Failed to parse notification payload: $error');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  void _navigateToPayload(Map<String, dynamic> payload) {
    final navigatorKey = _navigatorKey;
    if (navigatorKey == null) {
      _pendingNavigationPayload = payload;
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      _pendingNavigationPayload = payload;
      return;
    }

    final router = GoRouter.of(context);
    final type = payload['type'] as String? ?? '';
    switch (type) {
      case 'incident':
        router.push(RouteNames.parentIncidentDetail, extra: payload);
        break;
      default:
        router.push(RouteNames.parentDashboard);
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}
