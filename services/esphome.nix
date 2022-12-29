{ config, pkgs, ... }:

with pkgs;

let
  port = 6052;
  inherit (config.services.home-assistant) configDir;
in {
  services.nginx = {
    virtualHosts."esphome.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}";
        proxyWebsockets = true;
      };
    };
  };

  systemd.services.esphome = {
    description = "ESPHome";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "hass";
      Group = "hass";
      Restart = "on-failure";
      WorkingDirectory = configDir;
      ExecStart = "${pkgs.esphome}/bin/esphome dashboard ${configDir}/esphome";
    };
  };
}
