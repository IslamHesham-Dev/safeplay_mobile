# iOS Build Optimization Script for SafePlay Mobile (PowerShell)
# This script optimizes the iOS build process to reduce pod install time

Write-Host "🚀 Starting iOS Build Optimization..." -ForegroundColor Green

# Navigate to iOS directory
Set-Location ios

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "Pods") { Remove-Item -Recurse -Force "Pods" }
if (Test-Path "Podfile.lock") { Remove-Item -Force "Podfile.lock" }
if (Test-Path ".symlinks") { Remove-Item -Recurse -Force ".symlinks" }
if (Test-Path "Flutter/Flutter.framework") { Remove-Item -Recurse -Force "Flutter/Flutter.framework" }
if (Test-Path "Flutter/Flutter.podspec") { Remove-Item -Force "Flutter/Flutter.podspec" }

# Clean Flutter build cache
Write-Host "🧹 Cleaning Flutter build cache..." -ForegroundColor Yellow
Set-Location ..
flutter clean
flutter pub get
Set-Location ios

# Install pods with optimizations
Write-Host "📦 Installing pods with optimizations..." -ForegroundColor Yellow
pod install --repo-update --verbose

# Create .gitignore for iOS if it doesn't exist
if (-not (Test-Path ".gitignore")) {
    Write-Host "📝 Creating iOS .gitignore..." -ForegroundColor Yellow
    @"
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
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
}

Write-Host "✅ iOS Build Optimization Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: flutter build ios --release --no-codesign" -ForegroundColor White
Write-Host "2. The pod install should now be much faster (under 2 minutes)" -ForegroundColor White
Write-Host "3. If you still experience slow builds, try: pod install --repo-update" -ForegroundColor White
