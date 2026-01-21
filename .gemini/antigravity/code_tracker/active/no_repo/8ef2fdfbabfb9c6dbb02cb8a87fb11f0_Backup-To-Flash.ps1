�<#
.SYNOPSIS
    Mega Studio Backup Script
    Copies critical Agent System files and Projects to Flash Drive (E:)

.DESCRIPTION
    Proprietary backup script for Antigravity Mega Studio.
    Sources:
    - C:\Users\Abdullah\.agent (Agents & Workflows)
    - C:\Users\Abdullah\.gemini (Grimoires & Brain)
    - C:\Users\Abdullah\Projects (Source Code)
    
    Destination:
    - E:\MegaStudio_Backup
#>

$SourceBase = "C:\Users\Abdullah"
$DestBase = "E:\MegaStudio_Backup"

Write-Host "🚀 Mega Studio Backup Initialized..." -ForegroundColor Cyan
Write-Host "Target: $DestBase" -ForegroundColor Yellow

# Ensure Destination Exists
if (!(Test-Path $DestBase)) {
    New-Item -ItemType Directory -Path $DestBase | Out-Null
    Write-Host "Created Backup Directory." -ForegroundColor Green
}

# Define Backup Targets
$Targets = @(
    ".agent",
    ".gemini",
    "Projects"
)

foreach ($Target in $Targets) {
    $SourcePath = Join-Path $SourceBase $Target
    $DestPath = Join-Path $DestBase $Target
    
    Write-Host "`n⏳ Backing up: $Target" -ForegroundColor Cyan
    
    # Robocopy Command
    # /MIR : Mirror (Exact copy, deletes extras in dest)
    # /XO  : Exclude Older (Only copy new/changed files)
    # /R:3 : Retry 3 times on failure
    # /W:1 : Wait 1 second between retries
    # /MT:16 : Multi-threaded (Faster)
    
    robocopy $SourcePath $DestPath /MIR /XO /R:3 /W:1 /MT:16
    
    if ($LASTEXITCODE -le 7) {
        Write-Host "✅ $Target Backup Complete." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Error backing up $Target. (Code: $LASTEXITCODE)" -ForegroundColor Red
    }
}

Write-Host "`n💾 Creating Restore/Setup Script on Flash Drive..." -ForegroundColor Magenta

# Copy the Setup Script to Flash Drive (Will be created in next step)
Copy-Item "C:\Users\Abdullah\Setup-New-PC.ps1" -Destination "$DestBase\Setup-New-PC.ps1" -Force -ErrorAction SilentlyContinue

Write-Host "`n🎉 Backup Operation Completed Successfully!" -ForegroundColor Green
Write-Host "You can now take drive E: to any new PC." -ForegroundColor Gray
Read-Host "Press Enter to Exit"
�*cascade082-file:///C:/Users/Abdullah/Backup-To-Flash.ps1