÷# AutoSync-MegaStudio.ps1
# Synchronizes Antigravity Mega Studio Agents to all projects (Physical Copy).
# Source: C:\Users\Abdullah\.agent
# Targets: 
#   1. C:\Users\Abdullah\Projects\* (Your Main Projects)

$SourceAgentPath = "C:\Users\Abdullah\.agent"
$ProjectsRoot = "C:\Users\Abdullah\Projects"

Write-Host "Antigravity Auto-Sync Service (Deep Sync) Started..." -ForegroundColor Cyan
Write-Host "Source: $SourceAgentPath" -ForegroundColor Gray

# Validate Source
if (-not (Test-Path $SourceAgentPath)) {
    Write-Error "CRITICAL: Source .agent folder not found at $SourceAgentPath"
    exit 1
}

# Define Sync Function
function Sync-Project($Path) {
    $TargetAgentPath = Join-Path $Path ".agent"
    Write-Host "Syncing: $(Split-Path $Path -Leaf)..." -NoNewline

    # 1. Remove Links/Legacy
    if (Test-Path $TargetAgentPath) {
        $Item = Get-Item $TargetAgentPath -Force
        if ($Item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
            Remove-Item -Path $TargetAgentPath -Recurse -Force
        }
    }

    # 2. Robocopy
    $Log = robocopy $SourceAgentPath $TargetAgentPath /MIR /NFL /NDL /NJH /NJS /R:0 /W:0
    
    if ($LASTEXITCODE -lt 8) {
        Write-Host " [OK]" -ForegroundColor Green
    }
    else {
        Write-Host " [FAIL]" -ForegroundColor Red
    }
}

# Sync Main Projects
Write-Host "`n--- Syncing Projects ---" -ForegroundColor Yellow
if (Test-Path $ProjectsRoot) {
    Get-ChildItem -Path $ProjectsRoot -Directory | ForEach-Object { Sync-Project $_.FullName }
}

Write-Host "`nâœ… Sync Complete. (Projects Only)" -ForegroundColor Green
— *cascade08—˜*cascade08˜™ *cascade08™¢*cascade08¢¿ *cascade08¿Ö *cascade08Ö² *cascade08²µ *cascade08µâ *cascade08âå*cascade08åæ *cascade08æè*cascade08èé *cascade08éë*cascade08ëï *cascade08ïğ*cascade08ğñ *cascade08ñô*cascade08ôö *cascade08öú*cascade08úû *cascade08ûü*cascade08üı *cascade08ış*cascade08ş *cascade08‚*cascade08‚… *cascade08…ˆ*cascade08ˆŒ *cascade08Œ*cascade08 *cascade08*cascade08 *cascade08‘*cascade08‘’ *cascade08’“*cascade08“š *cascade08š›*cascade08› *cascade08*cascade08Ÿ *cascade08Ÿ *cascade08 É *cascade08ÉË*cascade08Ëñ *cascade08ñ÷*cascade08÷ø *cascade08øù*cascade08ùú *cascade08úş*cascade08şÿ *cascade08ÿ„*cascade08„… *cascade08…‡*cascade08‡« *cascade08«¬*cascade08¬± *cascade08±²*cascade08²³ *cascade08³´*cascade08´¶ *cascade08¶·*cascade08·«
 *cascade08«
­
*cascade08­
Ñ
 *cascade08Ñ
ç
*cascade08ç
ó
 *cascade08ó
¢*cascade08¢¤ *cascade08¤ª*cascade08ª« *cascade08«¸*cascade08¸¿ *cascade08¿Ä*cascade08ÄÅ *cascade08ÅÜ*cascade08Üİ *cascade08İâ*cascade08âã *cascade08ãå*cascade08åæ *cascade08æí*cascade08íî *cascade08î*cascade08‚ *cascade08‚*cascade08 *cascade08*cascade08 *cascade08*cascade08  *cascade08 ­ *cascade08­° *cascade08°² *cascade08²µ*cascade08µ¸ *cascade08¸¾ *cascade08¾Á *cascade08ÁÂ *cascade08ÂÕ*cascade08Õ× *cascade08×Ø *cascade08ØÙ*cascade08ÙÛ *cascade08ÛÜ*cascade08Üİ *cascade08İò *cascade08òõ*cascade08õ÷ *cascade0821file:///C:/Users/Abdullah/AutoSync-MegaStudio.ps1