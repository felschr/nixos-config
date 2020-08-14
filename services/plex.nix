{ config, pkgs, ... }:

{
  services.plex.enable = true;
  services.plex.openFirewall = true;
  services.plex.user = "felschr";
}
