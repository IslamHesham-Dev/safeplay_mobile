# Start SafePlay Web App
# This script builds and starts the Flutter web app

Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Starting web server on http://localhost:8080" -ForegroundColor Green

# Kill any existing server on port 8080
$existing = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Process -Id $existing.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# Start the server
Set-Location build\web
Start-Process python -ArgumentList "-m","http.server","8080" -WindowStyle Hidden

# Wait a moment for server to start
Start-Sleep -Seconds 2

# Open browser
Start-Process "http://localhost:8080"

Write-Host "Website started! Open http://localhost:8080 in your browser" -ForegroundColor Green
Write-Host "Press Ctrl+C in this window to stop the server" -ForegroundColor Yellow

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }
}


