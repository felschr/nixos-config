{ config, pkgs, ... }:

let port = 8002;
in {
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux.path;
    config = { LISTEN_ADDR = "localhost:${toString port}"; };
  };

  services.nginx = {
    virtualHosts."news.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:${toString port}";
    };
  };
}
