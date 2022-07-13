{ config, pkgs, ... }:

let port = 8088;
in {
  services.calibre-web = {
    enable = true;
    group = "media";
    listen.ip = "::1";
    listen.port = port;
    options.enableBookUploading = true;
    options.enableBookConversion = true;
    options.calibreLibrary = "/media/Books";
  };

  services.nginx = {
    virtualHosts."books.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}";
        extraConfig = ''
          client_max_body_size 500M;
        '';
      };
    };
  };
}
