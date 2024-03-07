{ config, ... }:

let
  inherit (config.users.users.collabora-office) uid;
  inherit (config.users.groups.collabora-office) gid;
in {
  virtualisation.oci-containers.containers.collabora-office = {
    image = "docker.io/collabora/code";
    ports = [ "9980:9980" ];
    environment = let
      mkAlias = domain:
        "https://" + (builtins.replaceStrings [ "." ] [ "\\." ] domain)
        + ":443";
    in {
      server_name = "office.felschr.com";
      aliasgroup1 = mkAlias "office.felschr.com";
      aliasgroup2 = mkAlias "cloud.felschr.com";
      extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
    };
    extraOptions = [
      "--runtime=crun"
      "--uidmap=0:65534:1"
      "--gidmap=0:65534:1"
      "--uidmap=100:${toString uid}:1"
      "--gidmap=101:${toString gid}:1"
      "--network=host"
      "--cap-add=MKNOD"
      "--cap-add=CHOWN"
      "--cap-add=FOWNER"
      "--cap-add=SYS_CHROOT"
      "--label=io.containers.autoupdate=registry"
    ];
  };

  services.nginx.virtualHosts."office.felschr.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9980";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_read_timeout 36000s;
      '';
    };
  };

  users.users.collabora-office = {
    isSystemUser = true;
    group = "collabora-office";
    uid = 982;
  };

  users.groups.collabora-office = { gid = 982; };
}
