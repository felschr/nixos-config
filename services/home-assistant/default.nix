{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  port = config.services.home-assistant.config.http.server_port;
  devices = {
    zigbee = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231009144806-if00";
    thread = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231009150648-if00";
  };
in
{
  disabledModules = [ "services/home-automation/home-assistant.nix" ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/home-automation/home-assistant.nix"
    "${inputs.nixpkgs-otbr}/nixos/modules/services/home-automation/openthread-border-router.nix"
    ./wyoming.nix
    # ./esphome.nix # HINT currently unused
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
      "thread"
      "otbr"
      "matter"
      # "esphome" # HINT currently unused
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
    customComponents = with pkgs.unstable.home-assistant-custom-components; [
      alarmo
      adaptive_lighting
      ingress
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      auto-entities
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
          extra_providers = [
            { type = "ikea"; }
            { type = "sonoff"; }
            { type = "ledvance"; }
          ];
        };
      };
      zha_toolkit = { };
      conversation = {
        intents = { };
      };
      ingress = {
        "matter" = {
          title = "Matter Server";
          icon = "mdi:home-automation";
          ui_mode = "toolbar";
          url = "http://127.0.0.1:${toString config.services.matter-server.port}/";
        };
        "otbr" = {
          title = "OpenThread Border Router";
          icon = "mdi:home-automation";
          ui_mode = "toolbar";
          url = "http://127.0.0.1:${toString config.services.openthread-border-router.web.listenPort}/";
        };
      };
    };
    # configWritable = true; # doesn't work atm
  };

  services.matter-server = {
    enable = true;
    extraArgs = [
      "--bluetooth-adapter=0"
    ];
  };

  services.openthread-border-router = {
    enable = true;
    package = inputs.nixpkgs-otbr.legacyPackages.${pkgs.system}.openthread-border-router;
    radio = {
      device = devices.thread;
      baudRate = 460800;
      extraDevices = [ "trel://enp2s0" ];
    };
    backboneInterface = "enp2s0";
    web.enable = true;
  };

  # systemd-resolved is already providing mDNS, but avahi seems to be required for otbr
  services.avahi.enable = lib.mkOverride 40 true;

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
