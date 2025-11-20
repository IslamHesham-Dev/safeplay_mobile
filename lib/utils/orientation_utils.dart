import 'package:flutter/services.dart';

/// Shared list of orientations supported across the SafePlay app.
const List<DeviceOrientation> kAllDeviceOrientations = <DeviceOrientation>[
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

/// Allows the app to freely rotate by enabling every supported orientation.
Future<void> allowAllDeviceOrientations() =>
    SystemChrome.setPreferredOrientations(kAllDeviceOrientations);
