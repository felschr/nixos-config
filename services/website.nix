{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."felschr.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "https://felschr.gitlab.io";
  };
}
