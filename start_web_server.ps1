# Simple PowerShell script to serve the Flutter web app
# Usage: .\start_web_server.ps1

$port = 8080
$webPath = Join-Path $PSScriptRoot "build\web"

if (-not (Test-Path $webPath)) {
    Write-Host "Error: Web build not found. Please run 'flutter build web' first." -ForegroundColor Red
    exit 1
}

Write-Host "Starting web server on http://localhost:$port" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Try to use Python's HTTP server if available
$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
    Write-Host "Using Python HTTP server..." -ForegroundColor Cyan
    Set-Location $webPath
    python -m http.server $port
} else {
    # Fallback: Use PowerShell's built-in web server capabilities
    Write-Host "Python not found. Using PowerShell web server..." -ForegroundColor Cyan
    Write-Host "Opening browser..." -ForegroundColor Cyan
    
    # Create a simple HTTP listener
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
    
    Write-Host "Server started at http://localhost:$port" -ForegroundColor Green
    Write-Host "Open http://localhost:$port in your browser" -ForegroundColor Yellow
    
    # Open browser
    Start-Process "http://localhost:$port"
    
    try {
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $localPath = $request.Url.LocalPath
            if ($localPath -eq "/") {
                $localPath = "/index.html"
            }
            
            $filePath = Join-Path $webPath ($localPath.TrimStart('/'))
            
            if (Test-Path $filePath) {
                $content = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $content.Length
                
                # Set content type
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentTypes = @{
                    ".html" = "text/html"
                    ".js" = "application/javascript"
                    ".css" = "text/css"
                    ".json" = "application/json"
                    ".png" = "image/png"
                    ".jpg" = "image/jpeg"
                    ".svg" = "image/svg+xml"
                }
                $response.ContentType = if ($contentTypes.ContainsKey($ext)) { $contentTypes[$ext] } else { "application/octet-stream" }
                
                $response.OutputStream.Write($content, 0, $content.Length)
            } else {
                $response.StatusCode = 404
                $response.Close()
            }
        }
    } finally {
        $listener.Stop()
    }
}



