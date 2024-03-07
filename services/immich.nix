{ config, pkgs, ... }:

let
  tag = "v1.88.2";
  dataDir = "/var/lib/immich";
  typesenseDataDir = "/var/lib/immich/typesense/data";
  uploadDir = "${dataDir}/upload";
  dbuser = "immich";
  dbname = "immich";
  dbPasswordFile = config.age.secrets.immich-db-password.path;
  ociBackend = config.virtualisation.oci-containers.backend;
  containersHost = "localhost";
  domain = "photos.felschr.com";

  inherit (config.users.users.immich) uid;
  inherit (config.users.groups.immich) gid;

  pgSuperUser = config.services.postgresql.superUser;

  immichBase = {
    user = "${toString uid}:${toString gid}";
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      NODE_ENV = "production";
      DB_HOSTNAME = containersHost;
      DB_PORT = toString config.services.postgresql.port;
      DB_USERNAME = dbuser;
      DB_DATABASE_NAME = dbname;
      REDIS_HOSTNAME = containersHost;
      REDIS_PORT = toString config.services.redis.servers.immich.port;
      TYPESENSE_HOST = "immich-typesense";
    };
    # only secrets need to be included, e.g. DB_PASSWORD, JWT_SECRET, MAPBOX_KEY
    environmentFiles = [
      config.age.secrets.immich-env.path
      config.age.secrets.immich-typesense-env.path
    ];
    extraOptions = [
      "--runtime-flag=directfs=false"
      "--runtime-flag=network=host"
      "--uidmap=0:65534:1"
      "--gidmap=0:65534:1"
      "--uidmap=${toString uid}:${toString uid}:1"
      "--gidmap=${toString gid}:${toString gid}:1"
      "--network=host"
      "--add-host=immich-server:127.0.0.1"
      "--add-host=immich-microservices:127.0.0.1"
      "--add-host=immich-machine-learning:127.0.0.1"
      "--add-host=immich-typesense:127.0.0.1"
      "--label=io.containers.autoupdate=registry"
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
      "${ociBackend}-immich-typesense.service"
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
      image = "ghcr.io/immich-app/immich-server:${tag}";
      ports = [ "3001:3001" ];
      entrypoint = "/bin/sh";
      cmd = [ "./start-server.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
      dependsOn = [ "immich-typesense" ];
    };

    immich-microservices = immichBase // {
      image = "ghcr.io/immich-app/immich-server:${tag}";
      entrypoint = "/bin/sh";
      cmd = [ "./start-microservices.sh" ];
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
      dependsOn = [ "immich-typesense" ];
    };

    immich-machine-learning = immichBase // {
      image = "ghcr.io/immich-app/immich-machine-learning:${tag}";
      volumes = [ "${uploadDir}:/usr/src/app/upload" ];
    };

    immich-typesense = {
      image = "docker.io/typesense/typesense:0.24.0";
      environment.TYPESENSE_DATA_DIR = "/data";
      environmentFiles = [ config.age.secrets.immich-typesense-env.path ];
      volumes = [ "${typesenseDataDir}:/data" ];
      extraOptions = [
        "--uidmap=0:${toString uid}:1"
        "--gidmap=0:${toString gid}:1"
        "--network=host"
        "--label=io.containers.autoupdate=registry"
      ];
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
    locations."/" = {
      proxyPass = "http://localhost:3001";
      extraConfig = ''
        client_max_body_size 50000M;
      '';
    };
  };

  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    uid = 980;
  };

  users.groups.immich = { gid = 977; };
}
