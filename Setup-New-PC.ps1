<#
.SYNOPSIS
    Mega Studio Universal Setup & Restore
    Restores environment and installs dev tools on a NEW PC.

.DESCRIPTION
    - Restores Agents (.agent)
    - Restores Knowledge (.gemini)
    - Restores Projects
    - Installs: VS Code, Android Studio, Git, Node.js, Flutter
#>

# Allow script execution if needed
Set-ExecutionPolicy Bypass -Scope Process -Force

$BackupRoot = $PSScriptRoot  # Assumes script is run FROM the flash drive folder
$TargetUserPath = $env:USERPROFILE

Write-Host "🚀 Mega Studio Restoration & Setup Protocol" -ForegroundColor Cyan
Write-Host "Source: $BackupRoot" -ForegroundColor Yellow
Write-Host "Target User: $TargetUserPath" -ForegroundColor Yellow
Write-Host "--------------------------------------------"

# 1. FILE RESTORATION
Write-Host "`n📦 Phase 1: Restoring Files..." -ForegroundColor Magenta

$FoldersToRestore = @(".agent", ".gemini", "Projects")

foreach ($Folder in $FoldersToRestore) {
    $Src = Join-Path $BackupRoot $Folder
    $Dst = Join-Path $TargetUserPath $Folder
    
    if (Test-Path $Src) {
        Write-Host "  Restoring $Folder..." -NoNewline
        robocopy $Src $Dst /MIR /R:2 /W:1 /MT:16 /NFL /NDL | Out-Null
        Write-Host " [DONE]" -ForegroundColor Green
    }
    else {
        Write-Host "  Warning: $Folder not found in backup." -ForegroundColor Yellow
    }
}

# 1.5 RESTORE VS CODE SETTINGS (Critical for Agents)
$SettingsSrc = Join-Path $BackupRoot ".vscode\settings.json"
$SettingsDstDir = Join-Path $TargetUserPath ".vscode"
if (Test-Path $SettingsSrc) {
    Write-Host "  Restoring Agent Visibility Settings..." -NoNewline
    if (!(Test-Path $SettingsDstDir)) { New-Item -ItemType Directory -Path $SettingsDstDir | Out-Null }
    Copy-Item $SettingsSrc -Destination "$SettingsDstDir\settings.json" -Force
    Write-Host " [DONE]" -ForegroundColor Green
}

# 2. TOOL INSTALLATION (Winget)
Write-Host "`n🛠️ Phase 2: Installing Developer Tools..." -ForegroundColor Magenta
Write-Host "Note: You may be prompted for UAC permissions." -ForegroundColor Gray

function Install-Tool ($Id, $Name) {
    Write-Host "  Installing $Name..." -NoNewline
    winget install --id $Id -e --source winget --accept-package-agreements --accept-source-agreements --silent | Out-Null
    if ($?) { Write-Host " [DONE]" -ForegroundColor Green }
    else { Write-Host " [FAILED/EXISTING]" -ForegroundColor Yellow }
}

Install-Tool "Microsoft.VisualStudioCode" "VS Code"
Install-Tool "Git.Git" "Git"
Install-Tool "OpenJS.NodeJS" "Node.js (LTS)"
Install-Tool "Google.AndroidStudio" "Android Studio"

# 3. FLUTTER INSTALLATION (Custom)
Write-Host "`n🦋 Phase 3: Installing Flutter..." -ForegroundColor Magenta
$FlutterPath = "C:\flutter"

if (!(Test-Path $FlutterPath)) {
    Write-Host "  Downloading Flutter Stable SDK..."
    # Download Flutter Zip (Requires Invoke-WebRequest)
    $FlutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip" # Check for latest version URL dynamically if possible, or use fixed stable
    $ZipPath = "$env:TEMP\flutter.zip"
    
    try {
        Invoke-WebRequest -Uri $FlutterUrl -OutFile $ZipPath -UseBasicParsing
        Write-Host "  Extracting to C:\..."
        Expand-Archive -Path $ZipPath -DestinationPath "C:\" -Force
        
        # Add to PATH
        $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($CurrentPath -notlike "*C:\flutter\bin*") {
            [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;C:\flutter\bin", "User")
            Write-Host "  Added Flutter to User PATH." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ❌ Failed to install Flutter automatically. Please install manually." -ForegroundColor Red
    }
}
else {
    Write-Host "  Flutter already exists at C:\flutter." -ForegroundColor Green
}

# 4. FINAL CHECK
Write-Host "`n✅ Setup Complete!" -ForegroundColor Cyan
Write-Host "Restart your computer/terminal to apply PATH changes."
Write-Host "Your agents and projects are ready at: $TargetUserPath"
Read-Host "Press Enter to Exit"
