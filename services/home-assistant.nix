{ config, pkgs, ... }:

with pkgs;

let
  mqttDomain = "mqtt.${config.networking.domain}";
  mqttWSPort = "9001";
in {
  environment.systemPackages = with pkgs; [ deconz ];

  local.services.deconz = {
    enable = true;
    httpPort = 8080;
    wsPort = 1443;
    openFirewall = true;
  };

  services.nginx = {
    virtualHosts = {
      ${mqttDomain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${mqttWSPort}";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.mosquitto.port ];

  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    checkPasswords = true;
    extraConf = ''
      listener ${mqttWSPort}
      protocol websockets
    '';
    users = {
      "hass" = {
        acl = [
          "topic readwrite homeassistant/#"
          "topic readwrite tasmota/#"
          "topic readwrite owntracks/#"
        ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/hass";
      };
      "tasmota" = {
        acl = [ "topic readwrite tasmota/#" "topic readwrite homeassistant/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/tasmota";
      };
      "owntracks" = {
        acl = [ "topic readwrite owntracks/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/owntracks";
      };
      "felix" = {
        acl = [ "topic read owntracks/#" "topic readwrite owntracks/felix/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/felix";
      };
      "birgit" = {
        acl = [ "topic read owntracks/#" "topic readwrite owntracks/birgit/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/birgit";
      };
    };
  };

  services.home-assistant = {
    enable = true;
    package = home-assistant.override {
      extraPackages = ps: with ps; [ (callPackage pydeconz { }) ];
    };
    openFirewall = true;
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 0;
        unit_system = "metric";
        temperature_unit = "C";
        external_url = "https://home.felschr.com";
        internal_url = "http://192.168.86.233:8123";
      };
      default_config = { };
      config = { };
      frontend = { };
      mobile_app = { };
      discovery = { };
      zeroconf = { };
      ssdp = { };
      shopping_list = { };
      deconz = {
        host = "localhost";
        port = 8080;
        api_key = "!secret deconz_apikey";
      };
      mqtt = {
        broker = "localhost";
        port = config.services.mosquitto.port;
        username = "hass";
        password = "!secret mqtt_password";
        discovery = true;
        discovery_prefix = "homeassistant";
      };
      owntracks = { mqtt_topic = "owntracks/#"; };
    };
    # configWritable = true; # doesn't work atm
  };
}
