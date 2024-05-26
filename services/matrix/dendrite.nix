{ config, pkgs, ... }:

let
  server_name = "felschr.com";
  domain = "matrix.${server_name}";
  database = {
    connection_string = "postgresql:///dendrite?host=/run/postgresql";
    max_open_conns = 10;
    max_idle_conns = 2;
    conn_max_lifetime = -1;
  };
in
{
  age.secrets.dendrite-private-key = {
    file = ../../secrets/dendrite/privateKey.age;
    mode = "755";
  };
  age.secrets.dendrite-env = {
    file = ../../secrets/dendrite/.env.age;
    mode = "755";
  };

  services.dendrite = {
    enable = true;
    environmentFile = config.age.secrets.dendrite-env.path;
    settings = {
      app_service_api.database = database;
      federation_api.database = database;
      key_server.database = database;
      media_api.database = database;
      mscs.database = database;
      room_server.database = database;
      sync_api.database = database;
      user_api.account_database = database;

      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET";

      media_api.max_file_size_bytes = 10485760; # 10 MB

      mscs.mscs = [
        "msc2836" # threads
        "msc2946" # space summaries
      ];

      federation_api.key_perspectives = [
        {
          server_name = "matrix.org";
          keys = [
            {
              key_id = "ed25519:auto";
              public_key = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
            }
            {
              key_id = "ed25519:a_RXGa";
              public_key = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
            }
          ];
        }
      ];

      global = {
        inherit server_name;
        private_key = config.age.secrets.dendrite-private-key.path;
        jetstream.storage_path = "/var/lib/dendrite/jetstream";
        dns_cache = {
          enabled = true;
          cache_size = 4096;
          cache_lifetime = "600s";
        };
      };
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "dendrite";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "dendrite" ];
  };

  systemd.services.dendrite.after = [ "postgresql.service" ];

  services.nginx.virtualHosts = {
    ${server_name} = {
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
    "${domain}" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/".extraConfig = ''
          return 404;
        '';
        "/_matrix".proxyPass = "http://127.0.0.1:${toString config.services.dendrite.httpPort}";
      };
    };
  };

  environment.systemPackages = [
    # run like: dendrite-create-account --username --admin
    (pkgs.writeShellScriptBin "dendrite-create-account" ''
      ${pkgs.dendrite}/bin/create-account \
        --config /run/dendrite/dendrite.yaml \
        "$@"
    '')
  ];
}
