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
      version = "GE-Proton7-29";
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
        sha256 = "1j4i7frfvahxjkjxcsvmfsz5hkd58hg1h8j9k9gzpq4xlnwhf4di";
      };
    in rec {
      recursive = true;
      inherit source;
      target = ".local/share/Steam/compatibilitytools.d/Proton-${version}/";
    };
  };
}
