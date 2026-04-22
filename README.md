# 📚 Wilder Sync Dashboard
*(Forked from [Sudashiii/Sake](https://github.com/Sudashiii/Sake))*

A polished, **Docker-free** reading stack optimized for Windows Server 2025. This project provides a clean web library, KOReader progress syncing, and book management without the complexity of Docker.

## 🚀 One-Line Installation

**IMPORTANT**: Open PowerShell and `cd` into the folder where you want the installation files to be placed (e.g. `C:\Wilder`). Then run:

```powershell
# Standard Install / Upgrade (Latest Release)
iwr -useb https://raw.githubusercontent.com/FoxWilder/KOReader-Sync-Dashboard/main/install.ps1 | iex

# Install Significant Version (Rollback/Forward)
$v = "v1.0.0"; iwr -useb https://raw.githubusercontent.com/FoxWilder/KOReader-Sync-Dashboard/main/install.ps1 | iex -Arguments "-Version $v"

# Uninstall and Cleanup (Deletes files and database)
iwr -useb https://raw.githubusercontent.com/FoxWilder/KOReader-Sync-Dashboard/main/install.ps1 | iex -Arguments "-Uninstall"
```

*The setup automatically handles data migration and backups during upgrades, and allows complete cleanup via the `-Uninstall` flag.*

## ✨ Features

- **Docker-Free**: Runs natively using Node.js and Python.
- **SQLite Database**: Replaces PostgreSQL for zero-config local storage.
- **Local Storage**: Replaces MinIO/S3 with standard filesystem storage.
- **Automated Workflow**: 
  - **Releases**: Every tag upload triggers a new GitHub Release with a bundled ZIP.
  - **Preview**: A web landing page is automatically deployed to GitHub Pages.
- **Windows Server Optimized**: Tailored for the Windows Server 2025 environment.

## 🛠️ Manual Instructions

If you prefer manual setup, follow these steps:

1. **Clone the repo**:
   ```bash
   git clone https://github.com/FoxWilder/KOReader-Sync-Dashboard.git
   cd KOReader-Sync-Dashboard
   ```
2. **Run Setup**:
   ```powershell
   ./setup.ps1
   ```
3. **Start the App**:
   ```bash
   npm run dev
   ```

## 📊 Logging & Troubleshooting

All activities are logged to the local directory for easy auditing and troubleshooting:

- **`install_log.txt`**: Verbose output from the PowerShell installer/manager.
- **`service_log.txt`**: General web server requests, authorization events, and library access logs.
- **`sync_log.txt`**: Detailed logs of every KOReader progress sync event (handshakes, pushes, and pulls).

## 🤖 Automation

This project uses **GitHub Actions** to automate its lifecycle:
- **Build & Package**: On every push to `main`, the app is built and packaged.
- **GitHub Pages**: The project info page is hosted at [foxwilder.github.io/KOReader-Sync-Dashboard](https://foxwilder.github.io/KOReader-Sync-Dashboard).
- **Auto-Releases**: Tagged versions (e.g., `v1.0.0`) automatically create a GitHub Release with assets.

## 📄 License
This project inherits the license of the original [Sake](https://github.com/Sudashiii/Sake) project.
