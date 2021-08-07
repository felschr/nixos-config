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
    # TODO doesn't show up in steam
    proton-ge = let
      version = "6.14-GE-2";
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
        sha256 = "18hfag1nzj6ldy0ign2yjfzfms0w23vmcykgl8h1dfk0xjaql8gk";
      };
    in rec {
      recursive = true;
      inherit source;
      target = ".steam/root/compatibilitytools.d/Proton-${version}/";
    };
  };
}
