# Wilder Sync Dashboard - Universal Installer/Updater/Uninstaller
# Optimized for Windows Server 2025
# Structure: [ROOT] -> install.ps1, run.ps1, app/ (binaries, src, logs, storage)

param (
    [string]$Version = "latest",
    [switch]$Uninstall,
    [switch]$Force
)

$repo = "FoxWilder/KOReader-Sync-Dashboard"
$installDir = $PSScriptRoot
if (!$installDir) { $installDir = Get-Location }

$appDir = Join-Path $installDir "app"
$logDir = Join-Path $appDir "logs"

# CRITICAL: Create log directory BEFORE anything else
if (!(Test-Path $logDir)) { New-Item -ItemType Directory $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "install_log.txt"

# --- LOGGING WRAPPER ---
function Write-Log([string]$message, [string]$color = "White") {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "[$timestamp] $message"
    Write-Host $message -ForegroundColor $color
    
    # Final safety check before write
    $targetDir = Split-Path $logFile -Parent
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory $targetDir -Force | Out-Null }
    $fullMessage | Out-File -FilePath $logFile -Append -Encoding utf8
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
    $connections = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            if ($conn.OwningProcess) {
                Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
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
    # Try releases first
    $releaseUrl = "https://api.github.com/repos/$repo/releases/latest"
    if ($Version -ne "latest") {
        $releaseUrl = "https://api.github.com/repos/$repo/releases/tags/$Version"
    }
    
    $releaseInfo = $null
    try {
        $releaseInfo = Invoke-RestMethod -Uri $releaseUrl
    } catch {
        # Fallback to tags if releases 404
        Write-Log "Falling back to tags query..." "Gray"
        $tags = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/tags"
        if ($tags) {
            $tag = $tags[0]
            $releaseInfo = @{
                tag_name = $tag.name
                assets = @(@{
                    name = "source.zip"
                    browser_download_url = $tag.zipball_url
                })
            }
        }
    }

    if (!$releaseInfo) { throw "No release or tag found." }
    
    $asset = $releaseInfo.assets | Where-Object { $_.name -like "*.zip" -or $_.name -like "source.zip" } | Select-Object -First 1
    $assetUrl = $asset.browser_download_url
} catch {
    Write-Log "ERROR: Failed to fetch version info." "Red"
    exit 1
}

# 3. Stop running processes
Write-Log "Ensuring workspace is unlocked..." "Yellow"
$connections = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if ($connections) {
    foreach ($conn in $connections) {
        if ($conn.OwningProcess) {
            $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Log "Stopping process ID $($conn.OwningProcess) ($($proc.Name))..." "Gray"
                $proc | Stop-Process -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
Start-Sleep -Seconds 2

# 4. Download
$tempFile = Join-Path $env:TEMP "wilder-update.zip"
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
Write-Log "Deploying core files..." "Yellow"
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $appDir -Force | Out-Null

if (!(Test-Path $logDir)) { New-Item -ItemType Directory $logDir -Force | Out-Null }

Write-Log "Extracting archive..." "Gray"
Expand-Archive -Path $tempFile -DestinationPath $appDir -Force
Remove-Item $tempFile

# Handle GitHub's nested folder structure (repo-name-hash)
$extractedItems = Get-ChildItem -Path $appDir
if ($extractedItems.Count -eq 1 -and $extractedItems[0].PSIsContainer) {
    Write-Log "Flattening nested directory structure..." "Gray"
    $subDir = $extractedItems[0].FullName
    Get-ChildItem -Path $subDir | Move-Item -Destination $appDir -Force
    Remove-Item $subDir -Recurse -Force
}

# 7. Setup
Write-Log "Running infrastructure setup..."
Set-Location $appDir

if (!(Test-Path "package.json")) {
    Write-Log "CRITICAL ERROR: package.json not found after extraction." "Red"
    exit 1
}

# Ensure dependencies are installed
if (!(Test-Path "node_modules")) {
    Write-Log "Installing Node.js dependencies (this may take a minute)..." "Yellow"
    npm install --omit=dev
}

if (Test-Path "setup.ps1") { powershell -ExecutionPolicy Bypass -File "setup.ps1" }

# 8. Finalize Root
Write-Log "Finalizing root pointers..."
Set-Location $installDir

# Move run.ps1 and install.ps1 to root if they were inside the app folder
if (Test-Path "app\run.ps1") { Move-Item "app\run.ps1" "run.ps1" -Force }
if (Test-Path "app\install.ps1") { Move-Item "app\install.ps1" "install.ps1" -Force }

# Generate a robust run.ps1
$runContent = @"
# Wilder Sync Dashboard Launcher
Write-Host "--- Wilder Sync Launcher ---" -ForegroundColor Cyan
Set-Location "`$PSScriptRoot\app"

if (!(Test-Path "node_modules")) {
    Write-Host "Dependencies missing. Orchestrating installation..." -ForegroundColor Yellow
    npm install --omit=dev
}

# Execute server using path-safe iteration
Write-Host "Synchronizing with Neural Engine..." -ForegroundColor Gray
& "node_modules/.bin/tsx" server.ts --prod
"@
Set-Content -Path "run.ps1" -Value $runContent

Write-Log "--- SUCCESS: Wilder Sync v$($releaseInfo.tag_name) is ready ---" "Green"
Write-Log "Launch 'run.ps1' to start the service." "Cyan"

# Automatically start it
./run.ps1
