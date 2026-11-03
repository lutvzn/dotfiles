# Shared Bitwarden helpers for the Windows run scripts. Include after write-log.ps1.
# Unlock-Bitwarden prompts once; Lock-Bitwarden relocks only what it unlocked.
$bwLockedByScript = $false

# Runs a bw command that needs the master password, allowing three attempts.
# Read-Host masks input with *; --passwordenv keeps it out of the process list.
function Invoke-BwWithPassword {
    param(
        [string[]]$Arguments
    )

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $secure = Read-Host -Prompt "Bitwarden master password" -AsSecureString
        $env:BW_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
        $session = bw @Arguments --passwordenv BW_PASSWORD --raw
        $bwExitCode = $LASTEXITCODE
        Remove-Item Env:BW_PASSWORD

        if ($bwExitCode -eq 0 -and $session) {
            $env:BW_SESSION = $session
            return $true
        }
        Write-Log "Bitwarden rejected the password (attempt $attempt of 3)."
    }

    return $false
}

# Logs in to or unlocks Bitwarden on the given server and sets $env:BW_SESSION.
# Reuses an already unlocked BW_SESSION from the environment.
function Unlock-Bitwarden {
    param(
        [string]$Server
    )

    $bwStatus = bw status | ConvertFrom-Json

    if ($env:BW_SESSION -and $bwStatus.status -eq "unlocked") {
        Write-Log "Using the unlocked Bitwarden session from BW_SESSION."
    } elseif ($bwStatus.status -eq "unauthenticated") {
        if ($bwStatus.serverUrl -ne $Server) {
            bw config server $Server | Out-Null
        }

        Write-Log "Logging in to Bitwarden at $Server."
        $bwEmail = Read-Host -Prompt "Bitwarden email"
        if (-not (Invoke-BwWithPassword @("login", $bwEmail))) {
            Write-Log "ERROR: Bitwarden login failed."
            return $false
        }
        $script:bwLockedByScript = $true
    } else {
        Write-Log "Unlocking Bitwarden."
        if (-not (Invoke-BwWithPassword @("unlock"))) {
            Write-Log "ERROR: Bitwarden unlock failed."
            return $false
        }
        $script:bwLockedByScript = $true
    }

    bw sync 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Bitwarden sync failed; using the cached vault."
    }
    return $true
}

# Returns the password field of a Bitwarden item; $null if it does not exist.
function Get-BitwardenPassword {
    param(
        [string]$Item
    )

    $password = bw get password $Item 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    return $password
}

# Returns a Bitwarden item as an object; $null if it does not exist.
function Get-BitwardenItem {
    param(
        [string]$Item
    )

    $json = bw get item $Item 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $json) { return $null }
    return $json | ConvertFrom-Json
}

function Lock-Bitwarden {
    if ($script:bwLockedByScript) {
        bw lock 2>$null | Out-Null
        Remove-Item Env:BW_SESSION -ErrorAction SilentlyContinue
        $script:bwLockedByScript = $false
    }
}
