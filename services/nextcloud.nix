{ config, pkgs, ... }:

let host = "cloud.felschr.com";
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud23;
    hostName = host;
    https = true;
    maxUploadSize = "10G";
    config = {
      adminuser = "admin";
      adminpassFile = "/etc/nixos/secrets/nextcloud/admin";
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
    ensureUsers = [{
      name = dbuser;
      ensurePermissions."DATABASE ${dbname}" = "ALL PRIVILEGES";
    }];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
