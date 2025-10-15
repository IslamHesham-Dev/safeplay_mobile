# SafePlay Mobile 📱

A Flutter-based mobile companion app for the SafePlay Portal, providing native mobile experiences for children (ages 6-12) and parents with offline-first functionality and child-friendly authentication.

## 🌟 Features

### Authentication
- **Picture Password** for Junior Explorer (6-8 years)
  - 4x4 emoji grid with 4-picture sequence
  - Animated selection with visual feedback
  - Secure SHA-256 hashing
  - Failed attempt tracking with lockout
  
- **Picture + PIN** for Bright Minds (9-12 years)
  - 12-picture selection (choose 3)
  - 4-digit PIN with strength validation
  - Two-stage authentication
  - Advanced security with bcrypt-style hashing
  
- **Parent Authentication**
  - Email/password login
  - Biometric authentication (Face ID/Touch ID)
  - Password reset via email
  - Session persistence

### Junior Explorer Dashboard (Ages 6-8)
- **Colorful Interface**
  - Gradient header with profile
  - Animated progress ring showing daily progress
  - Fire emoji streak tracker
  - Sage the Shield animated mascot
  
- **Learning Activities**
  - Subject-specific activity cards
  - PYP curriculum-aligned content
  - Touch-optimized interactions (48px+ targets)
  - Gamified progression system
  
- **Engagement Features**
  - XP and level system
  - Achievement tracking
  - Daily streak rewards
  - Time-based greetings

### PYP Curriculum Integration
- Phase 1-5 progression tracking
- Subject-specific learning objectives
- Automated phase advancement
- Progress reporting
- Curriculum-aligned activity generation

## 🏗️ Architecture

### State Management
- **Provider** for reactive state management
- **AuthProvider** - User authentication and session
- **ChildProvider** - Child profiles and progress
- **ActivityProvider** - Activities and learning data

### Navigation
- **GoRouter** for declarative routing
- Authentication guards for secure access
- Deep linking support
- Nested navigation for complex flows

### Backend
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Real-time data storage
- **Firebase Storage** - Media file uploads
- **Firebase Analytics** - Usage tracking

## 📦 Installation

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Xcode 14+ (for iOS)
- Android Studio (for Android)
- Firebase account

### Setup Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd safeplay_mobile
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**

First, install the FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Then configure Firebase for your project:
```bash
flutterfire configure
```

Follow the prompts to:
- Select or create a Firebase project
- Choose platforms (iOS, Android)
- Generate configuration files

4. **Update Firebase Security Rules**

