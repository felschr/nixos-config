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
  home.packages = [ steam steam.run ];

  xdg.dataFile = {
    # TODO doesn't show up in steam
    proton-ge = let version = "6.12-GE-1";
    in {
      recursive = false;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
        sha256 = "0j3ca5qqvj294ax9xpxcm9s70vdkhk1sskn53hq3pcn3p9yr6phq";
      };
      target = "Steam/compatibilitytools.d/proton-ge-${version}";
    };
  };
}
