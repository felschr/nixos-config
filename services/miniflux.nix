{ config, ... }:

let
  domain = "news.felschr.com";
  port = 8002;
in {
  age.secrets.miniflux.file = ../secrets/miniflux.age;

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux.path;
    config = {
      LISTEN_ADDR = "localhost:${toString port}";
      BASE_URL = "https://${domain}";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "miniflux";
      OAUTH2_CLIENT_SECRET_FILE =
        config.age.secrets.authelia-oidc-miniflux.path;
      OAUTH2_REDIRECT_URL = "https://news.felschr.com/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.felschr.com";
      OAUTH2_USER_CREATION = "1";
    };
  };

  services.nginx = {
    virtualHosts."news.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:${toString port}";
    };
  };
}