In the Firebase Console, set up security rules for Firestore:

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
      allow write: if request.auth != null;
    }
    
    // Activities collection
    match /activities/{activityId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Activity progress
    match /activityProgress/{progressId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. **Run the app**

For iOS:
```bash
flutter run -d ios
```

For Android:
```bash
flutter run -d android
```

## 🎨 Design System

### Colors
```dart
// Brand Colors
SafePlayColors.brandTeal500     // #00A8A8
SafePlayColors.brandOrange500   // #FF8500

// Junior Explorer (6-8)
SafePlayColors.juniorPurple     // #9C27B0
SafePlayColors.juniorPink       // #E91E63
SafePlayColors.juniorLime       // #CDDC39
SafePlayColors.juniorCyan       // #00BCD4

// Bright Minds (9-12)
SafePlayColors.brightIndigo     // #3F51B5
SafePlayColors.brightTeal       // #009688
SafePlayColors.brightAmber      // #FF9800
SafePlayColors.brightDeepPurple // #673AB7
```

### Typography
- **Headings:** Poppins (Bold, Semi-Bold)
- **Body:** Inter (Regular)
- **Sizes:** 48, 40, 32, 24, 20, 18, 16, 14px

### Components
- Touch targets: 48px minimum (Junior), 44px (Bright)
- Border radius: 24px (Junior), 12px (Bright)
- Animations: 300ms (Junior), 200ms (Bright)

## 📱 Screens

### Authentication Flow
1. **Splash Screen** - Checks existing session
2. **Login Screen** - Role selection (Parent/Child)
3. **Parent Login** - Email/password authentication
4. **Child Selector** - Choose child profile
5. **Junior/Bright Login** - Age-appropriate authentication

### Junior Explorer
- **Dashboard** - Activity grid, progress, streak
- **Activity Detail** - (Coming soon)
- **Activity Player** - (Coming soon)
- **Games** - (Coming soon)
- **Stories** - (Coming soon)
- **Rewards** - (Coming soon)

### Bright Minds
- **Dashboard** - (Coming soon)
- **Profile** - (Coming soon)
- **Forum** - (Coming soon)
- **Mood Check** - (Coming soon)

### Parent Dashboard
- **Overview** - (Coming soon)
- **Children Management** - (Coming soon)
- **Analytics** - (Coming soon)
- **Settings** - (Coming soon)

## 🔒 Security

### Authentication Security
- **Password Hashing:** SHA-256 for picture sequences
- **PIN Security:** Strong validation, no weak patterns
- **Lockout Policy:** 
  - Junior: 3 attempts → 15-minute lockout
  - Bright: 5 attempts → 30-minute lockout
- **Biometric:** Optional Face ID/Touch ID for parents

### Data Protection
- Encrypted local storage for sensitive data
- Secure Firebase authentication tokens
- Parent-controlled content filtering
- Child data isolation

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Coverage
- Unit tests: Services and providers
- Widget tests: UI components
- Integration tests: Complete user flows

## 📊 Project Status

### ✅ Completed (Phase 1-3 Partial)
- Navigation system with GoRouter
- Provider-based state management
- Firebase integration (Auth, Firestore, Storage, Analytics)
- PYP Curriculum service
- Picture password authentication (Junior)
- Picture+PIN authentication (Bright)
- Parent email/password authentication
- Junior Explorer dashboard
- Custom widgets (activity cards, progress ring, etc.)

### ⏳ In Progress
- Bright Minds dashboard
- Activity learning flow
- Parent dashboard features

### 📋 Planned
- Offline-first functionality
- Camera integration
- Push notifications
- Comprehensive testing
- Performance optimization
- Accessibility features

## 📁 Project Structure

```
lib/
├── design_system/          # Colors, themes, tokens
├── models/                 # Data models
├── navigation/             # Routing and guards
├── providers/              # State management
├── services/               # Backend services
├── screens/                # UI screens
├── widgets/                # Reusable widgets
└── main.dart              # App entry point
```

## 🛠️ Development

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable names
- Comment complex logic
- Keep widgets small and focused

### State Management Patterns
```dart
// Read provider (doesn't listen to changes)
final authProvider = context.read<AuthProvider>();

// Watch provider (rebuilds on changes)
final currentUser = context.watch<AuthProvider>().currentUser;

// Select specific value
final isLoading = context.select((AuthProvider p) => p.isLoading);

// Consumer widget
Consumer<AuthProvider>(
  builder: (context, auth, child) {
    return Text(auth.currentUser?.name ?? 'Guest');
  },
)
```

### Adding New Screens
1. Create screen file in appropriate directory
2. Add route in `route_names.dart`
3. Configure route in `app_router.dart`
4. Add navigation guard if needed
5. Implement screen UI
6. Connect to providers for data

## 🐛 Troubleshooting

### Firebase Configuration Issues
```bash
# Reconfigure Firebase
flutterfire configure

# Check Firebase packages
flutter pub get
```

### Build Errors
```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter run
```

### iOS-Specific Issues
```bash
# Update pods
cd ios
pod install
cd ..
```

### Android-Specific Issues
```bash
# Gradle sync
cd android
./gradlew clean
cd ..
```

## 📚 Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)

### Design
- [Material Design 3](https://m3.material.io/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)

### PYP Resources
- PYP Language Scope and Sequence
- IB Primary Years Programme documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

[To be specified]

## 👥 Support

For issues and questions:
- Create an issue in the repository
- Contact the development team

---

**Built with ❤️ using Flutter**

**Version:** 1.0.0+1  
**Last Updated:** October 12, 2025  
**Status:** Active Development (~45% Complete)
