import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import 'design_system/theme.dart';
import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'providers/activity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/child_provider.dart';
import 'services/activity_service.dart';
import 'services/offline_storage_service.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'utils/orientation_utils.dart';
// Database initialization removed - it requires admin permissions and should be run manually
// import 'services/database_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();

  // Set preferred orientations (not applicable on web)
  if (!kIsWeb) {
    await allowAllDeviceOrientations();
  }

  runApp(const SafePlayApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Database initialization removed - it requires admin permissions
    // and causes permission errors on app startup for regular users.
    // Database seeding should be done manually by admins or through a separate script.
    // If needed, uncomment and run only for admin/teacher accounts:
    // final dbInitializer = DatabaseInitializer();
    // await dbInitializer.initializeDatabase();
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization error: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class SafePlayApp extends StatefulWidget {
  const SafePlayApp({super.key});

  @override
  State<SafePlayApp> createState() => _SafePlayAppState();
}

class _SafePlayAppState extends State<SafePlayApp> {
  late final AuthService _authService;
  late final OfflineStorageService _offlineStorage;
  late final ActivityService _activityService;
  late final SyncService _syncService;
  late final NotificationService _notificationService;
  bool _notificationNavigatorRegistered = false;
  AppRouter? _appRouter;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _offlineStorage = OfflineStorageService();
    _activityService = ActivityService(offlineStorage: _offlineStorage);
    _syncService = SyncService(_offlineStorage, _activityService);
    _notificationService = NotificationService();
    unawaited(_syncService.initialize());
    unawaited(_notificationService.initialize());
  }

  @override
  void dispose() {
    _syncService.dispose();
    unawaited(_offlineStorage.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(_authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChildProvider(_authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(_activityService),
        ),
        Provider<SyncService>.value(
          value: _syncService,
        ),
        Provider<NotificationService>.value(
          value: _notificationService,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          _appRouter ??= AppRouter(authProvider);
          if (!_notificationNavigatorRegistered && _appRouter != null) {
            _notificationService.registerNavigatorKey(
              _appRouter!.navigatorKey,
            );
            _notificationNavigatorRegistered = true;
          }

          return MaterialApp.router(
            title: 'SafePlay Portal',
            theme: SafePlayTheme.lightTheme,
            routerConfig: _appRouter!.router,
            scrollBehavior: const SafePlayScrollBehavior(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SafePlayScrollBehavior extends MaterialScrollBehavior {
  const SafePlayScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}
