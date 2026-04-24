# Wilder Sync Dashboard - Manual Start Script
# This script manually starts the dashboard service if it's not running.

$installDir = Get-Location
Write-Host "--- Wilder Sync Launcher ---" -ForegroundColor Cyan
Write-Host "Location: $installDir"

# Check for Node.js
try {
    node -v | Out-Null
} catch {
    Write-Error "Node.js is not installed or not in PATH."
    exit 1
}

# Check if port 3000 is already in use
$portProcess = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if ($portProcess) {
    Write-Host "Service is already active on port 3000 (PID: $($portProcess.OwningProcess))." -ForegroundColor Yellow
    Write-Host "Open http://localhost:3000 in your browser."
    exit 0
}

Write-Host "Initializing service..." -ForegroundColor Green

# Use tsx to run the server directly (assuming dependencies are installed)
# In production, this would ideally run the built dist/server.js if we moved to a pure JS start
# But for this rolling release model, tsx on server.ts is fine.

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"node_modules\.bin\tsx server.ts --prod`"" -WindowStyle Normal

Write-Host "Service started in a new background window." -ForegroundColor Green
Write-Host "Access the dashboard at: http://localhost:3000"
Start-Sleep -Seconds 2
