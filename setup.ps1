# Sake Non-Docker Setup Script
# This script sets up the Sake reading stack without Docker.

Write-Host "--- Sake Setup Starting ---" -ForegroundColor Cyan

# 1. Prerequisite Checks
Write-Host "Checking prerequisites..."
$node = Get-Command node -ErrorAction SilentlyContinue
$npm = Get-Command npm -ErrorAction SilentlyContinue
$python = Get-Command python -ErrorAction SilentlyContinue

if (-not $node) { Write-Error "Node.js not found. Please install it."; exit 1 }
if (-not $npm) { Write-Error "NPM not found."; exit 1 }
if (-not $python) { Write-Host "Python not found. Trying 'python3'..."; $python = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $python) { Write-Error "Python not found. Please install Python 3."; exit 1 }

Write-Host "Found Node $($node.Version) and Python."

# 2. Migration and Environment Check
Write-Host "Running environment check and migration logic..."
python check_environment.py
if ($LASTEXITCODE -ne 0) { Write-Error "Environment check failed."; exit 1 }

python migrate.py
if ($LASTEXITCODE -ne 0) { Write-Error "Migration failed."; exit 1 }

# 3. Install Dependencies
Write-Host "Installing Node.js dependencies..."
npm install
if ($LASTEXITCODE -ne 0) { Write-Error "NPM install failed."; exit 1 }

# 4. Database Setup (Drizzle)
Write-Host "Initializing database..."
npm run db:push -ErrorAction SilentlyContinue # Try to push schema
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Note: Database push failed. You might need to manually run 'npx drizzle-kit push:sqlite' if current scripts are docker-bound." -ForegroundColor Yellow
}

# 5. Done
Write-Host "--- Setup Complete ---" -ForegroundColor Green
Write-Host "To start the application, run: npm run dev"
Write-Host "Your library will be available at http://localhost:3000 (default)"
