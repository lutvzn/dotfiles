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
    ]
    | where {|path| $path | path exists }
)

$env.PATH = ($env.PATH | uniq)
