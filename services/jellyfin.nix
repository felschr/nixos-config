{ config, pkgs, ... }:

{
  users.groups.media = { };

  services.jellyfin.enable = true;
  services.jellyfin.group = "media";
  services.jellyfin.openFirewall = true;

  # for hardware acceleration
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  services.nginx = {
    virtualHosts."media.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8096";
    };
  };
}
