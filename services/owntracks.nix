{ config, pkgs, ... }:

let
  frontend-config = builtins.toFile "owntracks-frontend-config.js" ''
    window.owntracks = window.owntracks || {};
    window.owntracks.config = {};
  '';
in {
  age.secrets.owntracks-htpasswd.file = ../secrets/owntracks/htpasswd.age;

  virtualisation.oci-containers.containers = {
    owntracks-recorder = {
      # official image does not support aarch64
      # image = "owntracks/recorder";
      image = "easypi/ot-recorder-arm";
      ports = [ "8083:8083" ];
      environment = {
        OTR_HOST = "localhost";
        OTR_PORT = "1883";
        OTR_USER = "owntracks";
        OTR_PASS = ""; # TODO
      };
      # easypi/ot-recorder-arm uses different store location
      # volumes = [ "/var/lib/owntracks/recorder/store:/store" ];
      volumes = [
        "/var/lib/owntracks/recorder/store:/var/spool/owntracks/recorder/store"
      ];
      extraOptions = [
        # TODO systemd doesn't substitute variables because it doesn't run in a shell
        # "-e OTR_PASS=\"$(cat ${config.age.secrets.mqtt-owntracks-plain.path})\""
        "--network=host"
      ];
    };

    owntracks-frontend = {
      image = "owntracks/frontend";
      ports = [ "8085:8085" ];
      environment = {
        SERVER_HOST = "localhost";
        SERVER_PORT = "8083";
        LISTEN_PORT = "8085";
      };
      volumes = [ "${frontend-config}:/usr/share/nginx/html/config/config.js" ];
      extraOptions = [ "--network=host" ];
    };
  };

  services = {
    nginx = {
      virtualHosts."owntracks.felschr.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:8085";
        basicAuthFile = config.age.secrets.owntracks-htpasswd.path;
      };
    };
  };

}
