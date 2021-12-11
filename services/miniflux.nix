{ config, pkgs, ... }:

let port = 8002;
in {
  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/etc/nixos/secrets/miniflux";
    config = { LISTEN_ADDR = "localhost:${port}"; };
  };

  services.nginx = {
    virtualHosts."news.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:${port}";
    };
  };
}
