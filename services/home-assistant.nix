{ config, pkgs, ... }:

with pkgs;
{
  services.home-assistant = {
    enable = true;
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
      default_config = {};
      config = {};
      frontend = {};
      mobile_app = {};
      discovery = {};
      zeroconf = {};
      ssdp = {};
      shopping_list = {};
      owntracks = {
        mqtt_topic = "owntracks/#";
	secret = "!secret owntracks_secret";
      };
    };
    # configWritable = true; # doesn't work atm
  };
}
