{ pkgs ? import <nixpkgs> { }}:

with pkgs;
with lib;
let
  system = builtins.currentSystem;
in
  rec {
    nixpkgs-hammering = (import (pkgs.fetchFromGitHub {
      owner = "jtojnar";
      repo = "nixpkgs-hammering";
      rev = "68322842806eb1f587cc28ff0620f30e9aef2179";
      sha256 = "1agp19h7licwx79kppp8x0iq9g8d0a25xv1b7nhcq9azfgx38l9x";
    })).defaultPackage.${system};

    nix-unsafePlugins = callPackage (pkgs.fetchFromGitHub {
      owner = "rmcgibbo";
      repo = "nix-unsafePlugins";
      rev = "0bed73ada94a7ebc791b4e6fe5eec8160c5f503c";
      sha256 = "0sv9di2q75p6i8hn1mvhqsrhkg8gd4174ycalgh7lff2clk8zilq";
    }) {};


    hammering = runCommand "hammering" {
      buildInputs = [
        makeWrapper
        (python3.withPackages (pythonPackages: with pythonPackages; [
          GitPython
        ]))
      ];
    } ''
      install -D ${./tools/hammering} $out/bin/$name
      patchShebangs $out/bin/$name
      wrapProgram "$out/bin/$name" \
        --prefix PATH ":" ${pkgs.lib.makeBinPath [
            nix
          ]} \
        --set NIX_PLUGINS ${nix-unsafePlugins}/lib/nix/plugins/libunsafePlugins.so
      ln -s ${./lib} $out/lib
      '';
  }