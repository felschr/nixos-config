{ config, pkgs, inputs, ... }:

let port = config.services.home-assistant.config.http.server_port;
in {
  disabledModules = [ "services/home-automation/home-assistant.nix" ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/home-automation/home-assistant.nix"
    ./wyoming.nix
    ./esphome.nix
  ];

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
    package = pkgs.unstable.home-assistant;
    openFirewall = true;
    extraComponents = [
      "default_config"
      "otp"
      "assist_pipeline"
      "wyoming"
      "esphome"
      "homekit_controller"
      "fritz"
      "roku"
      "sonos"
      "onvif"
      "shopping_list"
    ];
    extraPackages = ps: with ps; [ pyqrcode ];
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 42;
        unit_system = "metric";
        country = "DE";
        temperature_unit = "C";
        external_url = "https://home.felschr.com";
        internal_url = "http://192.168.1.102:8123";
        media_dirs.media = "/media";
      };
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "::1" ];
      };
      "automation editor" = "!include automations.yaml";
      "scene editor" = "!include scenes.yaml";
      "script editor" = "!include scripts.yaml";
      recorder.purge_keep_days = 60;
      zha = {
        database_path = "/var/lib/hass/zigbee.db";
        zigpy_config = { ota = { ikea_provider = true; }; };
      };
      conversation = { intents = { }; };
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
    file = ../../secrets/hass/secrets.age;
    path = "/var/lib/hass/secrets.yaml";
    owner = "hass";
    group = "hass";
  };
}
