{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./fonts.nix ./sound.nix ./vpn.nix ];

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
}
