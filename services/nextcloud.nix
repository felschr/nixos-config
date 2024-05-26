{ config, pkgs, ... }:

let
  host = "cloud.felschr.com";
in
{
  age.secrets.nextcloud-admin = {
    file = ../secrets/nextcloud/admin.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = host;
    https = true;
    maxUploadSize = "10G";
    config = {
      adminuser = "admin";
      adminpassFile = config.age.secrets.nextcloud-admin.path;
      dbtype = "pgsql";
      dbhost = "/run/postgresql";
    };
    autoUpdateApps.enable = true;
  };

  services.nginx.virtualHosts.${host} = {
    forceSSL = true;
    enableACME = true;
  };

  services.postgresql = with config.services.nextcloud.config; {
    enable = true;
    ensureDatabases = [ dbname ];
    ensureUsers = [
      {
        name = dbuser;
        ensureDBOwnership = true;
      }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
