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
    listeners = [{
      port = port;
      users = {
        "hass" = {
          acl = [ "readwrite homeassistant/#" "readwrite tasmota/#" ];
          hashedPasswordFile = config.age.secrets.mqtt-hass.path;
        };
        "tasmota" = {
          acl = [ "readwrite tasmota/#" "readwrite homeassistant/#" ];
          hashedPasswordFile = config.age.secrets.mqtt-tasmota.path;
        };
      };
    }];
  };
}
