# Check and repair fnm-managed Node, npm and npx on Windows.
function Repair-Fnm {
    [CmdletBinding()]
    param([switch] $Default)

    $ErrorActionPreference = 'Stop'
    if (-not $IsWindows -and $env:OS -ne 'Windows_NT') { return }
    if (-not (Get-Command fnm -ErrorAction SilentlyContinue)) {
        throw 'fnm is missing. Install Schniz.fnm with Winget or run chezmoi apply.'
    }

    function Test-FnmCommand([string] $Executable, [string[]] $Arguments, [string] $Expected) {
        try {
            $output = (& $Executable @Arguments 2>$null | Out-String).Trim()
            return ($LASTEXITCODE -eq 0 -and $output -match $Expected)
        } catch { return $false }
    }

    $logDir = Join-Path $HOME '.config/personalScripts/logs'
    $log = Join-Path $logDir 'Repair-Fnm.log'
    $temporary = Join-Path ([IO.Path]::GetTempPath()) ('fnm-repair-' + [guid]::NewGuid())
    try {
        if (-not $env:FNM_MULTISHELL_PATH) {
            $fnmEnv = fnm env --shell powershell | Out-String
            if ($LASTEXITCODE -ne 0) { throw 'fnm environment initialization failed.' }
            Invoke-Expression $fnmEnv
        }
        $version = (fnm current | Out-String).Trim()
        if ($Default -or $version -notmatch '^v\d+\.\d+\.\d+$') {
            $versions = fnm list | Out-String
            if ($LASTEXITCODE -ne 0) { throw 'Unable to query fnm installations.' }
            if ($versions -match '(?m)^\s*\*?\s*(v\d+\.\d+\.\d+)\s+default\s*$') {
                $version = $Matches[1]
            } else {
                # Match this repository's Node major on a new machine.
                fnm install 26 --progress never
                if ($LASTEXITCODE -ne 0) { throw 'Node 26 installation failed.' }
                fnm default 26
                if ($LASTEXITCODE -ne 0) { throw 'Setting the fnm default failed.' }
                fnm use default --log-level quiet
                if ($LASTEXITCODE -ne 0) { throw 'Selecting the fnm default failed.' }
                $version = (fnm current | Out-String).Trim()
            }
        }
        if ($version -notmatch '^v\d+\.\d+\.\d+$') { throw 'Unable to determine a managed Node version.' }
        $installation = Join-Path $env:FNM_DIR "node-versions/$version/installation"
        $node = Join-Path $installation 'node.exe'
        $npm = Join-Path $installation 'node_modules/npm/bin/npm-cli.js'
        $npx = Join-Path $installation 'node_modules/npm/bin/npx-cli.js'
        $nodeHealthy = (Test-FnmCommand $node @('--version') ('^' + [regex]::Escape($version) + '$')) -and
            (Test-FnmCommand $node @('-p', '6 * 7') '^42$')
        $launchers = @('npm', 'npm.cmd', 'npm.ps1', 'npx', 'npx.cmd', 'npx.ps1')
        $missing = @($launchers | Where-Object { -not (Test-Path -LiteralPath (Join-Path $installation $_) -PathType Leaf) })
        $npmHealthy = $nodeHealthy -and $missing.Count -eq 0 -and
            (Test-FnmCommand $node @($npm, '--version') '^\d+\.\d+\.\d+') -and
            (Test-FnmCommand $node @($npx, '--version') '^\d+\.\d+\.\d+')

        if (-not $nodeHealthy -or -not $npmHealthy) {
            New-Item -ItemType Directory -Force -Path $logDir | Out-Null
            Write-Host "Repairing Node/npm/npx for $version..."
            Add-Content -LiteralPath $log -Value "$(Get-Date -Format o) INFO: $version Node healthy=$nodeHealthy; npm/npx healthy=$npmHealthy"
            # Force a clean download without deleting aliases or global packages.
            fnm install $version --fnm-dir $temporary --progress never
            if ($LASTEXITCODE -ne 0) { throw "fnm download failed with exit code $LASTEXITCODE" }
            $clean = Join-Path $temporary "node-versions/$version/installation"
            $cleanNode = Join-Path $clean 'node.exe'
            if (-not (Test-FnmCommand $cleanNode @('-p', '6 * 7') '^42$')) {
                throw 'Downloaded Node cannot execute JavaScript.'
            }
            foreach ($cli in @('npm', 'npx')) {
                if (-not (Test-FnmCommand $cleanNode @((Join-Path $clean "node_modules/npm/bin/$cli-cli.js"), '--version') '^\d+\.\d+\.\d+')) {
                    throw "Downloaded $cli failed its version check."
                }
            }
            foreach ($file in $launchers) {
                if (-not (Test-Path -LiteralPath (Join-Path $clean $file))) { throw "Download is missing $file" }
            }
            New-Item -ItemType Directory -Force -Path $installation | Out-Null
            # Do not overwrite a healthy node.exe: it may be running this session.
            if (-not $nodeHealthy) {
                Copy-Item -LiteralPath $cleanNode -Destination $node -Force
            }
            New-Item -ItemType Directory -Force -Path (Join-Path $installation 'node_modules') | Out-Null
            Copy-Item -LiteralPath (Join-Path $clean 'node_modules/npm') -Destination (Join-Path $installation 'node_modules') -Recurse -Force
            foreach ($file in $launchers) {
                Copy-Item -LiteralPath (Join-Path $clean $file) -Destination $installation -Force
            }
        }
        fnm use $version --log-level quiet
        if ($LASTEXITCODE -ne 0) { throw "Unable to select Node $version" }
        if (-not (Test-FnmCommand 'node.exe' @('-p', '6 * 7') '^42$') -or
            -not (Test-FnmCommand 'npm.cmd' @('--version') '^\d+\.\d+\.\d+') -or
            -not (Test-FnmCommand 'npx.cmd' @('--version') '^\d+\.\d+\.\d+')) {
            throw 'Node/npm/npx verification failed after selecting the installation.'
        }
        if (-not $nodeHealthy -or -not $npmHealthy) {
            Add-Content -LiteralPath $log -Value "$(Get-Date -Format o) SUCCESS: Node, npm and npx verified for $version"
        }
    } catch {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
        Add-Content -LiteralPath $log -Value "$(Get-Date -Format o) ERROR: $($_.Exception.Message)"
        throw
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Recurse -Force }
    }
}
