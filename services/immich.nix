{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/immich";
  typesenseDataDir = "/var/lib/typesense/data";
  uploadDir = "${dataDir}/upload";
  dbuser = "immich";
  dbname = "immich";
  dbPasswordFile = config.age.secrets.immich-db-password.path;
  ociBackend = config.virtualisation.oci-containers.backend;
  containersHost = "localhost";
  domain = "photos.felschr.com";

  pgSuperUser = config.services.postgresql.superUser;

  immichBase = {
    environment = {
      NODE_ENV = "production";
      DB_HOSTNAME = containersHost;
      DB_PORT = toString config.services.postgresql.port;
      DB_USERNAME = dbuser;
      DB_DATABASE_NAME = dbname;
      REDIS_HOSTNAME = containersHost;
      REDIS_PORT = toString config.services.redis.servers.immich.port;
    };
    # only secrets need to be included, e.g. DB_PASSWORD, JWT_SECRET, MAPBOX_KEY
    environmentFiles = [
      config.age.secrets.immich-env.path
      config.age.secrets.immich-typesense-env.path
    ];
    extraOptions = [
      "--network=host"
      "--add-host=immich-server:127.0.0.1"
      "--add-host=immich-microservices:127.0.0.1"
      "--add-host=immich-machine-learning:127.0.0.1"
      "--add-host=immich-web:127.0.0.1"
      "--add-host=typesense:127.0.0.1"
    ];
  };
in {
  age.secrets.immich-env.file = ../secrets/immich/.env.age;
  age.secrets.immich-db-password.file = ../secrets/immich/db-password.age;
  age.secrets.immich-typesense-env.file = ../secrets/immich/typesense/.env.age;

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [ dbname ];
    ensureUsers = [{
      name = dbuser;
      ensurePermissions."DATABASE ${dbname}" = "ALL PRIVILEGES";
    }];
  };

  services.redis.servers.immich = {
    enable = true;
    port = 31640;
  };

  systemd.services.immich-init = {
    enable = true;
    description = "Set up paths & database access";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    before = [
      "${ociBackend}-immich-server.service"
      "${ociBackend}-immich-microservices.service"
      "${ociBackend}-immich-machine-learning.service"
      "${ociBackend}-immich-web.service"
      "${ociBackend}-typesense.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = [ "db_password:${dbPasswordFile}" ];
    };
    script = ''
      mkdir -p ${dataDir} ${uploadDir} ${typesenseDataDir}
      echo "Set immich postgres user password"
      db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
      ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} ${pkgs.postgresql}/bin/psql postgres \
        -c "alter user ${dbuser} with password '$db_password'"
    '';
  };

  virtualisation.oci-containers.containers = {
    immich-server = immichBase // {
      image = "ghcr.io/immich-app/immich-server:release";
      ports = [ "3001:3001" ];
      entrypoint = "/bin/sh";
      cmd = [ "./start-server.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
      dependsOn = [ "typesense" ];
    };

    immich-microservices = immichBase // {
      image = "ghcr.io/immich-app/immich-server:release";
      entrypoint = "/bin/sh";
      cmd = [ "./start-microservices.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
      dependsOn = [ "typesense" ];
    };

    immich-machine-learning = immichBase // {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
    };

    immich-web = immichBase // {
      image = "ghcr.io/immich-app/immich-web:release";
      ports = [ "3000:3000" ];
      entrypoint = "/bin/sh";
      cmd = [ "./entrypoint.sh" ];
    };

    typesense = {
      image = "typesense/typesense:0.24.0";
      environment.TYPESENSE_DATA_DIR = "/data";
      environmentFiles = [ config.age.secrets.immich-typesense-env.path ];
      volumes = [ "${typesenseDataDir}:/data" ];
      extraOptions = [ "--network=host" ];
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
