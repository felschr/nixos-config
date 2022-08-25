{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-ge = let
      version = "GE-Proton7-25";
      name = "wine-lutris-${version}-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "191d3nwy2vhfy69jn5xgxcj93vjkkzzk7pabp9nj27fv0p9c3zk4";
      };
      target = "lutris/runners/wine/${name}";
    };
  };
}
