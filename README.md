# Wilder Sync Dashboard v1.1.0 (Stable)
*(Forked from [Sudashiii/Sake](https://github.com/Sudashiii/Sake))*

![Wilder Sync](https://raw.githubusercontent.com/FoxWilder/KOReader-Sync-Dashboard/main/preview.png)

## Overview
**Wilder Sync** is a high-performance, technically refined intelligence repository and synchronization bridge for KOReader. It provides a centralized dashboard to manage your neural library, track reading telemetry, and monitor ecosystem updates through a unified interface. Specifically optimized for **Native Windows Server 2025** execution without Docker, WSL, or Containers.

## Core Capabilities

### 📚 Neural Library Management (Neural Base)
*   **Deep Indexing**: Automatic, recursive scanning of local repositories (EPUB, PDF, MOBI, AZW3).
*   **Metadata Extraction**: High-fidelity extraction of titles, authors, descriptions, and cover art.
*   **Virtual Grid Interface**: Optimized high-density book grid with automatic scaling and minimum 4-column desktop layout.
*   **Format Classification**: Granular tracking of document storage density and format distribution.

### 🔄 Synchronous Intelligence Protocol (KOReader Sync)
*   **Bi-Directional Handshake**: Fully compatible with the KOReader Sync plugin protocol.
*   **Telemetry Sync**: Real-time progress tracking, including percentage and XPointer positions.
*   **Shortened Endpoints**: Simplified routing system (`/sync`) for easier device configuration.
*   **Conflict Resolution**: Automated state merging to maintain sync integrity across multiple devices.

### 📊 Forensic Stat Widgets
*   **Compositional Analysis**: Breakdown of library size, unique entities (authors), and sectors (categories).
*   **Operational Telemetry**: Detailed insights into system uptime, active reading sessions, and archival vault status.
*   **Interactive Node Details**: Clickable widgets for deep-dives into system metrics and logic.

### 📰 Intelligence Feed
*   **Ecosystem Monitoring**: Real-time tracking of GitHub releases for connected projects (KOReader, etc.).
*   **Customizable Nodes**: Add or remove repositories to monitor within the dashboard.

### ⚡ System Integrity & Maintenance
*   **Recursive Sanitization**: Clean internal database fragments and orphaned records.
*   **Automated Core Upgrades**: One-click system-wide updates pulling directly from the main branch.
*   **Manual Override**: `run.ps1` for rapid recovery and manual service initiation.

## Technical Structure
*   **Frontend**: React 18, Vite, Tailwind CSS, Motion.
*   **Backend**: Node.js (Express) with `better-sqlite3`.
*   **Database**: SQLite (`wilder.db`).
*   **Storage**: Standard local filesystem replaces S3/MinIO.
*   **Deployment**: Automated PowerShell-based rolling release cycle.

## Installation / Upgrade
Execute the following in a PowerShell terminal:
```powershell
iwr -useb https://raw.githubusercontent.com/FoxWilder/KOReader-Sync-Dashboard/main/install.ps1 | iex
```

## Quick Start
1.  Launch `run.ps1` to start the service.
2.  Navigate to `http://localhost:3000`.
3.  Assign your **Data Repository** path in Settings.
4.  Configure your KOReader device with the **Master Handshake URL** found in settings.

## 📊 Logging & Troubleshooting
*   **`install_log.txt`**: Verbose output from the PowerShell installer/manager.
*   **`service_log.txt`**: General web server requests and library access logs.
*   **`sync_log.txt`**: Detailed logs of every KOReader progress sync event.

---
*Maintained by FoxWilder. Stable Release 1.1.0.*
