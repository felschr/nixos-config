{ config, pkgs, ... }:

let
  etebaseHost = "etebase.felschr.com";
in
{
  # TODO etebase-server doesn't support newer django version yet
  nixpkgs.config.permittedInsecurePackages = [ "python3.11-django-3.2.25" ];

  age.secrets.etebase-server = {
    file = ../secrets/etebase-server.age;
    owner = config.services.etebase-server.user;
    group = config.services.etebase-server.user;
  };

  services.etebase-server.enable = true;
  services.etebase-server.openFirewall = true;
  services.etebase-server.settings = {
    global = {
      secret_file = config.age.secrets.etebase-server.path;
    };
    allowed_hosts = {
      allowed_host1 = etebaseHost;
    };
  };

  services.caddy.virtualHosts."${etebaseHost}" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy 127.0.0.1:8001
    '';
  };
}
