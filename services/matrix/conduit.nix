{ config, pkgs, ... }:

let
  server_name = "felschr.com";
  domain = "matrix.${server_name}";
in
{
  services.matrix-conduit = {
    enable = true;
    package = pkgs.unstable.matrix-conduit;
    settings.global = {
      inherit server_name;
      database_backend = "rocksdb";
      trusted_servers = [
        "matrix.org"
        "libera.chat"
        "nixos.org"
      ];
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/_matrix/" = {
      proxyPass = "http://[::1]:${toString config.services.matrix-conduit.settings.global.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };

  services.nginx.virtualHosts.${server_name} = {
    enableACME = true;
    forceSSL = true;
    locations =
      let
        server = {
          "m.server" = "${domain}:443";
        };
        client = {
          "m.homeserver"."base_url" = "https://${domain}";
          "org.matrix.msc3575.proxy"."url" = "https://${domain}";
          "m.identity_server"."base_url" = "https://vector.im";
        };
      in
      {
        "= /.well-known/matrix/server".extraConfig = ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';
        "= /.well-known/matrix/client".extraConfig = ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '${builtins.toJSON client}';
        '';
      };
  };
}
