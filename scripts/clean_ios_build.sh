#!/bin/bash

# Clean iOS Build Script
# Use this if you encounter build issues after Podfile changes

echo "🧹 Cleaning iOS build artifacts..."

# Navigate to iOS directory
cd ios

# Clean CocoaPods
echo "Cleaning CocoaPods..."
rm -rf Pods/
rm -rf Podfile.lock
rm -rf .symlinks/

# Clean Xcode build artifacts
echo "Cleaning Xcode build artifacts..."
rm -rf build/
rm -rf DerivedData/
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Clean Flutter build cache
echo "Cleaning Flutter build cache..."
cd ..
flutter clean
flutter pub get

# Reinstall pods
echo "Reinstalling pods..."
cd ios
pod install

echo "✅ iOS build cleanup complete!"
echo "You can now run: flutter build ios --release --no-codesign"
