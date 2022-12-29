{ config, pkgs, ... }:

with pkgs;

let
  port = config.services.home-assistant.config.http.server_port;
  mqttPort = 1883;
  geniePort = 3232;
in {
  # just installed for ConBee firmware updates
  environment.systemPackages = with pkgs; [ deconz ];

  services.nginx = {
    virtualHosts."${config.networking.domain}" = {
      enableACME = true;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}";
        proxyWebsockets = true;
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "default_config"
      "otp"
      "mqtt"
      "esphome"
      "homekit_controller"
      "roku"
      "sonos"
      "onvif"
      "shopping_list"
    ];
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 42;
        unit_system = "metric";
        temperature_unit = "C";
        external_url = "https://home.felschr.com";
        internal_url = "http://192.168.1.102:8123";
      };
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "::1" ];
      };
      "automation editor" = "!include automations.yaml";
      "scene editor" = "!include scenes.yaml";
      "script editor" = "!include scripts.yaml";
      zha = {
        database_path = "/var/lib/hass/zigbee.db";
        zigpy_config = { ota = { ikea_provider = true; }; };
      };
      owntracks = { mqtt_topic = "owntracks/#"; };
      alarm_control_panel = [{
        platform = "manual";
        code = "!secret alarm_code";
        arming_time = 30;
        delay_time = 30;
        trigger_time = 120;
        disarmed = { trigger_time = 0; };
        armed_home = {
          arming_time = 0;
          delay_time = 0;
        };
      }];
      almond = {
        type = "local";
        host = "http://localhost:${toString geniePort}/me";
      };
    };
    # configWritable = true; # doesn't work atm
  };

  networking.firewall.allowedTCPPorts = [
    1400 # Sonos discovery
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # HomeKit
  ];

  age.secrets.hass-secrets = {
    file = ../secrets/hass/secrets.age;
    path = "/var/lib/hass/secrets.yaml";
    owner = "hass";
    group = "hass";
  };
}
