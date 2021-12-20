{ config, pkgs, nixosConfig, ... }:

let
  steam = pkgs.steam.override {
    extraLibraries = pkgs:
      with nixosConfig.hardware.opengl;
      if pkgs.hostPlatform.is64bit then
        [ package ] ++ extraPackages
      else
        [ package32 ] ++ extraPackages32;
  };
in {
  home.packages = [ steam steam.run pkgs.protontricks ];

  home.file = {
    proton-ge = let
      version = "7.0rc2-GE-1";
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
        sha256 = "0ch1vm371zrp2iqai4n3zfzl2s9kgp8a6ph9vgfwclwplc787xbr";
      };
    in rec {
      recursive = true;
      inherit source;
      target = ".steam/root/compatibilitytools.d/Proton-${version}/";
    };
  };
}
