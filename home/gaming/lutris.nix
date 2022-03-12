{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-ge = let
      version = "GE-Proton7-6";
      name = "wine-lutris-${version}-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "0w5yqnc2ic1fd1swc2m1qjmz75w6ndn06k3r61dg0fm88yk440zr";
      };
      target = "lutris/runners/wine/${name}";
    };
  };
}
