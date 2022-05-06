{ config, pkgs, ... }:

with pkgs;

let
  port = 1883;
  wsPort = 9001;

  mkSecret = file: {
    inherit file;
    owner = "mosquitto";
  };
in {
  age.secrets = {
    mqtt-felix = mkSecret ../secrets/mqtt/felix.age;
    mqtt-birgit = mkSecret ../secrets/mqtt/birgit.age;
    mqtt-hass = mkSecret ../secrets/mqtt/hass.age;
    mqtt-tasmota = mkSecret ../secrets/mqtt/tasmota.age;
    mqtt-owntracks = mkSecret ../secrets/mqtt/owntracks.age;
    mqtt-owntracks-plain = mkSecret ../secrets/mqtt/owntracks-plain.age;
  };

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
