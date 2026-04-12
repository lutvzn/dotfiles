{
  description = "A collection of CLI tools for my system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
  utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      cliPackages = import ./cli.nix { inherit pkgs; };
      systemCli = pkgs.buildEnv {
        name = "system-cli";
        paths = cliPackages;
      };
    in
      {
        packages.system-cli = systemCli;
        packages.default = systemCli;
      }
    );
}
