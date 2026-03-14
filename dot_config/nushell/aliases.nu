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
alias cz = chezmoi
alias vim = nvim
alias vi = nvim

# 3. Modern Replacements (only if available)
def-env ls [...args] {
    if (which eza | is-not-empty) {
        eza ...$args
    } else {
        ^ls ...$args
    }
}

def-env ll [...args] {
    if (which eza | is-not-empty) {
        eza -l --icons=auto --group-directories-first ...$args
    } else {
        ^ls -l ...$args
    }
}

def-env l. [...args] {
    if (which eza | is-not-empty) {
        eza -d .* ...$args
    } else {
        ^ls -d .* ...$args
    }
}

def-env l1 [...args] {
    if (which eza | is-not-empty) {
        eza -1 ...$args
    } else {
        ^ls -1 ...$args
    }
}

def-env grep [...args] {
    if (which ug | is-not-empty) {
        ug ...$args
    } else {
        ^grep ...$args
    }
}

def-env egrep [...args] {
    if (which ug | is-not-empty) {
        ug -E ...$args
    } else {
        ^grep -E ...$args
    }
}

def-env fgrep [...args] {
    if (which ug | is-not-empty) {
        ug -F ...$args
    } else {
        ^grep -F ...$args
    }
}
