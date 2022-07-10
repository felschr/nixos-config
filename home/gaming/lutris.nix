{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-ge = let
      version = "GE-Proton7-20";
      name = "wine-lutris-${version}-x86_64";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${version}/${name}.tar.xz";
        sha256 = "1yfcmfjyxfxkp14a3h2ffr6zfb9chk8676b978vk96vamdyr06j1";
      };
      target = "lutris/runners/wine/${name}";
    };
  };
}
