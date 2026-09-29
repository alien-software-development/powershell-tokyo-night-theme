<#
.SYNOPSIS
    Installs, configures, and manages the Tokyo Night Dark Theme for PowerShell.
.DESCRIPTION
    Applies Tokyo Night Dark Theme to:
    1. PowerShell 7+ and Windows PowerShell 5.1 profiles (PSReadLine, $Host, $PSStyle, Custom Prompt)
    2. Windows Console Registry (HKCU:\Console) for native console windows
    3. Windows Terminal settings.json (if installed)
.PARAMETER Uninstall
    Restores previous profile backups and removes console registry overrides.
.PARAMETER NoBackup
    Skips creating backup copies of existing PowerShell profile files.
.PARAMETER Quiet
    Suppresses terminal banner and interactive visual swatch preview.
.EXAMPLE
    .\Apply-Theme.ps1
.EXAMPLE
    .\Apply-Theme.ps1 -Uninstall
#>

[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$NoBackup,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
$e = [char]27

function Show-Header {
    if ($Quiet) { return }
    try { Clear-Host } catch {}
    Write-Host ""
    Write-Host "  ┌────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │           🌃 TOKYO NIGHT POWERSHELL THEME ENGINE           │" -ForegroundColor Yellow
    Write-Host "  │       Alien Software Development • Enterprise Automation   │" -ForegroundColor DarkCyan
    Write-Host "  └────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
}

# -------------------------------------------------------------------------
# 1. Profile Script Template
# -------------------------------------------------------------------------
$profileContent = @'
# ==============================================================================
# Tokyo Night Cohesive Dark Theme - Permanent Configuration
# Developed by Alien Software Development (https://aliensoftwaredevelopment.com)
# ==============================================================================

# Ensure UTF-8 Encoding
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

# Force Console Background to Dark (Index 0) and Foreground to Crisp (Index 7)
if ($Host.UI -and $Host.UI.RawUI) {
    try {
        $Host.UI.RawUI.BackgroundColor = 'Black'
        $Host.UI.RawUI.ForegroundColor = 'Gray'
        [Console]::ResetColor()
    } catch {}
}

# ------------------------------------------------------------------------------
# 1. PSReadLine Syntax Highlighting & Predictive IntelliSense
# ------------------------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    $e = [char]27

    # Tokyo Night 24-bit TrueColor Palette:
    # Command: #7aa2f7, Parameter: #bb9af7, Operator: #89ddff, Variable: #ff9e64
    # String: #9ece6a, Number: #e0af68, Type: #2ac3de, Comment: #6e738d
    # Error: #f7768e, Default: #c0caf5, Selection: #33467c / #ffffff
    $desiredColors = @{
        Command                     = "$e[38;2;122;162;247m"
        Parameter                   = "$e[38;2;187;154;247m"
        Operator                    = "$e[38;2;137;221;255m"
        Variable                    = "$e[38;2;255;158;100m"
        String                      = "$e[38;2;158;206;106m"
        Number                      = "$e[38;2;224;175;104m"
        Type                        = "$e[38;2;42;195;222m"
        Comment                     = "$e[38;2;110;115;141m"
        Keyword                     = "$e[38;2;187;154;247m"
        Member                      = "$e[38;2;125;207;255m"
        Emphasis                    = "$e[38;2;255;158;100m"
        Error                       = "$e[38;2;247;118;142m"
        Selection                   = "$e[48;2;51;70;124;38;2;255;255;255m"
        Default                     = "$e[38;2;192;202;245m"
        ContinuationPrompt          = "$e[38;2;110;115;141m"
        InlinePrediction            = "$e[38;2;86;95;137m"
        ListPredictionColor         = "$e[38;2;192;202;245m"
        ListPredictionSelectedColor = "$e[48;2;51;70;124;38;2;255;255;255m"
    }

    $supportedProps = (Get-PSReadLineOption).PSObject.Properties.Name
    $safeColors = @{}
    foreach ($entry in $desiredColors.GetEnumerator()) {
        $candidateName = $entry.Key + "Color"
        if ($supportedProps -contains $candidateName -or $supportedProps -contains $entry.Key) {
            $safeColors[$entry.Key] = $entry.Value
        }
    }

    try {
        Set-PSReadLineOption -Colors $safeColors -ErrorAction SilentlyContinue
    } catch {}

    try {
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key Tab -Function Complete -ErrorAction SilentlyContinue
    } catch {}

    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
    } catch {}
}

