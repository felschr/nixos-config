{ config, pkgs, ... }:

{
  # for reader used with AusweisApp2
  services.pcscd.enable = true;
  services.pcscd.plugins = with pkgs; [
    ccid
    pcsc-cyberjack
  ];
}
