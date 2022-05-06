{ config, pkgs, ... }:

let etebaseHost = "etebase.felschr.com";
in {
  age.secrets.etebase-server = {
    file = ../secrets/etebase-server.age;
    owner = config.services.etebase-server.user;
    group = config.services.etebase-server.user;
  };

  services.etebase-server.enable = true;
  services.etebase-server.openFirewall = true;
  services.etebase-server.settings = {
    global = { secret_file = config.age.secrets.etebase-server.path; };
    allowed_hosts = { allowed_host1 = etebaseHost; };
  };

  services.nginx = {
    virtualHosts."${etebaseHost}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8001";
    };
  };
}
