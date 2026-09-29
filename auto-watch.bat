@echo off
title Auto Git Sync Watcher - Alien Software Development
setlocal

echo.
echo ==========================================================
echo    Launching Real-Time GitHub Auto-Upload Watcher...
echo ==========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Sync-Git.ps1" -Watch

pause
