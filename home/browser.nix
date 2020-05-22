{ config, pkgs, ... }:

let
  brave = pkgs.runCommand "brave" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir $out
    ln -s ${pkgs.brave}/* $out
    rm $out/bin
    mkdir $out/bin
    ln -s ${pkgs.brave}/bin/* $out/bin
    rm $out/bin/brave
    makeWrapper ${pkgs.brave}/bin/brave $out/bin/brave \
      --add-flags "--ignore-gpu-blacklist"
  '';
in
{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableVaapi = true; # NVIDIA also requires vdpau backend
      commandLineArgs = "--force-dark-mode";
    };
  };

  home.packages = with pkgs; [
    brave
  ];
}
