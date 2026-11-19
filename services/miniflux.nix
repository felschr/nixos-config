{ config, ... }:

let
  domain = "news.felschr.com";
  port = 8002;
in
{
  age.secrets.miniflux.file = ../secrets/miniflux/admin.age;
  age.secrets.miniflux-oidc = {
    file = ../secrets/miniflux/oidc.age;
    group = "miniflux-secrets";
    mode = "440";
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux.path;
    config = {
      LISTEN_ADDR = "localhost:${toString port}";
      BASE_URL = "https://${domain}";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "miniflux";
      OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux-oidc.path;
      OAUTH2_REDIRECT_URL = "https://news.felschr.com/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.felschr.com";
      OAUTH2_USER_CREATION = "1";
    };
  };

  systemd.services.miniflux.serviceConfig.SupplementaryGroups = [ "miniflux-secrets" ];

  services.caddy.virtualHosts."news.felschr.com" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  users.groups.miniflux-secrets = { };
}
