{ pkgs, ... }:

{
  home.packages = with pkgs; [
    signal-desktop
    (makeAutostartItem {
      name = "signal-desktop";
      package = signal-desktop;
      prependExtraArgs = [ "--start-in-tray" ];
    })
  ];
}
