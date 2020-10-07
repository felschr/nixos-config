{ config, pkgs, ... }:

with pkgs;
let
  pydeconz = python3.pkgs.buildPythonPackage rec {
    pname = "pydeconz";
    version = "73";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "Lm7J0p2dp2gyesDpgN0WGpxPewC1z/IUy0CDEqofQGA=";
    };

    propagateBuildInputs = with python3Packages; [ setuptools ];
    buildInputs = with python3Packages; [ aiohttp ];
    doCheck = false;
  };
in
{
  imports = [ ./deconz.nix ];

  environment.systemPackages = with pkgs; [ deconz ];

  local.services.deconz = {
    enable = true;
    httpPort = 8080;
    wsPort = 1443;
    openFirewall = true;
  };

  services.home-assistant = {
    enable = true;
    package = home-assistant.override {
      extraPackages = ps: with ps; [ pydeconz ];
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
      deconz = {
        host = "localhost";
        port = 8080;
	api_key = "!secret deconz_apikey";
      };
    };
    # configWritable = true; # doesn't work atm
  };
}
