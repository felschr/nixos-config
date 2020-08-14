{ config, pkgs, ... }:

{
  services.jellyfin.enable = true;
  services.jellyfin.user = "felschr";
  networking.firewall.allowedTCPPorts = [ 8920 8096 1900 7359 ];
}
