{ config, pkgs, nixosConfig, ... }:

{
  home.packages = with pkgs; [ lutris ];

  xdg.dataFile = {
    wine-runner-sc.source = let version = "6.10";
    in {
      executable = true;
      recursive = true;
      source = builtins.fetchTarball {
        src =
          "https://github.com/snatella/wine-runner-sc/releases/download/wine-v${version}/wine-runner-${version}-gold-fsync.tgz";
        sha256 = "";
      };
      target = "lutris/wine/wine-runner-sc";
    };

    proton-ge = let version = "6.12-GE-1";
    in {
      executable = true;
      recursive = true;
      source = builtins.fetchTarball {
        url =
          "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
        sha256 = "12pk1bvjrziszglbrc6f0i555b19ycmf3cc70k63d53lyz3ra9vp";
      };
      target = "Steam/compatibilitytools.d/proton-ge";
    };
  };
}
