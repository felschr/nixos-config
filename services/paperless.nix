{ config, pkgs, ... }:

let
  port = 28981;
in
{
  age.secrets.paperless = {
    file = ../secrets/paperless.age;
    owner = config.services.paperless.user;
    group = config.services.paperless.user;
  };

  services.paperless = {
    enable = true;
    inherit port;
    passwordFile = config.age.secrets.paperless.path;
    settings = {
      PAPERLESS_ADMIN_USER = "felschr";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };

  services.caddy.virtualHosts."paperless.felschr.com" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
