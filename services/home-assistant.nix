{ config, pkgs, ... }:

with pkgs; 

{
  environment.systemPackages = with pkgs; [ deconz ];

  local.services.deconz = {
    enable = true;
    httpPort = 8080;
    wsPort = 1443;
    openFirewall = true;
  };

  users.users.mosquitto.extraGroups = [ "acme" ];

  networking.firewall.allowedTCPPorts = [
    config.services.mosquitto.ssl.port
  ];

  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    checkPasswords = true;
    ssl = {
      enable = true;
      cafile = "/var/lib/acme/${config.networking.domain}/chain.pem";
      certfile = "/var/lib/acme/${config.networking.domain}/cert.pem";
      keyfile = "/var/lib/acme/${config.networking.domain}/key.pem";
    };
    users = {
      "hass" = {
        acl = [
          "topic readwrite homeassistant/#"
          "topic readwrite tasmota/#"
          "topic readwrite owntracks/#"
        ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/hass";
      };
      "owntracks" = {
        acl = [
          "topic readwrite owntracks/#"
        ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/owntracks";
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
        port = "8883";
        username = "hass";
        password = "!secret mqtt_password";
        discovery = true;
        discovery_prefix = "homeassistant";
      };
      owntracks = {
        mqtt_topic = "owntracks/#";
      };
    };
    # configWritable = true; # doesn't work atm
  };
}
