{ config, pkgs, ... }:

with pkgs;

let mqttPort = 1883;
in {
  # just installed for ConBee firmware updates
  environment.systemPackages = with pkgs; [ deconz ];

  services.nginx = {
    virtualHosts."${config.networking.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.home-assistant.port}";
        proxyWebsockets = true;
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    package = (pkgs.home-assistant.overrideAttrs (oldAttrs: rec {
      # pytestCheckPhase uses too much RAM and pi can't handle it
      doCheck = false;
      doInstallCheck = false;
    })).override { extraComponents = [ "otp" ]; };
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 42;
        unit_system = "metric";
        temperature_unit = "C";
        external_url = "https://home.felschr.com";
        internal_url = "http://192.168.1.234:8123";
      };
      default_config = { };
      config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
      "automation editor" = "!include automations.yaml";
      automation = { };
      frontend = { };
      mobile_app = { };
      discovery = { };
      zeroconf = { };
      ssdp = { };
      shopping_list = { };
      zha = {
        database_path = "/var/lib/hass/zigbee.db";
        zigpy_config = { ota = { ikea_provider = true; }; };
      };
      mqtt = {
        broker = "localhost";
        port = mqttPort;
        username = "hass";
        password = "!secret mqtt_password";
        discovery = true;
        discovery_prefix = "homeassistant";
      };
      owntracks = { mqtt_topic = "owntracks/#"; };
      netatmo = {
        client_id = "!secret netatmo_client_id";
        client_secret = "!secret netatmo_client_secret";
      };
      sensor = [{
        platform = "template";
        sensors = {
          energy_total_usage = {
            friendly_name = "Total Energy Usage";
            unit_of_measurement = "kWh";
            value_template = ''
              {% computer = states('sensor.outlet_computer_energy_total') | float %}
              {% tv = states('sensor.outlet_tv_energy_total') | float %}

              {{ computer + tv }}
            '';
          };
        };
      }];
      utility_meter = {
        energy_total_usage_daily = {
          source = "sensor.energy_total_usage";
          cycle = "daily";
        };
        energy_total_usage_monthly = {
          source = "sensor.energy_total_usage";
          cycle = "monthly";
        };
        energy_total_usage_yearly = {
          source = "sensor.energy_total_usage";
          cycle = "yearly";
        };
      };
    };
    # configWritable = true; # doesn't work atm
  };
}
