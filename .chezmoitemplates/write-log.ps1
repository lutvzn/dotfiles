# Shared logger for the Windows run scripts. Set $logFile after including.
$logDir = Join-Path $HOME ".config\personalScripts\logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

function Write-Log {
    param(
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}
