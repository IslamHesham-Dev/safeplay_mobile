# Deploy SafePlay Web App to Firebase Hosting
# This script builds and deploys your Flutter web app to Firebase

Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Deploying to Firebase Hosting..." -ForegroundColor Cyan
firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Deployment successful!" -ForegroundColor Green
    Write-Host "Your website is live at: https://safeplay-portal.web.app" -ForegroundColor Cyan
} else {
    Write-Host "Deployment failed!" -ForegroundColor Red
}



