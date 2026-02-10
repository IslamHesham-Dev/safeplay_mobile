# SafePlay Mobile

<div align="center">

**A Flutter-based educational mobile app for children (ages 6-12), parents, and teachers**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)

**Version:** 1.0.0+1  
**Status:** Active Development  
**Last Updated:** February 2026

[Features](#features) • [Installation](#installation) • [Architecture](#architecture) • [Documentation](#documentation) • [App Showcase](#app-showcase)

</div>

---

## App Showcase

View screenshots, videos, and demonstrations of SafePlay Mobile in action:

**[View App Showcase](https://drive.google.com/drive/folders/1KqcR9Bb67L80J3E9ZA4FobT1jjQynCo_)**

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [User Roles](#user-roles)
- [Security](#security)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Resources](#resources)
- [Support](#support)

---

## Overview

**SafePlay Mobile** is a comprehensive educational platform designed to provide safe, engaging, and curriculum-aligned learning experiences for children. Built with Flutter, the app features age-appropriate authentication, gamified learning activities, real-time chat safety monitoring with AI, and robust parental controls.

### Key Highlights

- **PYP Curriculum Integration** - Aligned with IB Primary Years Programme (Phase 1-5)
- **AI Safety Monitoring** - Real-time chat safety using DeepSeek V3.1
- **Gamified Learning** - XP, levels, achievements, and daily streaks
- **Interactive Content** - Science simulations, math games, digital books
- **Multi-Role Support** - Children, parents, and teachers
- **Child-Friendly Security** - Picture passwords, PIN codes, and biometric auth
- **Cross-Platform** - iOS, Android, Web, and Desktop support

---

## Features

### Authentication System

#### Junior Explorer (Ages 6-8)
- **Picture Password Authentication**
  - 4×4 emoji grid with 4-picture sequence
  - Animated selection with haptic feedback
  - Secure SHA-256 hashing
  - 3 failed attempts → 15-minute lockout

#### Bright Minds (Ages 9-12)
- **Picture + PIN Authentication**
  - 12-picture gallery (choose 3)
  - 4-digit PIN with strength validation
  - Two-stage authentication flow
  - 5 failed attempts → 30-minute lockout

#### Parent & Teacher Access
- Email/password authentication
- Biometric login (Face ID/Touch ID)
- Password reset via email
- Secure session management
- Multi-child/student management

---

### Learning Features

#### For Children

**Junior Explorer Dashboard (6-8 years)**
- Colorful, touch-optimized interface (48px+ targets)
- Animated progress ring showing daily completion
- Streak tracker
- Sage the Shield mascot with animations
- Subject-specific activity cards
- Gamified XP and level system

**Bright Minds Dashboard (9-12 years)**
- Modern, sleeker design (44px touch targets)
- Advanced progress analytics
- Mood check-ins
- Peer forum (moderated)
- Self-paced learning paths

**Interactive Learning Activities**
- **Science Simulations** - States of Matter, Density, Static Electricity
- **Math Games** - Area Models, Equality Explorer, Number Patterns
- **Digital Books** - Interactive PDFs with narration
- **Phonics Games** - Word building, letter recognition
- **Creative Activities** - Drawing, storytelling
- **Break Activities** - Brain breaks and mindfulness

#### For Parents

**Parent Dashboard**
- Real-time child progress monitoring
- AI Safety Alerts (chat monitoring)
- Activity history and analytics
- Screen time management
- Content filtering controls
- Achievement tracking
- Direct messaging with teachers

#### For Teachers

**Teacher Dashboard**
- Custom activity builder
- Student progress tracking
- Classroom management
- Assignment creation
- Question template library
- Real-time messaging with students
- Analytics and reporting

---

### AI Safety Monitoring

**DeepSeek V3.1 Integration** (via OpenRouter)

The app includes real-time chat safety monitoring to protect children:

- **Automated Threat Detection**
  - Profanity filtering
  - Bullying detection
  - Sensitive topic identification
  - Stranger danger alerts

- **Parent Dashboard Alerts**
  - Real-time incident notifications
  - Message context and classification
  - Manual review and escalation
  - Configurable sensitivity levels

**Setup:**
```bash
flutter run \
  --dart-define=OPENROUTER_API_KEY=sk-or-************ \
  --dart-define=OPENROUTER_APP_URL=https://safeplay.app \
  --dart-define=OPENROUTER_APP_NAME="SafePlay Mobile"
```

> **Security Note:** Never commit API keys. Use `--dart-define`, environment variables, or secure platform storage.

---

### Gamification System

- **Experience Points (XP)** - Earned from completing activities
- **Leveling System** - Progressive difficulty unlocks
- **Daily Streaks** - Consecutive login rewards
- **Achievements** - Milestone badges and trophies
- **Leaderboards** - Classroom and global rankings
- **Rewards** - Avatar customization, themes

---

## Architecture

### Technology Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | Provider |
| **Navigation** | GoRouter |
| **Backend** | Firebase (Auth, Firestore, Storage, Analytics) |
| **AI Safety** | DeepSeek V3.1 (OpenRouter) |
| **Local Storage** | Shared Preferences, Flutter Secure Storage |
| **Audio** | Flutter TTS, Audioplayers |
| **PDF Rendering** | Flutter PDFView |
| **WebView** | Flutter InAppWebView |

### Design Patterns

- **MVVM** (Model-View-ViewModel)
- **Provider Pattern** for reactive state management
- **Repository Pattern** for data abstraction
- **Service Locator** for dependency injection
- **Factory Pattern** for object creation

### State Management Architecture

```dart
// Provider-based reactive state
┌─────────────────┐
│   UI Widgets    │
└────────┬────────┘
         │ watch/listen
         ↓
┌─────────────────┐
│   Providers     │  (AuthProvider, ChildProvider, ActivityProvider)
└────────┬────────┘
         │ calls
         ↓
┌─────────────────┐
│    Services     │  (AuthService, FirestoreService, AnalyticsService)
└────────┬────────┘
         │ accesses
         ↓
┌─────────────────┐
│  Data Sources   │  (Firebase, Local Storage)
└─────────────────┘
```

### Firebase Architecture

```
Firestore Collections:
├── users/                    # Parent & teacher accounts
│   ├── {userId}/
│   │   ���── profile
│   │   └── settings
├── children/                 # Child profiles
│   ├── {childId}/
│   │   ├── profile
│   │   ├── progress
│   │   └── achievements
├── activities/               # Learning activities
├── activityProgress/         # Completion tracking
├── curriculumQuestions/      # Question bank
├── breakActivities/          # Mindfulness activities
├── childInboxMessages/       # Student messages
├── teacherInboxMessages/     # Teacher messages
└── safetyAlerts/            # AI-generated alerts
```

---

## Installation

### Prerequisites

- **Flutter SDK:** 3.0 or higher
- **Dart SDK:** 3.0 or higher
- **Development Tools:**
  - Xcode 14+ (for iOS development)
  - Android Studio (for Android development)
  - VS Code or Android Studio with Flutter plugins
- **Firebase Account** with project setup
- **OpenRouter API Key** (optional, for AI safety monitoring)

### Setup Steps

#### 1. Clone the Repository

```bash
git clone https://github.com/IslamHesham-Dev/safeplay_mobile.git
cd safeplay_mobile
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Configure Firebase

Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Configure Firebase for your project:
```bash
flutterfire configure
```

Follow the prompts to:
- Select or create a Firebase project
- Choose platforms (iOS, Android, Web)
- Generate `firebase_options.dart`

#### 4. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

#### 5. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

#### 6. Configure Environment Variables

Create a `.env` file (use `.env.example` as template):
```bash
cp .env.example .env
```

Add your API keys:
```env
OPENROUTER_API_KEY=sk-or-************
OPENROUTER_APP_URL=https://safeplay.app
OPENROUTER_APP_NAME=SafePlay Mobile
```

#### 7. Run the App

**iOS:**
```bash
flutter run -d ios
```

**Android:**
```bash
flutter run -d android
```

**Web:**
```bash
flutter run -d chrome
```

**With Environment Variables:**
```bash
flutter run --dart-define-from-file=.env
```

---

## Project Structure

```
safeplay_mobile/
├── lib/
│   ├── design_system/          # Design tokens, colors, themes
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── theme.dart
│   ├── models/                 # Data models (User, Child, Activity)
│   │   ├── user_model.dart
│   │   ├── child_model.dart
│   │   ├── activity_model.dart
│   │   └── curriculum_question.dart
│   ├── navigation/             # Routing and navigation guards
│   │   ├── app_router.dart
│   │   ├── route_names.dart
│   │   └── auth_guard.dart
│   ├── providers/              # State management providers
│   │   ├── auth_provider.dart
│   │   ├── child_provider.dart
│   │   ├── activity_provider.dart
│   │   └── safety_provider.dart
│   ├── services/               # Business logic and API calls
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   ├── analytics_service.dart
│   │   ├── curriculum_service.dart
│   │   └── ai_safety_service.dart
│   ├── screens/                # UI screens
│   │   ├── auth/               # Authentication screens
│   │   ├── child/              # Child dashboards and activities
│   │   ├── parent/             # Parent dashboard
│   │   ├── teacher/            # Teacher dashboard
│   │   └── shared/             # Shared screens
│   ├── widgets/                # Reusable UI components
│   │   ├── activity_card.dart
│   │   ├── progress_ring.dart
│   │   ├── mascot_widget.dart
│   │   └── safety_alert_card.dart
│   ├── utils/                  # Utilities and helpers
│   │   ├── constants.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── main.dart              # App entry point
├── assets/
│   ├── images/                 # Image assets
│   ├── audio/                  # Audio files (narration, sounds)
│   └── books/                  # PDF books
├── android/                    # Android-specific config
├── ios/                        # iOS-specific config
├── web/                        # Web-specific config
├── test/                       # Unit and widget tests
├── integration_test/           # Integration tests
├── pubspec.yaml               # Dependencies
├── firebase.json              # Firebase configuration
├── firestore.rules            # Firestore security rules
├── firestore.indexes.json     # Firestore indexes
└── README.md                  # This file
```

---

## User Roles

### Children (Junior Explorer & Bright Minds)

**Capabilities:**
- Complete learning activities
- Play educational games
- Read digital books
- Track progress and achievements
- Earn XP and level up
- Customize avatars
- Message teachers (monitored)

**Restrictions:**
- No access to parent/teacher features
- Age-appropriate content filtering
- Monitored chat communications
- Time-limited sessions (configurable by parent)

### Parents

**Capabilities:**
- Monitor child progress
- View AI safety alerts
- Manage screen time
- Configure content filters
- View activity history
- Communicate with teachers
- Export progress reports

### Teachers

**Capabilities:**
- Create custom activities
- Assign tasks to students
- Monitor student progress
- Build question templates
- Message students (monitored)
- Generate classroom reports
- Access curriculum library

---

## Security

### Authentication Security

- **Password Hashing:** SHA-256 for picture sequences
- **PIN Security:** Bcrypt-style hashing with salt
- **Lockout Policy:** Progressive delays after failed attempts
- **Session Management:** Secure token-based authentication
- **Biometric Auth:** Face ID/Touch ID for parents/teachers

### Data Protection

- **Encryption at Rest:** Flutter Secure Storage
- **Encryption in Transit:** HTTPS/TLS
- **Firebase Security Rules:** Role-based access control
- **PII Protection:** Minimal data collection, COPPA compliant
- **Parent Consent:** Required for child accounts

### AI Safety Monitoring

- **Real-time Analysis:** DeepSeek V3.1 classification
- **Privacy First:** Messages analyzed only for safety
- **Transparent Logging:** All alerts logged for review
- **Human Oversight:** Parents can review flagged content
- **Configurable Sensitivity:** Adjust detection thresholds

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Children data accessible by parents and assigned teachers
    match /children/{childId} {
      allow read: if request.auth != null && 
        (get(/databases/$(database)/documents/children/$(childId)).data.parentId == request.auth.uid ||
         request.auth.token.role == 'teacher');
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/children/$(childId)).data.parentId == request.auth.uid;
    }
  }
}
```

---

## Development

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names (camelCase for variables, PascalCase for classes)
- Document public APIs with dartdoc comments
- Keep widgets small and focused (< 200 lines)
- Use `const` constructors where possible

### State Management Best Practices

```dart
// Good: Use context.watch for rebuilding on changes
Widget build(BuildContext context) {
  final user = context.watch<AuthProvider>().currentUser;
  return Text(user?.name ?? 'Guest');
}

// Good: Use context.read for one-time actions
void _logout(BuildContext context) {
  context.read<AuthProvider>().signOut();
}

// Good: Use context.select for specific value changes
Widget build(BuildContext context) {
  final isLoading = context.select((AuthProvider p) => p.isLoading);
  return isLoading ? CircularProgressIndicator() : MyContent();
}

// Bad: Don't call async operations in build
Widget build(BuildContext context) {
  context.read<AuthProvider>().loadUser(); // Bad!
  return Container();
}
```

### Adding New Features

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Add Models** (`lib/models/`)
3. **Create Services** (`lib/services/`)
4. **Add Providers** (`lib/providers/`)
5. **Build UI** (`lib/screens/` and `lib/widgets/`)
6. **Add Routes** (update `lib/navigation/app_router.dart`)
7. **Write Tests** (`test/` and `integration_test/`)
8. **Update Documentation**

### Design System Guidelines

**Colors:**
```dart
// Brand Colors
SafePlayColors.brandTeal500     // #00A8A8
SafePlayColors.brandOrange500   // #FF8500

// Junior Explorer (6-8 years)
SafePlayColors.juniorPurple     // #9C27B0
SafePlayColors.juniorPink       // #E91E63
SafePlayColors.juniorLime       // #CDDC39
SafePlayColors.juniorCyan       // #00BCD4

// Bright Minds (9-12 years)
SafePlayColors.brightIndigo     // #3F51B5
SafePlayColors.brightTeal       // #009688
SafePlayColors.brightAmber      // #FF9800
SafePlayColors.brightDeepPurple // #673AB7
```

**Typography:**
- **Headings:** Poppins (Bold, Semi-Bold)
- **Body:** Inter (Regular)
- **Sizes:** 48, 40, 32, 24, 20, 18, 16, 14px

**Component Guidelines:**
- **Touch Targets:** 48px minimum (Junior), 44px (Bright)
- **Border Radius:** 24px (Junior), 12px (Bright)
- **Animations:** 300ms (Junior), 200ms (Bright)
- **Spacing:** 4, 8, 12, 16, 24, 32, 48px

---

## Testing

### Run Tests

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/

# With coverage
flutter test --coverage
```

### Test Structure

```
test/
├── unit/                      # Unit tests
│   ├── models_test.dart
│   ├── services_test.dart
│   └── providers_test.dart
├── widget/                    # Widget tests
│   ├── activity_card_test.dart
│   └── progress_ring_test.dart
└── integration/               # Integration tests
    ├── auth_flow_test.dart
    └── activity_flow_test.dart
```

### Writing Tests

```dart
// Unit Test Example
testWidgets('ActivityCard displays title', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ActivityCard(
        activity: Activity(title: 'Math Fun', ...),
      ),
    ),
  );

  expect(find.text('Math Fun'), findsOneWidget);
});
```

---

## Deployment

### iOS Deployment

1. **Configure Signing**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select your team and provisioning profile

2. **Build Archive**
   ```bash
   flutter build ipa
   ```

3. **Upload to App Store**
   - Use Xcode Organizer or Transporter app

### Android Deployment

1. **Generate Signing Key**
   ```bash
   keytool -genkey -v -keystore ~/safeplay-release-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias safeplay
   ```

2. **Configure Signing** (update `android/key.properties`)
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=safeplay
   storeFile=/path/to/safeplay-release-key.jks
   ```

3. **Build APK/AAB**
   ```bash
   # APK
   flutter build apk --release
   
   # App Bundle (recommended for Play Store)
   flutter build appbundle
   ```

4. **Upload to Play Store**

### Web Deployment

1. **Build for Web**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Firebase Hosting**
   ```bash
   firebase deploy --only hosting
   ```

---

## Troubleshooting

### Firebase Configuration Issues

**Problem:** Firebase not initializing
```bash
# Solution: Reconfigure Firebase
flutterfire configure
flutter pub get
flutter clean
flutter run
```

### Build Errors

**Problem:** Build failures after dependency updates
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### iOS-Specific Issues

**Problem:** CocoaPods errors
```bash
# Solution: Update pods
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

**Problem:** Signing issues
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target → Signing & Capabilities
- Choose your development team

### Android-Specific Issues

**Problem:** Gradle build failures
```bash
# Solution: Clean Gradle cache
cd android
./gradlew clean
cd ..
flutter run
```

**Problem:** SDK version conflicts
- Check `android/app/build.gradle`
- Ensure `minSdkVersion >= 21`
- Ensure `compileSdkVersion >= 33`

### AI Safety Monitoring Issues

**Problem:** OpenRouter API errors
- Verify API key is correct
- Check API quota/limits
- Ensure `--dart-define` flags are set correctly

---

## Contributing

We welcome contributions! Please follow these guidelines:

### Contribution Workflow

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Pull Request Guidelines

- Provide clear description of changes
- Include screenshots for UI changes
- Ensure all tests pass
- Follow code style guidelines
- Update documentation as needed

### Code Review Process

- At least one approval required
- All CI/CD checks must pass
- No merge conflicts
- Documentation updated

---

## Resources

### Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)

### Design Resources

- [Material Design 3](https://m3.material.io/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Cupertino Widgets](https://docs.flutter.dev/development/ui/widgets/cupertino)

### PYP Curriculum

- [IB Primary Years Programme](https://www.ibo.org/programmes/primary-years-programme/)
- PYP Language Scope and Sequence
- IB PYP Documentation

### AI Safety

- [OpenRouter Documentation](https://openrouter.ai/docs)
- [DeepSeek Models](https://platform.deepseek.com/)

### Additional Guides

For detailed implementation guides, see:
- [`GETTING_STARTED_GUIDE.md`](GETTING_STARTED_GUIDE.md) - Quick start guide
- [`COMPLETE_IMPLEMENTATION_REPORT.md`](COMPLETE_IMPLEMENTATION_REPORT.md) - Full feature list
- [`SIMULATION_IMPLEMENTATION.md`](SIMULATION_IMPLEMENTATION.md) - Science simulations setup
- [`TEACHER_ACTIVITY_BUILDER_SYSTEM.md`](TEACHER_ACTIVITY_BUILDER_SYSTEM.md) - Activity builder guide
- [`VOICEOVER_GUIDE.md`](VOICEOVER_GUIDE.md) - Audio integration guide
- [`FIRESTORE_RULES_FOR_CHILDREN.md`](FIRESTORE_RULES_FOR_CHILDREN.md) - Security rules setup

---

## Support

### Get Help

- **Issues:** [Create an issue](https://github.com/IslamHesham-Dev/safeplay_mobile/issues)
- **Discussions:** Use GitHub Discussions for questions
- **Email:** Contact the development team

### Bug Reports

When reporting bugs, please include:
- Device/platform information
- Flutter/Dart version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/logs if applicable

### Feature Requests

We love hearing your ideas! Please:
- Check existing issues first
- Provide clear use case
- Explain expected behavior
- Include mockups if applicable

---

## Project Status

### Completed Features

- Navigation system with GoRouter
- Provider-based state management
- Firebase integration (Auth, Firestore, Storage, Analytics)
- PYP Curriculum service
- Picture password authentication (Junior)
- Picture+PIN authentication (Bright)
- Parent email/password authentication
- Junior Explorer dashboard with gamification
- Bright Minds dashboard
- Parent dashboard with AI safety alerts
- Teacher dashboard and activity builder
- Science simulations (States of Matter, Density, Static Electricity)
- Math games (Area Models, Equality Explorer)
- Digital book reader with PDFs
- AI chat safety monitoring (DeepSeek V3.1)
- Custom widgets (activity cards, progress ring, mascot)
- Audio narration and text-to-speech

### In Progress

- Offline-first functionality with local caching
- Push notifications for achievements and alerts
- Advanced analytics and reporting
- Comprehensive unit and integration tests

### Planned Features

- Video content player
- Live video chat with teachers
- Collaborative learning activities
- AR/VR learning experiences
- Advanced AI tutoring
- Multi-language support (Arabic, French, Spanish)
- Accessibility improvements (screen reader, high contrast)
- Desktop apps (Windows, macOS, Linux)

---

## License

**This is a private repository.** All rights reserved.

For licensing inquiries, please contact the repository owner.

---

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- OpenRouter for AI API access
- IB Organization for PYP curriculum guidelines
- All contributors and testers

---

<div align="center">

**Built with Flutter**

**Made for children, parents, and teachers worldwide**

[![Flutter](https://img.shields.io/badge/Flutter-Powered-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)

---

**Repository:** [IslamHesham-Dev/safeplay_mobile](https://github.com/IslamHesham-Dev/safeplay_mobile)  
**Created:** October 2025  
**Last Updated:** February 2026

</div>
