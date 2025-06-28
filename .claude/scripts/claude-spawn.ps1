# PowerShell script to spawn Claude in new Windows Terminal window with instructions

param(
    [Parameter(Mandatory=$true)]
    [string]$Task,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = (Get-Location).Path
)

# Convert Windows path to WSL path if needed
if ($ProjectPath -match '^([A-Z]):\\(.*)$') {
    $drive = $matches[1].ToLower()
    $path = $matches[2] -replace '\\', '/'
    $wslPath = "/mnt/$drive/$path"
} else {
    $wslPath = $ProjectPath
}

# Build the command to run in the new terminal
# First enter WSL Ubuntu, then navigate to directory, then run claude
# Use full path to claude executable
$command = "cd '$wslPath' && /home/zachary/.npm-global/bin/claude '$Task'"

# Open new Windows Terminal window
# -w new opens in a completely new window
wt.exe -w new wsl -d Ubuntu -- bash -c "$command"

Write-Host "Spawned Claude with task: $Task" -ForegroundColor Green
Write-Host "In directory: $ProjectPath" -ForegroundColor Yellow