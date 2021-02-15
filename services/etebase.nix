{ config, pkgs, ... }:

let
  etebaseHost = "etebase.felschr.com";
in
{
  services.etebase-server.enable = true;
  services.etebase-server.host = etebaseHost;
  services.etebase-server.openFirewall = true;
  services.etebase-server.secretFile = "/etc/nixos/secrets/etebase-server";

  services.nginx = {
    virtualHosts."${etebaseHost}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8001";
    };
  };
}
