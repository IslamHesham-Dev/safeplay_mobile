# PhET Simulation Troubleshooting Guide

## Black Screen Issues

If you're seeing a black screen when loading simulations, try these solutions:

### 1. Check Internet Connection
- PhET simulations require an active internet connection
- Test on Wi-Fi for best performance
- Try loading https://phet.colorado.edu in a browser to verify PhET is accessible

### 2. Wait for Loading
- Simulations can take 5-10 seconds to load initially
- Look for a loading indicator
- Try tapping the screen or waiting longer

### 3. Android Permissions

**Add to `android/app/src/main/AndroidManifest.xml`:**

```xml
<manifest>
    <!-- Add these before <application> tag -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        ...
        android:usesCleartextTraffic="true">
        ...
    </application>
</manifest>
```

### 4. iOS Permissions

**Add to `ios/Runner/Info.plist`:**

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<key>io.flutter.embedded_views_preview</key>
<true/>
```

### 5. Clear Cache and Restart

```bash
cd safeplay_mobile
flutter clean
flutter pub get
flutter run
```

### 6. Test URLs Directly

Verify these URLs work in your device browser:
- https://phet.colorado.edu/sims/html/states-of-matter-basics/latest/states-of-matter-basics_en.html
- https://phet.colorado.edu/sims/html/balloons-and-static-electricity/latest/balloons-and-static-electricity_en.html
- https://phet.colorado.edu/sims/html/density/latest/density_en.html

### 7. WebView Settings

The app already has these settings enabled:
```dart
InAppWebViewSettings(
  javaScriptEnabled: true,
  mediaPlaybackRequiresUserGesture: false,
  allowsInlineMediaPlayback: true,
  useHybridComposition: true, // For better Android performance
)
```

### 8. Debug Mode

Add this to see WebView console logs:

```dart
onConsoleMessage: (controller, consoleMessage) {
  debugPrint('WebView Console: ${consoleMessage.message}');
},
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Black screen on Android | Add `android:usesCleartextTraffic="true"` to AndroidManifest.xml |
| Black screen on iOS | Add NSAppTransportSecurity to Info.plist |
| Slow loading | Wait 10-15 seconds, check internet speed |
| Nothing appears | Verify PhET.colorado.edu is accessible in your region |
| Crashes on tap | Update flutter_inappwebview to latest version |

## Test Command

Run with verbose logging:
```bash
flutter run --verbose
```

## Still Not Working?

1. Try on a different device
2. Test on emulator vs real device
3. Check if PhET is blocked by your network/firewall
4. Try mobile data instead of Wi-Fi
5. Contact PhET support if simulations don't work in any browser

## Quick Fix for States of Matter

The URL is correct: 
```
https://phet.colorado.edu/sims/html/states-of-matter-basics/latest/states-of-matter-basics_en.html
```

If still black screen:
1. Wait 10 seconds after opening
2. Tap on the preview area
3. Try fullscreen mode (Start Simulation button)
4. Check device network settings


