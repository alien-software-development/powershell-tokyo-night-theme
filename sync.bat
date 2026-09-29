@echo off
title Auto Git Push - Alien Software Development
setlocal

echo.
echo ==========================================================
echo        Uploading all updates to GitHub repository...
echo ==========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Sync-Git.ps1" %*

echo.
pause
