{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShellNoCC {
  buildInputs = [
    bintools
    gcc
    libffi.dev
    nodejs
    ruby
    yarn
  ];
}
