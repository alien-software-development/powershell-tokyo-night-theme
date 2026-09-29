<#
.SYNOPSIS
    Installs and applies your custom PowerShell terminal theme across any Windows computer.
.DESCRIPTION
    Applies Tokyo Night Dark Theme to:
    1. PowerShell 7+ and Windows PowerShell 5.1 profiles (PSReadLine, $Host, $PSStyle, Custom Prompt)
    2. Windows Console Registry (HKCU:\Console) for native console windows
    3. Windows Terminal settings.json (if installed)
#>

[CmdletBinding()]
param()

$Host.UI.RawUI.WindowTitle = "Applying PowerShell Theme..."
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "      PowerShell Universal Theme Installer & Sync         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------------------------
# 1. Profile Script Template
# -------------------------------------------------------------------------
$profileContent = @'
# ==============================================================================
# Professional Cohesive Dark Theme - Permanent Configuration
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

    # Palette:
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
# 2. Write Profile for PowerShell 7 and Windows PowerShell 5.1
# -------------------------------------------------------------------------
Write-Host "[1/3] Writing PowerShell Profiles..." -ForegroundColor Green

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
        try {
            $dir = Split-Path $file -Parent
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            [System.IO.File]::WriteAllText($file, $profileContent, [System.Text.Encoding]::UTF8)
            Write-Host "  -> Profile saved: $file" -ForegroundColor Gray
        } catch {
            Write-Warning "Could not write to $($file): $_"
        }
    }
}

# -------------------------------------------------------------------------
# 3. Configure Windows Console Registry (HKCU:\Console)
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[2/3] Configuring Windows Console Registry (Colors & Palettes)..." -ForegroundColor Green

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
        Write-Host "  -> Registry configured: $keyPath" -ForegroundColor Gray
    } catch {
        Write-Warning "Could not update $($keyPath): $_"
    }
}

# -------------------------------------------------------------------------
# 4. Configure Windows Terminal (if present)
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[3/3] Checking for Windows Terminal..." -ForegroundColor Green

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

            # Filter out existing "Tokyo Night" scheme if any and add updated
            $filteredSchemes = @($settings.schemes | Where-Object { $_.name -ne "Tokyo Night" })
            $filteredSchemes += $tokyoNightScheme
            $settings.schemes = $filteredSchemes

            # Set as default scheme
            if (-not $settings.profiles.defaults) {
                $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value (New-Object PSObject) -ErrorAction SilentlyContinue
            }
            $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value "Tokyo Night" -Force

            $updatedJson = $settings | ConvertTo-Json -Depth 32
            [System.IO.File]::WriteAllText($wtPath, $updatedJson, [System.Text.Encoding]::UTF8)
            Write-Host "  -> Windows Terminal scheme updated: $wtPath" -ForegroundColor Gray
            $wtUpdated = $true
        } catch {
            Write-Warning "Could not update Windows Terminal settings: $_"
        }
    }
}

if (-not $wtUpdated) {
    Write-Host "  -> Windows Terminal not installed or settings not found (skipped)." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Theme applied successfully on this computer!           " -ForegroundColor Green
Write-Host "  Open a new PowerShell window to see your theme.         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