# ------------------------------------------------------------------------------
# 2. Host Console Output & Error Theme ($Host.PrivateData)
# ------------------------------------------------------------------------------
if ($Host.PrivateData) {
    try {
        $Host.PrivateData.ErrorForegroundColor    = 'Red'
        $Host.PrivateData.ErrorBackgroundColor    = 'Black'
        $Host.PrivateData.WarningForegroundColor  = 'Yellow'
        $Host.PrivateData.WarningBackgroundColor  = 'Black'
        $Host.PrivateData.DebugForegroundColor    = 'DarkCyan'
        $Host.PrivateData.DebugBackgroundColor    = 'Black'
        $Host.PrivateData.VerboseForegroundColor  = 'DarkGray'
        $Host.PrivateData.VerboseBackgroundColor  = 'Black'
        $Host.PrivateData.ProgressForegroundColor = 'White'
        $Host.PrivateData.ProgressBackgroundColor = 'DarkBlue'
    } catch {}
}

# ------------------------------------------------------------------------------
# 3. PSStyle Formatting (PowerShell 7.2+)
# ------------------------------------------------------------------------------
if (Get-Variable -Name PSStyle -ErrorAction SilentlyContinue) {
    try {
        $e = [char]27
        $PSStyle.Formatting.TableHeader = "$e[38;2;187;154;247;1m"
        $PSStyle.Formatting.FormatAccent = "$e[38;2;125;207;255m"
        $PSStyle.Formatting.Error = "$e[38;2;247;118;142m"
        $PSStyle.Formatting.Warning = "$e[38;2;224;175;104m"
        $PSStyle.Formatting.Verbose = "$e[38;2;110;115;141m"
        $PSStyle.Formatting.Debug = "$e[38;2;42;195;222m"

        $PSStyle.FileInfo.Directory = "$e[38;2;122;162;247;1m"
        $PSStyle.FileInfo.SymbolicLink = "$e[38;2;42;195;222m"
        $PSStyle.FileInfo.Executable = "$e[38;2;158;206;106m"
    } catch {}
}

# ------------------------------------------------------------------------------
# 4. Clean & Professional Dark Prompt
# ------------------------------------------------------------------------------
function prompt {
    $e = [char]27
    $reset = "$e[0m"

    $path = ($pwd.Path).Replace($HOME, "~")
    $pathColor = "$e[38;2;122;162;247m"

    $gitBranch = ""
    try {
        $branch = (git branch --show-current 2>$null)
        if ($branch) {
            $gitColor = "$e[38;2;224;175;104m"
            $gitBranch = " $gitColor($branch)$reset"
        }
    } catch {}

    $statusColor = if ($?) { "$e[38;2;158;206;106m" } else { "$e[38;2;247;118;142m" }
    $symbol = ">"

    "$pathColor$path$reset$gitBranch`n$statusColor$symbol$reset "
}
'@

