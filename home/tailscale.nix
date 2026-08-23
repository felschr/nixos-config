{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # https://github.com/lilyinstarlight/nixos-cosmic/pull/688
    # gui-scale-applet
    unstable.trayscale
    (makeAutostartItem {
      name = "dev.deedles.Trayscale";
      package = unstable.trayscale;
      prependExtraArgs = [ "--hide-window" ];
    })
  ];
}
