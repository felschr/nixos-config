_:

{
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
      "--network=host"
      "--cap-add=MKNOD"
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
}
