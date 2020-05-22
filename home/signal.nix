{ config, pkgs, ... }:

let
  # TODO this doesn't affect the desktop file
  # e.g. when starting via GNOME the flag is not set
  signal-desktop = pkgs.runCommand "signal-desktop" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir $out
    ln -s ${pkgs.signal-desktop}/* $out
    rm $out/bin
    mkdir $out/bin
    ln -s ${pkgs.signal-desktop}/bin/* $out/bin
    rm $out/bin/signal-desktop
    makeWrapper ${pkgs.signal-desktop}/bin/signal-desktop $out/bin/signal-desktop \
      --add-flags "--use-tray-icon"
  '';
in
{
  home.packages = [ signal-desktop ];

  xdg.configFile."autostart/signal-desktop.desktop".text =
    builtins.replaceStrings
      ["bin/signal-desktop"] ["bin/signal-desktop --start-in-tray"]
      (builtins.readFile "${signal-desktop}/share/applications/signal-desktop.desktop");
}
