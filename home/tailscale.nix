{ pkgs, ... }:

{
  home.packages = with pkgs; [
    unstable.trayscale
    (makeAutostartItem {
      name = "dev.deedles.Trayscale";
      package = unstable.trayscale;
      prependExtraArgs = [ "--hide-window" ];
    })
  ];
}
