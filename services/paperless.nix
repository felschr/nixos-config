{ config, pkgs, ... }:

let port = 28981;
in {
  services.paperless-ng = {
    enable = true;
    inherit port;
    passwordFile = "/etc/nixos/secrets/paperless";
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
}
