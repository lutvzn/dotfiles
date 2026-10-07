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

# Prepend user bin and Homebrew directories
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend [
        "/home/linuxbrew/.linuxbrew/bin"
        "/home/linuxbrew/.linuxbrew/sbin"
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        "/usr/local/bin"
        "/usr/local/sbin"
        ($env.HOME | path join ".local" "bin")
        ($env.HOME | path join "bin")
        ($env.HOME | path join ".cargo" "bin")
        ($env.HOME | path join ".local" "share" "pi" "bin")
        ($env.HOME | path join ".local" "share" "pi")
        ($env.HOME | path join ".local" "share" "fnm")
        ($env.HOME | path join ".bun" "bin")
    ]
    | where {|path| $path | path exists }
)

$env.PATH = ($env.PATH | uniq)

if (($env.HOME | path join ".bun") | path exists) {
    $env.BUN_INSTALL = ($env.HOME | path join ".bun")
}

# fnm has no native Nu shell output; load its JSON environment instead.
if (which fnm | is-not-empty) {
    let fnm_env = (^fnm env --json | from json)
    load-env $fnm_env
    let node_bin = if $nu.os-info.name == "windows" {
        $fnm_env.FNM_MULTISHELL_PATH
    } else {
        $fnm_env.FNM_MULTISHELL_PATH | path join "bin"
    }
    $env.PATH = ($env.PATH | prepend $node_bin | uniq)
    ^fnm use default --log-level quiet
}
