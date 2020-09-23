{ config, pkgs, ... }:

with pkgs;
let
  signal-desktop =
    runCommand "signal-desktop" { buildInputs = [ makeWrapper ]; } ''
      mkdir $out
      ln -s ${pkgs.signal-desktop}/* $out
      rm $out/bin
      makeWrapper ${pkgs.signal-desktop}/bin/signal-desktop $out/bin/signal-desktop \
        --add-flags "--use-tray-icon"
    '';
in {
  home.packages = [ signal-desktop ];

  # TODO switch to overwritten `signal-desktop` when
  # desktop file is updated with correct exec path
  xdg.configFile."autostart/signal-desktop.desktop".text =
    builtins.replaceStrings [ "bin/signal-desktop" ]
    [ "bin/signal-desktop --start-in-tray" ] (builtins.readFile
      "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop");
}
