{ pkgs ? (let lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in import (builtins.fetchTarball {
  url =
    "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
  sha256 = lock.nodes.nixpkgs.locked.narHash;
}) { }) }:

let
  dependencies = with pkgs; [];
in pkgs.mkShell {
  name = "gleam-shell";
  buildInputs = with pkgs; [
    erlang
    gleam
    rebar3
    elixir
  ];
  packages = dependencies;
  shellHook = ''
    echo "shell ready"
    gleam --version
  '';
}
