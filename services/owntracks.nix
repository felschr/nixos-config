{ config, pkgs, ... }:

let
  frontend-config = builtins.toFile "owntracks-frontend-config.js" ''
    window.owntracks = window.owntracks || {};
    window.owntracks.config = {};
  '';
in {
  age.secrets.owntracks-recorder-env.file =
    ../secrets/owntracks/recorder.env.age;
  age.secrets.owntracks-htpasswd.file = ../secrets/owntracks/htpasswd.age;

  virtualisation.oci-containers.containers = {
    owntracks-recorder = {
      image = "owntracks/recorder";
      ports = [ "8083:8083" ];
      environment = {
        OTR_HOST = "localhost";
        OTR_PORT = "1883";
        OTR_USER = "owntracks";
      };
      # provide OTR_PASS
      environmentFiles = [ config.age.secrets.owntracks-recorder-env.path ];
      volumes = [ "/var/lib/owntracks/recorder/store:/store" ];
      extraOptions = [ "--network=host" ];
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
