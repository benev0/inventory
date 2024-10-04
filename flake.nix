{
  description = "Development environment Gleam";

  inputs.nixpkgs.url = "https://github.com/nixos/nixpkgs/tarball/28b5b8af91ffd2623e995e20aee56510db49001a";

  # "github:NixOS/nixpkgs/release-24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = import ./shell.nix { inherit pkgs; };
    });
}
