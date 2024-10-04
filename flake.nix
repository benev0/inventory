{
  description = "Development environment Gleam";

  inputs = {
    nixpkgs.url = "https://github.com/nixos/nixpkgs/tarball/28b5b8af91ffd2623e995e20aee56510db49001a";
    flake-utils.url = "github:numtide/flake-utils";
    # rust-overlay.url = "github:oxalica/rust-overlay";
    # # flake-utils.follows = "rust-overlay/flake-utils";
    # nixpkgs.follows = "rust-overlay/nixpkgs";
  };

  outputs = { self, nixpkgs,  ...}:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # matcha = { lib, fetchFromGitHub, rustPlatform }:

    in {
      devShells.${system}.default =
        pkgs.mkShell {

          buildInputs = [
            pkgs.erlang
            pkgs.gleam
            pkgs.rebar3
            pkgs.elixir
            pkgs.glas
            pkgs.vscode-extensions.gleam.gleam
            # (rustPlatform.buildRustPackage rec {
            #   pname = "matcha";
            #   version = "0.17.0";
            #   src = pkgs.fetchFromGitHub {
            #     owner = "michaeljones";
            #     repo = "matcha";
            #     rev = "54fe7490974dc1e9787bef6d4696ee71bcfcf597";
            #     hash = "sha256-TYAgxJGCexSDM0FIDmohfr+pipyv42T5c+XBmU4RSyA=";
            #   };
            #   # cargoHash = lib.fakeHash;
            #   cargoHash = "sha256-8VZ7aglO7Jigd9IWZQeNaCjWBAcSZQDpi33+lChHUHI=";
            # })
          ];
          # packages = [];
          shellHook = ''
            export PATH="/home/ben/.cargo/bin:$PATH"
            echo "shell ready"
            gleam --version
            matcha --version
          '';
        };
    };
}
