# env.nu
#
# Installed by:
# version = "0.110.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

# Prepend user bin and Nix directories
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend [
        ($env.HOME | path join ".local" "bin")
        ($env.HOME | path join "bin")
        ($env.HOME | path join ".cargo" "bin")
    ]
)

let global_nix_bin = "/nix/var/nix/profiles/default/bin"
if ($global_nix_bin | path exists) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $global_nix_bin)
}

$env.PATH = ($env.PATH | uniq)
