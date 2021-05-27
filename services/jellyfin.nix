{ config, pkgs, ... }:

{
  services.jellyfin.enable = true;
  services.jellyfin.user = "felschr";
  services.jellyfin.openFirewall = true;

  # for hardware acceleration
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  services.nginx = {
    virtualHosts."jellyfin.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8096";
    };
  };
}
