# WebView Plugin Registration Fix

## Error Encountered

```
PlatformException(error, java.lang.IllegalStateException: 
Trying to create a platform view of unregistered type: com.pichillilorenzo/flutter_inappwebview
```

## Why This Happens

The `flutter_inappwebview` plugin requires **native Android code** to be compiled into your app. When you add a new plugin and run `flutter pub get`, the Dart code is updated, but the native Android/iOS code needs a **full rebuild** - hot reload is not enough.

## ✅ Solution: Full Rebuild Required

### Step 1: Stop the Running App

**In Android Studio/VS Code:**
- Press the **Stop** button (red square)
- Or close the app on your device/emulator

**In Terminal:**
- Press `Ctrl+C` to stop the running process

### Step 2: Clean and Rebuild

```bash
cd safeplay_mobile

# Clean the build
flutter clean

# Get dependencies again
flutter pub get

# IMPORTANT: Full rebuild (not hot reload!)
flutter run
```

### Step 3: Wait for Full Build

- The first build will take **2-5 minutes** (it's compiling native code)
- You'll see "Running Gradle task 'assembleDebug'..." - this is normal
- Wait until you see "✓ Built build/app/outputs/flutter-apk/app-debug.apk"

### Step 4: Test Again

Once the app is fully rebuilt and running:
1. Navigate to Bright dashboard
2. Scroll to simulations
3. Tap any simulation
4. Tap "Start Simulation"
5. Should now work without the error!

---

## Alternative: Rebuild from IDE

### Android Studio

1. Stop the app
2. Click **File** → **Invalidate Caches / Restart**
3. Wait for indexing to complete
4. Click the **Run** button (green play icon)

### VS Code

1. Stop the app (red square)
2. Open Command Palette (`Ctrl+Shift+P`)
3. Type: "Flutter: Clean Project"
4. Then: "Flutter: Run"

---

## Important Notes

### Hot Reload vs Full Rebuild

| Method | When to Use | Speed | Registers Plugins |
|--------|-------------|-------|-------------------|
| Hot Reload (`r`) | UI changes only | Fast (1-2 sec) | ❌ No |
| Hot Restart (`R`) | State changes | Medium (5-10 sec) | ❌ No |
| Full Rebuild | New plugins, native changes | Slow (2-5 min) | ✅ Yes |

**Rule of Thumb:**
- Added a new dependency? → **Full rebuild required**
- Changed Dart code only? → Hot reload is fine
- Changed AndroidManifest.xml or Info.plist? → **Full rebuild required**

---

## Verify Plugin Registration

After the full rebuild, you can verify the plugin is registered:

```bash
flutter pub get
flutter run --verbose
```

Look for these lines in the output:
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

Then check the app - WebView should work!

---

## Still Not Working?

### If error persists after full rebuild:

1. **Delete build folders manually:**
   ```bash
   cd safeplay_mobile
   rm -rf build
   rm -rf android/build
   rm -rf android/app/build
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check Flutter version:**
   ```bash
   flutter --version
   ```
   Make sure you're on Flutter 3.0+

3. **Update flutter_inappwebview:**
   ```bash
   flutter pub upgrade flutter_inappwebview
   ```

4. **Try on a different device/emulator:**
   - Physical device vs emulator
   - Different Android version

---

## Prevention for Future

When adding any plugin that has native code (not just pure Dart), always:

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. **Stop the running app completely**
4. Run `flutter run` for full rebuild
5. Test the new feature

**Never rely on hot reload** after adding a plugin!

---

## Summary

The issue is **normal** when adding `flutter_inappwebview` - it just needs a full rebuild because it contains native Android/iOS code that must be compiled.

**Quick Fix:**
```bash
# Stop app (Ctrl+C)
flutter clean
flutter pub get
flutter run
# Wait 2-5 minutes for full build
# Test simulations again ✓
```

After this, the simulations should work perfectly! 🎉


