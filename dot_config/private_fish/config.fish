set -g fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path ~/.nix-profile/bin
    /home/lutvzn/.local/share/fnm/fnm env --use-on-cd --shell fish | source
    starship init fish | source
end
### bling.fish source start
test -f /usr/share/bazzite-cli/bling.fish && source /usr/share/bazzite-cli/bling.fish
### bling.fish source end
