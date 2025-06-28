# PowerShell script to monitor agent status files
param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    
    [Parameter(Mandatory=$true)]
    [string]$AgentName,
    
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSeconds = 0  # 0 = no timeout, wait indefinitely
)

$statusFile = "issue-$FeatureName/.status/$AgentName.status"
$startTime = Get-Date
$lastStatus = ""

Write-Host "Monitoring $AgentName for feature: $FeatureName" -ForegroundColor Cyan
Write-Host "Status file: $statusFile" -ForegroundColor Gray
Write-Host "Timeout: $TimeoutSeconds seconds" -ForegroundColor Gray
Write-Host "" 

while ($true) {
    # Check if timeout exceeded (only if timeout is set)
    if ($TimeoutSeconds -gt 0) {
        $elapsed = (Get-Date) - $startTime
        if ($elapsed.TotalSeconds -gt $TimeoutSeconds) {
            Write-Host "`nTimeout reached. Agent may still be running." -ForegroundColor Yellow
            break
        }
    }
    
    # Check if status file exists
    if (Test-Path $statusFile) {
        try {
            $status = Get-Content $statusFile | ConvertFrom-Json
            
            # Display progress if changed
            if ($status.current_task -ne $lastStatus) {
                $timestamp = Get-Date -Format "HH:mm:ss"
                $progress = $status.progress
                $progressBar = "[" + ("=" * [Math]::Floor($progress/5)) + (" " * (20 - [Math]::Floor($progress/5))) + "]"
                
                Write-Host "`r[$timestamp] $progressBar $progress% - $($status.current_task)" -NoNewline
                $lastStatus = $status.current_task
            }
            
            # Check if completed
            if ($status.status -eq "completed") {
                Write-Host "`n`n[SUCCESS] $AgentName completed successfully!" -ForegroundColor Green
                return $true
            }
            elseif ($status.status -eq "error") {
                Write-Host "`n`n[ERROR] $AgentName encountered an error!" -ForegroundColor Red
                return $false
            }
        }
        catch {
            # Status file might be mid-write, ignore and try again
        }
    }
    
    Start-Sleep -Seconds 2
}

return $false