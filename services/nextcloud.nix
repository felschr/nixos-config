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

  # Office
  # TODO move to own config
  virtualisation.oci-containers.containers.collabora-office = {
    image = "collabora/code";
    ports = [ "9980:9980" ];
    environment = {
      domain = builtins.replaceStrings [ "." ] [ "\\." ] "office.felschr.com";
      extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
    };
    extraOptions = [ "--network=host" ];
  };
  services.nginx.virtualHosts."office.felschr.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:9980";
      proxyWebsockets = true;
    };
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
