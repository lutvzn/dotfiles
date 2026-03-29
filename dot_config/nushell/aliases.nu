# .config/nushell/aliases.nu - Commonly used aliases for Nushell

# 1. Navigation
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias ..... = cd ../../../..

# 2. Tools & Core Shortcuts
alias g = git
alias lg = lazygit
alias sctl = systemctl
alias vim = nvim
alias vi = nvim

def --wrapped cz [...rest] {
    ^chezmoi ...$rest
}

def nuf [] {
    ^$"($env.HOME)/.config/personalScripts/update-flake-lock.sh"
}
