{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-ge = let
      version = "7.1-GE-1";
      name = "wine-lutris-ge-7.1-1-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "1x29ydla6sww2plbinl7pdjlmlg52sf5c6c9xrfpl1cg6svgqnk6";
      };
      target = "lutris/runners/wine/${name}";
    };
  };
}
