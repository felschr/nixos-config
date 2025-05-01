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

  services.nginx.virtualHosts."office.felschr.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString cfg.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_read_timeout 36000s;
      '';
    };
  };
}
