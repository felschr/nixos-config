{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-runner-sc = let
      package = { }:
        pkgs.stdenv.mkDerivation rec {
          name = "wine-runner-sc";
          version = "6.10";

          src = pkgs.fetchurl {
            url =
              "https://github.com/snatella/wine-runner-sc/releases/download/wine-v${version}/wine-runner-${version}-gold-fsync.tgz";
            sha256 = "03v0qrhjc0qv3rmx3zb82d3pwqp3ys0r3dhqdplls2nv69ik5b9l";
          };

          phases = [ "unpackPhase" "installPhase" ];
          unpackCmd = "tar -xzf $src";
          sourceRoot = ".";
          installPhase = "cp -r . $out";
        };
      source = pkgs.callPackage package { };
    in {
      recursive = false;
      inherit source;
      target = "lutris/runners/wine/wine-runner-sc";
    };
  };
}
