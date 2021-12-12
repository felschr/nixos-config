{ config, pkgs, ... }:

with pkgs;

let
  host = "mqtt.felschr.com";
  port = 1883;
  wsPort = 9001;
in {
  services.nginx = {
    virtualHosts."${mqttHost}" = {
      serverAliases = [ "mqtt.home.felschr.com" ];
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
            hashedPasswordFile = "/etc/nixos/secrets/mqtt/hass";
          };
          "tasmota" = {
            acl = [ "readwrite tasmota/#" "readwrite homeassistant/#" ];
            hashedPasswordFile = "/etc/nixos/secrets/mqtt/tasmota";
          };
          "owntracks" = {
            acl = [ "readwrite owntracks/#" ];
            hashedPasswordFile = "/etc/nixos/secrets/mqtt/owntracks";
          };
        };
      }
      {
        port = wsPort;
        settings.protocol = "websockets";
        users = {
          "felix" = {
            acl = [ "read owntracks/#" "readwrite owntracks/felix/#" ];
            hashedPasswordFile = "/etc/nixos/secrets/mqtt/felix";
          };
          "birgit" = {
            acl = [ "read owntracks/#" "readwrite owntracks/birgit/#" ];
            hashedPasswordFile = "/etc/nixos/secrets/mqtt/birgit";
          };
        };
      }
    ];
  };
}
