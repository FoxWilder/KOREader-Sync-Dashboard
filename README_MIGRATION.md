# Sake Non-Docker Setup Guide

This project provides a PowerShell-based setup to run [Sudashiii/Sake](https://github.com/Sudashiii/Sake) without Docker. It targets environments (like Windows Servers) where Node.js and Python are available but Docker is not.

## How to use this to create your own Fork

Since I am an AI, I cannot perform the "Fork" action directly on GitHub for you. Instead, follow these steps to create your own modified version:

1. **Create a new repository** on your GitHub account (e.g., `your-username/Sake`).
2. **Clone the original repository** locally:
   ```bash
   git clone https://github.com/Sudashiii/Sake.git
   cd Sake
   ```
3. **Add the scripts provided here** (`setup.ps1` and `migrate.py`) to the root of your clone.
4. **Push to your new repository**:
   ```bash
   git remote set-url origin https://github.com/your-username/Sake.git
   git push -u origin master
   ```

## The Setup Script (`setup.ps1`)

The provided `setup.ps1` does the following:
- Checks for Node.js, NPM, and Python.
- Installs dependencies using `npm install`.
- Configures a local SQLite database (via Drizzle) to replace the Docker-based Postgres.
- Configures local file storage to replace Docker-based MinIO.
- Initializes the database schema.
- Starts the development server.

## Configuration Changes
The script automatically updates your `.env` file to use:
- `DATABASE_URL=file:./sake.db`
- Local storage paths instead of S3 buckets.
