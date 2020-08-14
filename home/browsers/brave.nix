{ config, pkgs, ... }:

let
  brave-wrapped = with pkgs; pkgs.runCommand "brave" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir $out
    ln -s ${brave}/* $out
    rm $out/bin
    mkdir $out/bin
    ln -s ${brave}/bin/* $out/bin
    rm $out/bin/brave
    makeWrapper ${brave}/bin/brave $out/bin/brave \
      --add-flags "--ignore-gpu-blacklist"
  '';
in
{
  home.packages = with pkgs; [
    brave-wrapped
  ];
}
