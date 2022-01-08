{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-ge = let
      version = "7.0rc3-GE-1";
      name = "wine-lutris-ge-7.0rc3-1-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "12wg99nfgi511ckvk2v4s893vq2iwdrz7p01rv18rqsschm2fxay";
      };
      target = "lutris/runners/wine/${name}";
    };
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
