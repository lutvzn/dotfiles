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
            starship
            fish
            atuin
            zoxide
            fzf
            chezmoi
            gh
            go
	    glab
            pipx
            lazygit
            ripgrep
            shellcheck
	    neovim
            fd
            curl
          ];
        };

        # A devShell for testing
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            starship
            fish
            atuin
            zoxide
            fzf
            chezmoi
            gh
            glab
            lazygit
            ripgrep
            shellcheck
            fd
            curl
          ];
        };
      }
    );
}
