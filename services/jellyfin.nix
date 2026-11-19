{ config, lib, ... }:

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

  services.caddy.virtualHosts = {
    "media.felschr.com" = {
      extraConfig = ''
        encode zstd gzip
        header Strict-Transport-Security "max-age=31536000; includeSubDomains"
        reverse_proxy 127.0.0.1:8096
      '';
    };
  };
}
