{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./fonts.nix ./sound.nix ./vpn.nix ];

  services.fwupd.enable = true;

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
}
