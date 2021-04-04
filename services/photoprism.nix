{ pkgs, config, ... }:

{
  environment.systemPackages = [ pkgs.photoprism ];

  services.nginx = {
    enable = true;
    virtualHosts."photos.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.photoprism.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 100M;
          proxy_read_timeout 300s;
        '';
      };
    };
  };

  services.photoprism.enable = true;
}
