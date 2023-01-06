{ config, pkgs, lib, ... }:

{
  # TODO move into heroic.nix or rename lutris.nix
  home.packages = with pkgs; [ lutris heroic ];

  xdg.dataFile = {
    wine-ge = let
      version = "GE-Proton7-35";
      name = "wine-lutris-${version}-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "17adirraf6m9kiaa9bkc991h1m5r5g8rbjhgv3ccrvd0v1339zn7";
      };
      target = "lutris/runners/wine/${name}";
    };
  };
}
