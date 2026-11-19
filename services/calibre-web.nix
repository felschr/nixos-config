{ config, pkgs, ... }:

let
  port = 8088;
in
{
  age.secrets.calibre-web-htpasswd.file = ../secrets/calibre-web/htpasswd.age;

  # Caddy's basic_auth needs the htpasswd line split into user and hash,
  # so generate an environment file for `services.caddy.environmentFile`.
  systemd.services.caddy-environment = {
    before = [ "caddy.service" ];
    wantedBy = [ "caddy.service" ];
    serviceConfig = {
      Type = "oneshot";
      Umask = "0077";
    };
    script = ''
      printf 'CALIBRE_OPDS_USER=%s\nCALIBRE_OPDS_HASH=%s\n' \
        "$(cut -d: -f1 ${config.age.secrets.calibre-web-htpasswd.path})" \
        "$(cut -d: -f2- ${config.age.secrets.calibre-web-htpasswd.path})" \
        > /run/caddy.env
    '';
  };

  services.caddy.environmentFile = "/run/caddy.env";

  services.calibre-web = {
    enable = true;
    package = pkgs.unstable.calibre-web.overridePythonAttrs (old: {
      dependencies = old.dependencies ++ old.optional-dependencies.kobo;
    });
    group = "media";
    listen.ip = "::1";
    listen.port = port;
    options.enableBookUploading = true;
    options.enableBookConversion = true;
    options.enableKepubify = true;
    options.calibreLibrary = "/media/Books";
  };

  services.caddy.virtualHosts."books.felschr.com" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      handle /opds/* {
        basic_auth {
          {$CALIBRE_OPDS_USER} {$CALIBRE_OPDS_HASH}
        }
        reverse_proxy [::1]:${toString port}
      }
      handle {
        reverse_proxy [::1]:${toString port}
      }
    '';
  };
}
