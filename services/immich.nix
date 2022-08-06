{ config, lib, pkgs, ... }:

let
  uploadDir = "/var/lib/immich/upload";
  dbuser = "immich";
  dbname = "immich";
  ociBackend = config.virtualisation.oci-containers.backend;
  containersHost = if ociBackend == "podman" then
    "host.containers.internal"
  else
    "host.docker.internal";
  domain = "photos.felschr.com";

  immichEnv = {
    environment = {
      NODE_ENV = "production";
      DB_HOSTNAME = containersHost;
      DB_PORT = toString config.services.postgresql.port;
      DB_USERNAME = dbuser;
      DB_DATABASE_NAME = dbname;
      REDIS_HOSTNAME = containersHost;
      REDIS_PORT = toString config.services.redis.servers.immich.port;
      VITE_SERVER_ENDPOINT = "https://${domain}/api";

      # immich requires this value, even though we don't have password auth
      DB_PASSWORD = "x";
    };
    # only secrets need to be included, e.g. JWT_SECRET, MAPBOX_KEY
    environmentFiles = [ config.age.secrets.immich-env.path ];
  };
in {
  age.secrets.immich-env.file = ../secrets/immich/.env.age;

  services.postgresql = {
    enable = true;
    ensureDatabases = [ dbname ];
    ensureUsers = [{
      name = dbuser;
      ensurePermissions."DATABASE ${dbname}" = "ALL PRIVILEGES";
    }];
  };

  services.redis.servers.immich.enable = true;

  systemd.services.prepare-immich = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p ${uploadDir}
    '';
    before = [
      "${ociBackend}-immich-server.service"
      "${ociBackend}-immich-microservices.service"
      "${ociBackend}-immich-machine-learning.service"
      "${ociBackend}-immich-web.service"
      "${ociBackend}-immich-proxy.service"
    ];
  };

  virtualisation.oci-containers.containers = {
    immich-server = immichEnv // {
      image = "altran1502/immich-server:release";
      entrypoint = "/bin/sh";
      cmd = [ "./start-server.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
    };

    immich-microservices = immichEnv // {
      image = "altran1502/immich-server:release";
      entrypoint = "/bin/sh";
      cmd = [ "./start-microservices.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
    };

    immich-machine-learning = immichEnv // {
      image = "altran1502/immich-machine-learning:release";
      entrypoint = "/bin/sh";
      cmd = [ "./entrypoint.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
    };

    immich-web = immichEnv // {
      image = "altran1502/immich-web:release";
      entrypoint = "/bin/sh";
      cmd = [ "./entrypoint.sh" ];
    };
  };

  systemd.services = {
    "${ociBackend}-immich-server" = {
      requires = [ "postgresql.service" "redis-immich.service" ];
      after = [ "postgresql.service" "redis-immich.service" ];
    };

    "${ociBackend}-immich-microservices" = {
      requires = [ "postgresql.service" "redis-immich.service" ];
      after = [ "postgresql.service" "redis-immich.service" ];
    };

    "${ociBackend}-immich-machine-learning" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/api" = {
      proxyPass = "http://localhost:3001";
      extraConfig = ''
        rewrite /api/(.*) /$1 break;
        client_max_body_size 50000M;
      '';
    };
    locations."/" = {
      proxyPass = "http://localhost:3000";
      extraConfig = ''
        client_max_body_size 50000M;
      '';
    };
  };
}
