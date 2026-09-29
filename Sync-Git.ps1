<#
.SYNOPSIS
    Automated Git Sync & Auto-Upload Engine for Tokyo Night PowerShell Theme.
.DESCRIPTION
    1. Re-encodes standalone .bat files if Apply-Theme.ps1 changed
    2. Mirrors files to Desktop folder
    3. Auto-stages, commits, and pushes all changes to GitHub
    4. Optional -Watch mode: continuously monitors files and auto-pushes on save!
.PARAMETER Message
    Custom commit message. If omitted, an automatic semantic timestamp message is used.
.PARAMETER Watch
    Runs continuous background filesystem watcher that auto-commits and pushes whenever any file is saved.
.EXAMPLE
    .\Sync-Git.ps1
.EXAMPLE
    .\Sync-Git.ps1 "feat: added new prompt glyphs"
.EXAMPLE
    .\Sync-Git.ps1 -Watch
#>

[CmdletBinding()]
param(
    [string]$Message,
    [switch]$Watch
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }
Set-Location $scriptDir

function Update-StandaloneBatches {
    $ps1Path = Join-Path $scriptDir "Apply-Theme.ps1"
    if (Test-Path $ps1Path) {
        $code = [System.IO.File]::ReadAllText($ps1Path, [System.Text.Encoding]::UTF8)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($code)
        $base64 = [Convert]::ToBase64String($bytes)

        $batContent = @"
@echo off
title Applying PowerShell Terminal Theme...
setlocal enabledelayedexpansion

echo.
echo ==========================================================
echo        Applying Custom PowerShell Terminal Theme...
echo ==========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "`$script = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$base64')); Invoke-Expression `$script"

echo.
pause
"@
        [System.IO.File]::WriteAllText((Join-Path $scriptDir "Apply-Theme-SingleFile.bat"), $batContent, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText((Join-Path $scriptDir "Apply-PowerShell-Theme.bat"), $batContent, [System.Text.Encoding]::UTF8)
    }

    # Mirror to Desktop
    $desktopPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
    $desktopDir = Join-Path $desktopPath "PowerShell-Theme-Setup"
    if (Test-Path $desktopDir) {
        Copy-Item -Path "$scriptDir\*" -Destination "$desktopDir\" -Recurse -Force -Exclude ".git"
    }
}

function Push-ToGit([string]$commitMsg) {
    Set-Location $scriptDir

    Update-StandaloneBatches

    $status = git status --porcelain
    if (-not $status) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] Everything is up-to-date. No changes to push." -ForegroundColor DarkGray
        return
    }

    Write-Host ""
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] Changes detected! Syncing with GitHub..." -ForegroundColor Cyan

    git add .

    if (-not $commitMsg) {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $commitMsg = "update: auto-sync updates ($timestamp)"
    }

    git commit -m $commitMsg
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Nothing committed or commit error."
        return
    }

    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] Pushing to origin main..." -ForegroundColor Yellow
    git push origin main

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))]  Successfully pushed to GitHub! (https://github.com/alien-software-development/powershell-tokyo-night-theme)" -ForegroundColor Green
    } else {
        Write-Error "Git push failed. Please check network or remote configuration."
    }
}

if (-not $Watch) {
    Push-ToGit -commitMsg $Message
    return
}

# -------------------------------------------------------------------------
# Watcher Mode
# -------------------------------------------------------------------------
Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    AUTOMATIC GITHUB SYNC ENGINE (WATCHER ACTIVE)         " -ForegroundColor Yellow
Write-Host "    Monitoring: $scriptDir" -ForegroundColor DarkCyan
Write-Host "    Any saved change will automatically push to GitHub.   " -ForegroundColor Green
Write-Host "    Press Ctrl+C at any time to stop.                     " -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Run initial check
Push-ToGit -commitMsg "chore: watcher initial sync"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $scriptDir
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::LastWrite

$lastAction = [DateTime]::MinValue

while ($true) {
    $change = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 1000)
    if ($change.TimedOut) { continue }

    # Ignore .git changes and temporary files
    if ($change.Name -like "*.git*" -or $change.Name -like "*.tmp" -or $change.Name -like "*SingleFile.bat") {
        continue
    }

    # Debounce (wait 2 seconds to avoid rapid duplicate triggers while editing)
    $now = Get-Date
    if (($now - $lastAction).TotalSeconds -lt 2) {
        continue
    }
    $lastAction = $now

    Write-Host "[$($now.ToString('HH:mm:ss'))] File change detected: $($change.Name)" -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Push-ToGit -commitMsg "update: auto-sync $($change.Name) ($($now.ToString('yyyy-MM-dd HH:mm:ss')))"
}
