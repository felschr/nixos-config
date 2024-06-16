{
  config,
  pkgs,
  inputs,
  ...
}:

let
  port = config.services.home-assistant.config.http.server_port;
in
{
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
    package = pkgs.unstable.home-assistant.overrideAttrs (oldAttrs: {
      doInstallCheck = false;
    });
    openFirewall = true;
    extraComponents = [
      "default_config"
      "otp"
      "upnp"
      "zha"
      # "matter" # TODO uses insecure version of openssl
      "esphome"
      "homekit_controller"
      "fritz"
      "roku"
      "sonos"
      "onvif"
      "reolink"
      "media_source"
      "alarm_control_panel"
      "assist_pipeline"
      "wyoming"
      "todo"
      "local_todo"
      "shopping_list"
    ];
    extraPackages =
      ps: with ps; [
        pyqrcode

        # HACS
        aiogithubapi
      ];
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
        internal_url = "http://home-server:8123";
        media_dirs.media = "/media";
        allowlist_external_dirs = [
          "/tmp"
          "/media"
        ];
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
        enable_quirks = true;
        custom_quirks_path = "${config.services.home-assistant.configDir}/zha_quirks/";
        zigpy_config.ota = {
          ikea_provider = true;
          sonoff_provider = true;
          ledvance_provider = true;
        };
      };
      zha_toolkit = { };
      conversation = {
        intents = { };
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
    file = ../../secrets/hass/secrets.age;
    path = "/var/lib/hass/secrets.yaml";
    owner = "hass";
    group = "hass";
  };
}
