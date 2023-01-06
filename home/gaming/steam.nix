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
    proton-ge = let version = "GE-Proton7-43";
    in rec {
      recursive = true;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
        sha256 = "1qw87ychhx8z5wvzw8w1j0h554mxs9w14glbbn2ywwyhp643h2hb";
      };
      target = ".local/share/Steam/compatibilitytools.d/Proton-${version}/";
    };
  };
}
