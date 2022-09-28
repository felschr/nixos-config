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
    proton-ge = let version = "GE-Proton7-35";
    in rec {
      recursive = true;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
        sha256 = "12n7w49ml79id1yg4rbbh48v021p3waspq5aqvkxxy8n1gp8dssv";
      };
      target = ".local/share/Steam/compatibilitytools.d/Proton-${version}/";
    };
  };
}
