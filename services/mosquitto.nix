{ config, pkgs, ... }:

with pkgs;

let
  port = 1883;
  wsPort = 9001;
in {
  services.nginx = {
    virtualHosts."mqtt.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString wsPort}";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = port;
        users = {
          "hass" = {
            acl = [
              "readwrite homeassistant/#"
              "readwrite tasmota/#"
              "readwrite owntracks/#"
            ];
            hashedPasswordFile = config.age.secrets.mqtt-hass.path;
          };
          "tasmota" = {
            acl = [ "readwrite tasmota/#" "readwrite homeassistant/#" ];
            hashedPasswordFile = config.age.secrets.mqtt-tasmota.path;
          };
          "owntracks" = {
            acl = [ "readwrite owntracks/#" ];
            hashedPasswordFile = config.age.secrets.mqtt-owntracks.path;
          };
        };
      }
      {
        port = wsPort;
        settings.protocol = "websockets";
        users = {
          "felix" = {
            acl = [ "read owntracks/#" "readwrite owntracks/felix/#" ];
            hashedPasswordFile = config.age.secrets.mqtt-felix.path;
          };
          "birgit" = {
            acl = [ "read owntracks/#" "readwrite owntracks/birgit/#" ];
            hashedPasswordFile = config.age.secrets.mqtt-birgit.path;
          };
        };
      }
    ];
  };
}
