{ config, pkgs, ... }:

let port = 28981;
in {
  age.secrets.paperless = {
    file = ../secrets/paperless.age;
    owner = config.services.paperless.user;
    group = config.services.paperless.user;
  };

  /* services.paperless = {
     enable = true;
     inherit port;
     passwordFile = config.age.secrets.paperless.path;
     extraConfig = {
     PAPERLESS_ADMIN_USER = "felschr";
     PAPERLESS_OCR_LANGUAGE = "deu+eng";
     };
     };

     services.nginx = {
     virtualHosts."paperless.felschr.com" = {
     enableACME = true;
     forceSSL = true;
     locations."/" = {
     proxyPass = "http://localhost:${toString port}";
     proxyWebsockets = true;
     };
     };
     };
  */
}
