{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ signal-desktop ];

  xdg.configFile."autostart/signal-desktop.desktop".text =
    builtins.replaceStrings [ "bin/signal-desktop" ] [ "bin/signal-desktop --start-in-tray" ]
      (builtins.readFile "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop");
}
