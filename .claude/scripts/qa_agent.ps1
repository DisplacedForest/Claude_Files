# PowerShell script to spawn Claude QA agent

param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ""
)

# If no ProjectPath provided, use the directory containing this script
if ([string]::IsNullOrEmpty($ProjectPath)) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    # Go up two levels: scripts -> .claude -> project root
    $ProjectPath = Split-Path -Parent (Split-Path -Parent $ScriptDir)
}

# Convert Windows path to WSL path if needed
if ($ProjectPath -match '^([A-Z]):\\(.*)$') {
    $drive = $matches[1].ToLower()
    $path = $matches[2] -replace '\\', '/'
    $wslPath = "/mnt/$drive/$path"
} else {
    $wslPath = $ProjectPath
}

# Set feature directory path
$featureDir = "issue-$FeatureName"
$wslFeaturePath = "$wslPath/$featureDir"

# Build the command to run the QA agent
$task = "/qa_agent $FeatureName"
# Stay in project root, don't cd into feature directory
$command = "cd '$wslPath' && /home/zachary/.npm-global/bin/claude '$task'"

# Open new Windows Terminal window for QA agent
wt.exe -w new wsl -d Ubuntu -- bash -c "$command"

Write-Host "Spawned QA Agent for feature: $FeatureName" -ForegroundColor Magenta
Write-Host "Working in: $featureDir" -ForegroundColor Yellow
Write-Host "Will review all work and create final report" -ForegroundColor Cyan