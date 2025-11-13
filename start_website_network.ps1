# Start SafePlay Web App - Network Accessible
# This allows access from phones/other devices on the same network

Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Find the main network IP address
$networkIP = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.254.*" -and 
        $_.IPAddress -notlike "192.168.56.*" -and
        $_.IPAddress -notlike "192.168.137.*"
    } | 
    Where-Object {$_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual"} |
    Select-Object -First 1 -ExpandProperty IPAddress

if (-not $networkIP) {
    $networkIP = "192.168.1.100"  # Fallback
    Write-Host "Could not detect IP, using fallback: $networkIP" -ForegroundColor Yellow
} else {
    Write-Host "Detected network IP: $networkIP" -ForegroundColor Green
}

$port = 8080

# Kill any existing server on port 8080
$existing = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Process -Id $existing.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "Starting web server..." -ForegroundColor Cyan
Write-Host "Server will be accessible from:" -ForegroundColor Green
Write-Host "  - This computer: http://localhost:$port" -ForegroundColor White
Write-Host "  - Your phone:    http://$networkIP`:$port" -ForegroundColor White
Write-Host ""

# Start Python server bound to all interfaces (0.0.0.0)
Set-Location build\web

# Check if Python is available
$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
    # Start server bound to all interfaces
    Start-Process python -ArgumentList "-m","http.server","$port","--bind","0.0.0.0" -WindowStyle Hidden
    
    Write-Host "Server started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To access from your phone:" -ForegroundColor Yellow
    Write-Host "1. Make sure your phone is on the same Wi-Fi network" -ForegroundColor White
    Write-Host "2. Open a browser on your phone" -ForegroundColor White
    Write-Host "3. Go to: http://$networkIP`:$port" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    
    # Open local browser too
    Start-Sleep -Seconds 1
    Start-Process "http://localhost:$port"
    
    # Keep script running
    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | ForEach-Object {
            Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
        }
    }
} else {
    Write-Host "Error: Python not found. Please install Python to run the web server." -ForegroundColor Red
    Write-Host "Alternatively, use: flutter run -d web-server --web-port=$port --web-hostname=0.0.0.0" -ForegroundColor Yellow
}



