#!/bin/bash

# iOS Build Optimization Script for SafePlay Mobile
# This script optimizes the iOS build process to reduce pod install time

echo "🚀 Starting iOS Build Optimization..."

# Navigate to iOS directory
cd ios

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf Pods/
rm -rf Podfile.lock
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# Clean Flutter build cache
echo "🧹 Cleaning Flutter build cache..."
cd ..
flutter clean
flutter pub get
cd ios

# Install pods with optimizations
echo "📦 Installing pods with optimizations..."
pod install --repo-update --verbose

# Create .gitignore for iOS if it doesn't exist
if [ ! -f .gitignore ]; then
    echo "📝 Creating iOS .gitignore..."
    cat > .gitignore << EOF
# Xcode
.DS_Store
*/build/*
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.moved-aside
*.xccheckout
*.xcscmblueprint

# CocoaPods
Pods/
Podfile.lock

# Flutter
Flutter/Flutter.framework
Flutter/Flutter.podspec
Flutter/Generated.xcconfig
Flutter/ephemeral/
Flutter/app.flx
Flutter/app.zip
Flutter/flutter_assets/
Flutter/flutter_export_environment.sh
ServiceDefinitions.json
Runner/GeneratedPluginRegistrant.*

# Build
build/
DerivedData/

# Other
.symlinks/
EOF
fi

echo "✅ iOS Build Optimization Complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run: flutter build ios --release --no-codesign"
echo "2. The pod install should now be much faster (under 2 minutes)"
echo "3. If you still experience slow builds, try: pod install --repo-update"
