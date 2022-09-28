{ config, pkgs, lib, ... }:

{
  # TODO move into heroic.nix or rename lutris.nix
  home.packages = with pkgs; [ lutris heroic ];

  xdg.dataFile = {
    wine-ge = let
      version = "GE-Proton7-29";
      name = "wine-lutris-${version}-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "0kabfah8h01b7f822qi0kqp3d6mrd7q7p8ygd2c14j3hczr4vyyg";
      };
      target = "lutris/runners/wine/${name}";
    };
  };
}
