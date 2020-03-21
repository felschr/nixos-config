{ config, pkgs, ... }:

let
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
}
