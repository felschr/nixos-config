{ config, ... }:

let
  cfg = config.services.collabora-online;
in
{
  services.collabora-online = {
    enable = true;
    aliasGroups = [
      {
        host = "https://office.felschr.com";
        aliases = [ "https://cloud.felschr.com" ];
      }
    ];
    settings = {
      ssl = {
        enable = false;
        termination = true;
      };
    };
  };

  services.caddy.virtualHosts."office.felschr.com" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy 127.0.0.1:${toString cfg.port} {
        flush_interval -1
      }
    '';
  };
}
