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
  };
}
