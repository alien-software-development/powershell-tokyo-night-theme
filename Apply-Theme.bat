@echo off
title Applying PowerShell Terminal Theme...
setlocal enabledelayedexpansion

echo.
echo ==========================================================
echo        Applying Custom PowerShell Terminal Theme...
echo ==========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Apply-Theme.ps1"

echo.
echo Press any key to close this window...
pause >nul
