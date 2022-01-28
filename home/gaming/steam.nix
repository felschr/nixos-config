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
      version = "7.0rc6-GE-1";
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
        sha256 = "sha256:07i4nfiilrqjzingnjdi3ih4g04bfr9a7xxrw8jbpb7z9nrf3gqc";
      };
    in rec {
      recursive = true;
      inherit source;
      target = ".local/share/Steam/compatibilitytools.d/Proton-${version}/";
    };
  };
}
