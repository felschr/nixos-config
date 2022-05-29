{ config, pkgs, ... }:

let port = 8088;
in {
  services.calibre-web = {
    enable = true;
    listen.port = port;
    options.calibreLibrary = "/media/Books";
  };

  services.nginx = {
    virtualHosts."books.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:${toString port}";
    };
  };
}
