{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/focalboard";
  ociBackend = config.virtualisation.oci-containers.backend;
  containersHost = "localhost";
  port = 8003;
  domain = "boards.felschr.com";
  dbHost = containersHost;
  dbPort = toString config.services.postgresql.port;
  dbUser = "focalboard";
  dbName = "focalboard";
  dbPasswordFile = config.age.secrets.focalboard-db-password.path;

  pgSuperUser = config.services.postgresql.superUser;
in {
  age.secrets.focalboard-env.file = ../secrets/focalboard/.env.age;
  age.secrets.focalboard-db-password.file =
    ../secrets/focalboard/db-password.age;

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [ dbName ];
    ensureUsers = [{
      name = dbUser;
      ensurePermissions."DATABASE ${dbName}" = "ALL PRIVILEGES";
    }];
  };

  systemd.services.focalboard-init = {
    enable = true;
    description = "Set up paths & database access for Focalboard";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    before = [ "${ociBackend}-focalboard.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = [ "db_password:${dbPasswordFile}" ];
    };
    script = ''
      mkdir -p ${dataDir}
      echo "Set focalboard postgres user password"
      db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
      ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} ${pkgs.postgresql}/bin/psql postgres \
        -c "alter user ${dbUser} with password '$db_password'"
    '';
  };

  virtualisation.oci-containers.containers.focalboard = {
    image = "mattermost/focalboard";
    ports = [ "${toString port}:${toString port}" ];
    volumes = [ "${dataDir}:/var/lib/focalboard" ];
    environment = {
      FOCALBOARD_PORT = toString port;
      FOCALBOARD_DBTYPE = "postgres";
    };
    # only secrets need to be included, e.g. FOCALBOARD_DBCONFIG
    environmentFiles = [ config.age.secrets.focalboard-env.path ];
    extraOptions = [ "--network=host" ];
  };

  systemd.services."${ociBackend}-focalboard" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
}
