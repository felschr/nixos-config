{ config, pkgs, ... }:

{
  # Direct mode
  services.nginx.virtualHosts."felschr.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/.well-known/openpgpkey/" = {
      recommendedProxySettings = false;
      proxyPass = "https://openpgpkey.protonmail.ch";
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*' always;
        proxy_set_header Host $proxy_host;
        rewrite /.well-known/openpgpkey/(.*) /.well-known/openpgpkey/$host/$1 break;
      '';
    };
  };

  # Advanced mode
  services.nginx.virtualHosts."openpgpkey.felschr.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/.well-known/openpgpkey/felschr.com/" = {
      recommendedProxySettings = false;
      proxyPass = "https://openpgpkey.protonmail.ch";
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*' always;
        proxy_set_header Host $proxy_host;
      '';
    };
  };
}
