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
      version = "7.1-GE-2";
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
        sha256 = "1dkb6lf3pjg25rd7asbcd35343zivsgybsbal3i5rzvvi7h202lf";
      };
    in rec {
      recursive = true;
      inherit source;
      target = ".local/share/Steam/compatibilitytools.d/Proton-${version}/";
    };
  };
}
