# Wilder Sync Dashboard - Universal Installer/Updater/Uninstaller
# Optimized for Windows Server 2025
# Structure: [ROOT] -> install.ps1, run.ps1, app/ (binaries, src, logs, storage)

param (
    [string]$Version = "latest",
    [switch]$Uninstall,
    [switch]$Force
)

$repo = "FoxWilder/KOReader-Sync-Dashboard"
$installDir = Get-Location
$logDir = "$installDir\app\logs"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory $logDir -Force | Out-Null }
$logFile = "$logDir\install_log.txt"

# --- LOGGING WRAPPER ---
function Write-Log([string]$message, [string]$color = "White") {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "[$timestamp] $message"
    Write-Host $message -ForegroundColor $color
    $fullMessage | Out-File -FilePath $logFile -Append
}

Write-Log "--- Wilder Sync Dashboard Manager ---" "Cyan"
Write-Log "Based on project Sake (Sudashiii/Sake)" "Gray"

# --- UNINSTALL LOGIC ---
if ($Uninstall) {
    if (-not $Force) {
        $confirm = Read-Host "Are you sure you want to uninstall and DELETE ALL DATA? (y/n)"
        if ($confirm -ne "y") { exit }
    }
    
    Write-Log "Stopping processes..." "Yellow"
    Stop-Process -Id (Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue).OwningProcess -Force -ErrorAction SilentlyContinue
    
    Write-Log "Removing application files..."
    Remove-Item -Recurse -Force "$installDir\app" -ErrorAction SilentlyContinue
    Remove-Item -Force "$installDir\install.ps1", "$installDir\run.ps1" -ErrorAction SilentlyContinue
    
    Write-Log "Uninstall complete." "Green"
    exit
}

# --- INSTALL / UPGRADE LOGIC ---

# 1. Detection
if (Test-Path "$installDir\app\package.json") {
    Write-Log "Existing installation detected. mode: UPGRADE" "Yellow"
    $isUpdate = $true
} else {
    Write-Log "No existing installation found. mode: NEW INSTALL" "Green"
    $isUpdate = $false
}

# 2. Fetch Release Info
Write-Log "Fetching version information ($Version) from GitHub..."
try {
    $releaseUrl = "https://api.github.com/repos/$repo/releases"
    if ($Version -ne "latest") {
        $releaseUrl = "https://api.github.com/repos/$repo/releases/tags/$Version"
    }
    $releaseInfo = Invoke-RestMethod -Uri $releaseUrl
    if ($Version -eq "latest") { $releaseInfo = $releaseInfo | Sort-Object published_at -Descending | Select-Object -First 1 }
    
    $asset = $releaseInfo.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
    $assetUrl = $asset.browser_download_url
} catch {
    Write-Log "ERROR: Failed to fetch version info." "Red"
    exit 1
}

# 3. Stop running processes
Write-Log "Ensuring workspace is unlocked..." "Yellow"
Stop-Process -Id (Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue).OwningProcess -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 4. Download
$tempFile = "$env:TEMP\wilder-update.zip"
Write-Log "Downloading version $($releaseInfo.tag_name)..."
Invoke-WebRequest -Uri $assetUrl -OutFile $tempFile

# 5. Backup & Prep
$tempDir = New-Item -ItemType Directory -Path "$env:TEMP\wilder_prep_$([Guid]::NewGuid())"
if ($isUpdate) {
    Write-Log "Staging existing data..."
    if (Test-Path "$installDir\app\storage") { Copy-Item -Recurse "$installDir\app\storage" "$tempDir\storage" }
    if (Test-Path "$installDir\app\logs") { Copy-Item -Recurse "$installDir\app\logs" "$tempDir\logs" }
    # Legacy check
    if (Test-Path "$installDir\wilder.db") { Copy-Item "$installDir\wilder.db" "$tempDir\storage\wilder.db" -ErrorAction SilentlyContinue }
}

# 6. Deploy
Write-Log "Deploying core files..."
# Clean app folder but KEEP root scripts for now
if (Test-Path "$installDir\app") { Remove-Item -Recurse -Force "$installDir\app" }
New-Item -ItemType Directory -Path "$installDir\app" -Force | Out-Null
Expand-Archive -Path $tempFile -DestinationPath "$installDir\app" -Force
Remove-Item $tempFile

# Restore data
if (Test-Path "$tempDir\storage") { Move-Item "$tempDir\storage" "$installDir\app\storage" -Force }
if (Test-Path "$tempDir\logs") { Move-Item "$tempDir\logs" "$installDir\app\logs" -Force }
Remove-Item -Recurse $tempDir

# 7. Setup
Write-Log "Running infrastructure setup..."
Set-Location "$installDir\app"
if (Test-Path "setup.ps1") { powershell -ExecutionPolicy Bypass -File "setup.ps1" }

# 8. Finalize Root
Write-Log "Finalizing root pointers..."
Set-Location $installDir

# Move run.ps1 and install.ps1 to root if they were inside the app folder
if (Test-Path "app\run.ps1") { Move-Item "app\run.ps1" "run.ps1" -Force }
if (Test-Path "app\install.ps1") { Move-Item "app\install.ps1" "install.ps1" -Force }

# Ensure run.ps1 exists
if (!(Test-Path "run.ps1")) {
    $runContent = @"
# Wilder Sync Dashboard Launcher
Set-Location "`$PSScriptRoot\app"
node_modules\.bin\tsx server.ts --prod
"@
    Set-Content -Path "run.ps1" -Value $runContent
}

Write-Log "--- SUCCESS: Wilder Sync v$($releaseInfo.tag_name) is ready ---" "Green"
Write-Log "Launch 'run.ps1' to start the service." "Cyan"

# Automatically start it
./run.ps1
