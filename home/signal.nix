{ pkgs, ... }:

{
  home.packages = with pkgs; [
    signal-desktop
    (makeAutostartItem {
      name = "signal";
      package = signal-desktop;
      prependExtraArgs = [ "--start-in-tray" ];
    })
  ];
}
