# How to Start SafePlay Web App

## Quick Start (Recommended)

Simply run the PowerShell script:
```powershell
.\start_website.ps1
```

This will:
1. Build the Flutter web app
2. Start a web server on port 8080
3. Open your browser automatically

## Manual Method

### Step 1: Build the web app
```powershell
flutter build web
```

### Step 2: Start the web server
```powershell
cd build\web
python -m http.server 8080
```

### Step 3: Open your browser
Navigate to: **http://localhost:8080**

## Alternative: Use Flutter's built-in server

```powershell
flutter run -d web-server --web-port=8080
```

Then manually open: **http://localhost:8080**

## Notes

- The web server runs on **port 8080** by default
- To stop the server, press `Ctrl+C` in the terminal
- If port 8080 is busy, use a different port (e.g., 8081, 8082)
- Make sure you have Python installed (comes with most systems)




