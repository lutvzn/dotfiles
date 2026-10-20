# Winget ran earlier in the same chezmoi process; refresh its PATH additions.
# Drop duplicates: the inherited PATH already holds most registry entries, and
# cmd.exe (used by npm .cmd shims) ignores a PATH longer than 8191 characters.
$pathEntries = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
    [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + $env:PATH
$seenPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$env:PATH = @($pathEntries -split ';' | Where-Object { $_ -and $seenPaths.Add($_.TrimEnd('\')) }) -join ';'