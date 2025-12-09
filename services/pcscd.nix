{ config, pkgs, ... }:

{
  # for reader used with ausweisapp
  services.pcscd.enable = true;
  services.pcscd.plugins = with pkgs; [
    ccid
    pcsc-cyberjack
  ];
}
