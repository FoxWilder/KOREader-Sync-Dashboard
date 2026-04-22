# Sake Fork Script
# This script helps you push your modified local clone to your own GitHub repository.

$remoteUrl = Read-Host "Enter your new GitHub repository URL (e.g., https://github.com/your-username/Sake.git)"

if (-not $remoteUrl) {
    Write-Error "Repository URL is required."
    exit 1
}

Write-Host "Updating git remote..." -ForegroundColor Cyan
git remote set-url origin $remoteUrl

Write-Host "Adding setup scripts..."
git add setup.ps1 migrate.py check_environment.py README_MIGRATION.md

Write-Host "Committing changes..."
git commit -m "Migration: Setup for non-docker environment with PowerShell"

Write-Host "Pushing to your new repository..." -ForegroundColor Cyan
git push -u origin master # Or 'main' depending on the repo

Write-Host "--- Operation Complete ---" -ForegroundColor Green
Write-Host "Your files should now be in your own GitHub repository."
