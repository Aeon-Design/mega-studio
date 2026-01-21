†# AutoSync-MegaStudio.ps1
# Synchronizes Antigravity Mega Studio Agents to all projects (Physical Copy).
# Source: C:\Users\Abdullah\.agent
# Target: C:\Users\Abdullah\Projects\*

$SourceAgentPath = "C:\Users\Abdullah\.agent"
$ProjectsRoot = "C:\Users\Abdullah\Projects"

Write-Host "Antigravity Auto-Sync Service (Physical Copy) Started..." -ForegroundColor Cyan
Write-Host "Source: $SourceAgentPath" -ForegroundColor Gray

# Validate Source
if (-not (Test-Path $SourceAgentPath)) {
    Write-Error "CRITICAL: Source .agent folder not found at $SourceAgentPath"
    exit 1
}

# Iterate through all subdirectories in Projects
$Projects = Get-ChildItem -Path $ProjectsRoot -Directory

foreach ($Project in $Projects) {
    $TargetAgentPath = Join-Path $Project.FullName ".agent"
    
    Write-Host "Syncing: $($Project.Name)..." -NoNewline

    # 1. Check & Remove Symlinks/Junctions (Crucial step to avoid recursion)
    if (Test-Path $TargetAgentPath) {
        $Item = Get-Item $TargetAgentPath -Force
        if ($Item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
            Write-Host " [REMOVING LINK]" -ForegroundColor Yellow -NoNewline
            Remove-Item -Path $TargetAgentPath -Recurse -Force
        }
    }

    # 2. Execute Robocopy Mirror (/MIR)
    # /MIR :: Mirror a directory tree (equivalent to /E plus /PURGE).
    
    $Log = robocopy $SourceAgentPath $TargetAgentPath /MIR /NFL /NDL /NJH /NJS /R:0 /W:0
    
    # Check Robocopy Exit Code (0-7 is success/changes)
    if ($LASTEXITCODE -lt 8) {
        Write-Host " [OK] (Synced)" -ForegroundColor Green
    }
    else {
        Write-Host " [ERROR] Robocopy Failed ($LASTEXITCODE)" -ForegroundColor Red
    }
}

Write-Host "All projects are physically synced." -ForegroundColor Green
Write-Host "Run this script again whenever you update the Master Agents." -ForegroundColor Gray
†21file:///c:/Users/Abdullah/AutoSync-MegaStudio.ps1