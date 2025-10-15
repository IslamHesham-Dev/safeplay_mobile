# 🚀 SafePlay Mobile - Getting Started Guide

## Quick Start (5 Minutes)

### Step 1: Install Dependencies
```bash
cd safeplay_mobile
flutter pub get
```

### Step 2: Configure Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

Follow the prompts to:
- Select or create a Firebase project
- Choose platforms (iOS and/or Android)
- Generate configuration files

### Step 3: Set Up Firestore
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database**
4. Click **Create Database**
5. Start in **Test mode** (we'll set up security rules next)

### Step 4: Add Security Rules
In Firebase Console → Firestore → Rules, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Children collection
    match /children/{childId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource.data.parentId == request.auth.uid || 
         request.resource.data.parentId == request.auth.uid);
    }
    
    // Activities collection (read-only for users)
    match /activities/{activityId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admin can write
    }
    
    // Activity progress
    match /activityProgress/{progressId} {
      allow read, write: if request.auth != null && 
        resource.data.childId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.children;
    }
  }
}
```

Click **Publish**.

### Step 5: Run the App
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

---

## Detailed Setup

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Xcode 14+ (for iOS)
- Android Studio (for Android)
- Firebase account

### Install Flutter
```bash
# macOS/Linux
brew install flutter

# Or download from: https://flutter.dev/docs/get-started/install
```

Verify installation:
```bash
flutter doctor
```

### Firebase Configuration Details

#### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add Project**
3. Enter project name: "SafePlay"
4. Disable Google Analytics (optional)
5. Click **Create Project**

#### 2. Add iOS App
1. Click **iOS** icon
2. Enter Bundle ID: `com.safeplay.mobile`
3. Download `GoogleService-Info.plist`
4. Move to `safeplay_mobile/ios/Runner/`

#### 3. Add Android App
1. Click **Android** icon
2. Enter Package name: `com.safeplay.mobile`
3. Download `google-services.json`
4. Move to `safeplay_mobile/android/app/`

#### 4. Enable Services
In Firebase Console, enable:
- **Authentication** → Email/Password
- **Firestore Database**
- **Storage**
- **Analytics** (optional)
- **Cloud Messaging** (for notifications)
- **Crashlytics** (optional)

### First Run

1. **Start the app**
```bash
flutter run
```

2. **Create a parent account**
- Click "Sign Up"
- Enter name, email, password
- Click "Sign Up"

3. **Add a child**
- On parent dashboard, click "+"
- Enter child's name and age
- Click "Add Child"

4. **Set up child authentication**
- For Junior (6-8): Set up picture password
- For Bright (9-12): Set up picture+PIN

5. **Test child login**
- Log out from parent account
- Click "Child Login"
- Select child
- Enter picture password or picture+PIN

---

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/widgets
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Check Code Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Building for Production

### iOS

#### 1. Configure Xcode
```bash
cd ios
pod install
cd ..
```

#### 2. Open in Xcode
```bash
open ios/Runner.xcworkspace
```

#### 3. Configure Signing
- Select **Runner** target
- Go to **Signing & Capabilities**
- Select your team
- Enable capabilities:
  - Push Notifications
  - Background Modes (Remote notifications)
  - Sign in with Apple (optional)

#### 4. Build
```bash
flutter build ios --release
```

#### 5. Archive and Upload
- In Xcode: Product → Archive
- Click **Distribute App**
- Follow App Store Connect workflow

### Android

#### 1. Generate Signing Key
```bash
keytool -genkey -v -keystore ~/safeplay-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias safeplay
```

#### 2. Configure Signing
Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=safeplay
storeFile=<path-to-jks-file>
```

#### 3. Build
```bash
flutter build appbundle --release
```

#### 4. Upload to Play Store
- Go to [Google Play Console](https://play.google.com/console)
- Create app
- Upload `build/app/outputs/bundle/release/app-release.aab`
- Follow publishing workflow

---

## Troubleshooting

### Firebase Not Connecting
```bash
# Reconfigure Firebase
flutterfire configure

# Check if files exist
ls -la ios/Runner/GoogleService-Info.plist
ls -la android/app/google-services.json
```

### Build Errors
```bash
# Clean build
flutter clean
flutter pub get

# iOS: Clean pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Android: Clean gradle
cd android
./gradlew clean
cd ..
```

### Permission Issues (iOS)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>SafePlay needs camera access for activities</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SafePlay needs photo library access</string>
<key>NSMicrophoneUsageDescription</key>
<string>SafePlay needs microphone for video activities</string>
```

### Permission Issues (Android)
Already configured in `android/app/src/main/AndroidManifest.xml`.

---

## Development Tips

### Hot Reload
Press `r` in terminal to hot reload
Press `R` for hot restart

### Debug Mode
```bash
flutter run --debug
```

### Profile Mode
```bash
flutter run --profile
```

### Release Mode
```bash
flutter run --release
```

### View Logs
```bash
# All logs
flutter logs

# Filter logs
flutter logs | grep "SafePlay"
```

### Inspect Database
Use [Firestore Emulator](https://firebase.google.com/docs/emulator-suite):
```bash
firebase emulators:start
```

---

## Quick Reference

### Useful Commands
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build iOS
flutter build ios

# Build Android
flutter build apk  # or appbundle
```

### Important Files
- `lib/main.dart` - App entry point
- `lib/navigation/app_router.dart` - All routes
- `lib/services/auth_service.dart` - Authentication
- `lib/models/` - Data models
- `lib/providers/` - State management

### Key Directories
- `lib/screens/` - All app screens
- `lib/widgets/` - Reusable widgets
- `lib/services/` - Backend services
- `test/` - Tests

---

## Support

### Documentation
- [README.md](README.md) - Project overview
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Technical details
- [COMPLETE_IMPLEMENTATION_REPORT.md](COMPLETE_IMPLEMENTATION_REPORT.md) - Full report

### Resources
- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Material Design](https://m3.material.io/)

---

## Next Steps

After setup:
1. ✅ Create test accounts
2. ✅ Test all features
3. ✅ Add sample activities to Firestore
4. ✅ Test offline functionality
5. ✅ Test push notifications
6. ✅ Run performance tests
7. ✅ Submit to app stores

---

**Ready to launch SafePlay Mobile!** 🚀



