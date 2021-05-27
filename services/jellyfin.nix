{ config, pkgs, ... }:

let user = "felschr";
in {
  services.jellyfin.enable = true;
  services.jellyfin.user = user;
  services.jellyfin.openFirewall = true;

  # for hardware acceleration
  users.users."${user}".extraGroups = [ "video" "render" ];

  services.nginx = {
    virtualHosts."jellyfin.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8096";
    };
  };
}
