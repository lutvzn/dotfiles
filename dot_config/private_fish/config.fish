set -g fish_greeting

if status is-interactive
    # Initialize Homebrew when available
    for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew
        if test -x $brew_bin
            eval ($brew_bin shellenv)
            break
        end
    end

    # Prepend user bin directories
    fish_add_path ~/.local/bin ~/bin

    # Tool Initialization
    if type -q zoxide; zoxide init fish | source; end
    if type -q starship; starship init fish | source; end
    if type -q atuin; atuin init fish | source; end
    if type -q fzf; fzf --fish | source; end
    if type -q fnm; fnm env --use-on-cd --shell fish | source; end

    # Modern replacements (eza for ls, ug for grep)
    if type -q eza
        alias ls='eza'
        alias ll='eza -l --icons=auto --group-directories-first'
        alias l.='eza -d .*'
        alias l1='eza -1'
    end

    if type -q ug
        alias grep='ug'
        alias egrep='ug -E'
        alias fgrep='ug -F'
    end

    # Source custom aliases
    if test -f ~/.config/aliases
        source ~/.config/aliases
    end
end
