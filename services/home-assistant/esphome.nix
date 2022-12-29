{ config, pkgs, ... }:

with pkgs;

let
  port = 6052;
  inherit (config.services.home-assistant) configDir;
  passwordFile = config.age.secrets.esphome-password.path;
in {
  age.secrets.esphome-password.file = ../../secrets/esphome/password.age;

  services.nginx = {
    virtualHosts."esphome.felschr.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        proxyWebsockets = true;
      };
    };
  };

  systemd.services.esphome = {
    description = "ESPHome";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.LoadCredential = [ "password:${passwordFile}" ];
    script = ''
      password="$(<"$CREDENTIALS_DIRECTORY/password")"
      ${pkgs.esphome}/bin/esphome dashboard ${configDir}/esphome --password "$password"
    '';
  };
}
