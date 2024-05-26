{ config, lib, pkgs, ... }:

{
  services.jellyfin.enable = true;
  services.jellyfin.group = "media";
  services.jellyfin.openFirewall = true;

  # for hardware acceleration
  users.users.${config.services.jellyfin.user}.extraGroups = [
    "video"
    "render"
  ];
  systemd.services.jellyfin.serviceConfig = {
    DeviceAllow = lib.mkForce [ "/dev/dri/renderD128" ];
  };

  services.nginx.virtualHosts = {
    "media.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8096";
    };
  };
}
