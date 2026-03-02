{
  description = "A collection of CLI tools for my system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.buildEnv {
          name = "cli-tools";
          paths = with pkgs; [
            atuin
            bun
            chezmoi
            curl
            fd
            fish
            fnm
            fzf
            gh
            go
            glab
            lazygit
            neovim
            pipx
            python314
            ripgrep
            shellcheck
            starship
            zoxide
            nerd-fonts.fira-code
          ];
        };
      }
    );
}