# -------------------------------------------------------------------------
# Handle Uninstall
# -------------------------------------------------------------------------
if ($Uninstall) {
    Show-Header
    Write-Host "[-] Uninstalling Tokyo Night Theme and restoring settings..." -ForegroundColor Yellow

    $docFolders = @(
        [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments),
        "$HOME\Documents"
    ) | Select-Object -Unique

    foreach ($doc in $docFolders) {
        if (-not $doc) { continue }
        $targets = @(
            (Join-Path $doc "PowerShell\Microsoft.PowerShell_profile.ps1"),
            (Join-Path $doc "WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
        )
        foreach ($file in $targets) {
            if (Test-Path $file) {
                # Look for most recent backup
                $backup = Get-ChildItem -Path (Split-Path $file) -Filter "$(Split-Path $file -Leaf).bak*" -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending | Select-Object -First 1

                if ($backup) {
                    Copy-Item $backup.FullName $file -Force
                    Write-Host "  -> Restored backup: $($backup.Name) -> $($file)" -ForegroundColor Green
                } else {
                    Remove-Item $file -Force -ErrorAction SilentlyContinue
                    Write-Host "  -> Removed profile: $file" -ForegroundColor Gray
                }
            }
        }
    }

    $consoleKeys = @(
        "HKCU:\Console\Windows PowerShell",
        "HKCU:\Console\PowerShell",
        "HKCU:\Console\pwsh",
        "HKCU:\Console\pwsh.exe"
    )
    foreach ($k in $consoleKeys) {
        if (Test-Path $k) {
            Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  -> Removed registry key: $k" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "Theme successfully uninstalled. Restart your terminal." -ForegroundColor Green
    return
}

# -------------------------------------------------------------------------
# Install Process
# -------------------------------------------------------------------------
Show-Header

Write-Host "  [1/3] Configuring PowerShell Profile Environments..." -ForegroundColor Green

$docFolders = @(
    [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments),
    "$HOME\Documents"
) | Select-Object -Unique

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

foreach ($doc in $docFolders) {
    if (-not $doc) { continue }
    $targets = @(
        (Join-Path $doc "PowerShell\Microsoft.PowerShell_profile.ps1"),
        (Join-Path $doc "WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
    )

    foreach ($file in $targets) {
        try {
            $dir = Split-Path $file -Parent
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }

            # Safety backup if existing profile exists and not already Tokyo Night
            if ((Test-Path $file) -and (-not $NoBackup)) {
                $existing = Get-Content $file -Raw -ErrorAction SilentlyContinue
                if ($existing -and ($existing -notmatch "Tokyo Night Cohesive Dark Theme")) {
                    $backupPath = "$file.bak_$timestamp"
                    Copy-Item $file $backupPath -Force
                    Write-Host "    • Backup created: $backupPath" -ForegroundColor DarkGray
                }
            }

            [System.IO.File]::WriteAllText($file, $profileContent, [System.Text.Encoding]::UTF8)
            Write-Host "    ✓ Profile configured: $file" -ForegroundColor Gray
        } catch {
            Write-Warning "Could not write to $($file): $_"
        }
    }
}

# -------------------------------------------------------------------------
# Configure Windows Console Registry
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "  [2/3] Updating Windows Console Color Tables (HKCU:\Console)..." -ForegroundColor Green

$colorTableValues = @{
    ColorTable00 = 1971734   # #16161E (Dark Background)
    ColorTable01 = 10574141  # #3D59A1
    ColorTable02 = 6999710   # #9ECE6A
    ColorTable03 = 14598954  # #2AC3DE
    ColorTable04 = 9336567   # #F7768E
    ColorTable05 = 1971734   # #16161E
    ColorTable06 = 16108224  # #C0CAF5
    ColorTable07 = 16108224  # #C0CAF5 (Default Foreground Text)
    ColorTable08 = 6834241   # #414868
    ColorTable09 = 16228986  # #7AA2F7
    ColorTable10 = 6999710   # #9ECE6A
    ColorTable11 = 16764797  # #7DCFFF
    ColorTable12 = 9665279   # #FF7A93
    ColorTable13 = 16751040  # #C099FF
    ColorTable14 = 6594303   # #FF9E64
    ColorTable15 = 16777215  # #FFFFFF
    ScreenColors = 7         # Color 7 on Color 0
    PopupColors  = 7
    CursorColor  = 16228986  # #7AA2F7
}

$consoleKeys = @(
    "HKCU:\Console",
    "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe",
    "HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe",
    "HKCU:\Console\Windows PowerShell",
    "HKCU:\Console\PowerShell",
    "HKCU:\Console\pwsh",
    "HKCU:\Console\pwsh.exe"
)

foreach ($keyPath in $consoleKeys) {
    try {
        if (-not (Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force | Out-Null
        }
        foreach ($prop in $colorTableValues.Keys) {
            Set-ItemProperty -Path $keyPath -Name $prop -Value $colorTableValues[$prop] -Type DWord -Force | Out-Null
        }
        Write-Host "    ✓ Registry synchronized: $keyPath" -ForegroundColor Gray
    } catch {
        Write-Warning "Could not update $($keyPath): $_"
    }
}

# -------------------------------------------------------------------------
# Configure Windows Terminal (if present)
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "  [3/3] Detecting Windows Terminal Integration..." -ForegroundColor Green

$wtSettingsPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)

$tokyoNightScheme = [ordered]@{
    name                = "Tokyo Night"
    background          = "#16161E"
    foreground          = "#C0CAF5"
    cursorColor         = "#7AA2F7"
    selectionBackground = "#33467C"
    black               = "#16161E"
    blue                = "#3D59A1"
    cyan                = "#2AC3DE"
    green               = "#9ECE6A"
    purple              = "#8E76F7"
    red                 = "#F7768E"
    white               = "#C0CAF5"
    yellow              = "#C0CAF5"
    brightBlack         = "#414868"
    brightBlue          = "#7AA2F7"
    brightCyan          = "#7DCFFF"
    brightGreen         = "#9ECE6A"
    brightPurple        = "#C099FF"
    brightRed           = "#FF7A93"
    brightWhite         = "#FFFFFF"
    brightYellow        = "#FF9E64"
}

$wtUpdated = $false
foreach ($wtPath in $wtSettingsPaths) {
    if (Test-Path $wtPath) {
        try {
            $rawJson = Get-Content -Path $wtPath -Raw -Encoding UTF8
            $settings = $rawJson | ConvertFrom-Json

            if (-not $settings.schemes) {
                $settings | Add-Member -MemberType NoteProperty -Name "schemes" -Value @()
            }

            $filteredSchemes = @($settings.schemes | Where-Object { $_.name -ne "Tokyo Night" })
            $filteredSchemes += $tokyoNightScheme
            $settings.schemes = $filteredSchemes

            if (-not $settings.profiles.defaults) {
                $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value (New-Object PSObject) -ErrorAction SilentlyContinue
            }
            $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value "Tokyo Night" -Force

            $updatedJson = $settings | ConvertTo-Json -Depth 32
            [System.IO.File]::WriteAllText($wtPath, $updatedJson, [System.Text.Encoding]::UTF8)
            Write-Host "    ✓ Windows Terminal theme injected: $wtPath" -ForegroundColor Gray
            $wtUpdated = $true
        } catch {
            Write-Warning "Could not update Windows Terminal settings: $_"
        }
    }
}

if (-not $wtUpdated) {
    Write-Host "    • Windows Terminal not detected (native console configured)." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Visual Tokyo Night Swatch & Syntax Test
# -------------------------------------------------------------------------
if (-not $Quiet) {
    Write-Host ""
    Write-Host "  ────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  🎨 Live Tokyo Night Palette Test Swatch:" -ForegroundColor Yellow
    Write-Host ""
    
    # 24-bit TrueColor swatches
    $colors = @(
        @{ Name = "BgDark "; Code = "48;2;22;22;30;38;2;255;255;255" },
        @{ Name = "Blue   "; Code = "48;2;122;162;247;38;2;22;22;30" },
        @{ Name = "Purple "; Code = "48;2;187;154;247;38;2;22;22;30" },
        @{ Name = "Cyan   "; Code = "48;2;42;195;222;38;2;22;22;30" },
        @{ Name = "Green  "; Code = "48;2;158;206;106;38;2;22;22;30" },
        @{ Name = "Yellow "; Code = "48;2;224;175;104;38;2;22;22;30" },
        @{ Name = "Orange "; Code = "48;2;255;158;100;38;2;22;22;30" },
        @{ Name = "Red    "; Code = "48;2;247;118;142;38;2;255;255;255" }
    )
    $swatchLine = "  "
    foreach ($c in $colors) {
        $swatchLine += "$e[$($c.Code)m  $($c.Name)$e[0m "
    }
    Write-Host $swatchLine
    Write-Host ""

    Write-Host "  💡 Syntax Highlighting Preview:" -ForegroundColor Yellow
    $sampleCmd = "  $e[38;2;122;162;247mGet-ChildItem$e[0m $e[38;2;187;154;247m-Path$e[0m $e[38;2;158;206;106m`"C:\Projects`"$e[0m $e[38;2;137;221;255m|$e[0m $e[38;2;122;162;247mWhere-Object$e[0m { $e[38;2;255;158;100m`$_$e[0m.$e[38;2;125;207;255mLength$e[0m $e[38;2;187;154;247m-gt$e[0m $e[38;2;224;175;104m1000$e[0m } $e[38;2;110;115;141m# Filter files$e[0m"
    Write-Host $sampleCmd
    Write-Host ""

    Write-Host "  ✅ Installation Complete! Open a new PowerShell terminal to verify." -ForegroundColor Green
    Write-Host "  ────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}
