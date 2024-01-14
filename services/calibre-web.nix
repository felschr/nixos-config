{ config, pkgs, ... }:

let port = 8088;
in {
  age.secrets.calibre-web-htpasswd = {
    file = ../secrets/calibre-web/htpasswd.age;
    owner = config.services.nginx.user;
  };

  services.calibre-web = {
    enable = true;
    group = "media";
    listen.ip = "::1";
    listen.port = port;
    options.enableBookUploading = true;
    options.enableBookConversion = true;
    options.enableKepubify = true;
    options.calibreLibrary = "/media/Books";
  };

  services.nginx = {
    virtualHosts."books.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://[::1]:${toString port}";
          extraConfig = ''
            client_max_body_size 500M;
            proxy_busy_buffers_size 1024k;
            proxy_buffers 4 512k;
            proxy_buffer_size 1024k;
          '';
        };
        "/opds" = {
          proxyPass = "http://[::1]:${toString port}";
          basicAuthFile = config.age.secrets.calibre-web-htpasswd.path;
        };
      };
    };
  };
}
