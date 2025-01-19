{ pkgs, ... }:

{
  home.file = {
    # proton-ge =
    #   let
    #     version = "GE-Proton7-54";
    #   in
    #   {
    #     recursive = true;
    #     source = builtins.fetchTarball {
    #       url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    #       sha256 = "1iy14s1d48wxnnmw45jh5w2yadkrvwip8k91xljwg066aprb00vi";
    #     };
    #     target = ".local/share/Steam/compatibilitytools.d/Proton-${version}/";
    #   };
  };
}
