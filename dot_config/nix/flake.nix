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
        cliPackages = import ./cli.nix { inherit pkgs; };
      in
      {
        packages.default = pkgs.buildEnv {
          name = "cli-tools";
          paths = cliPackages;
        };
      }
    );
}
