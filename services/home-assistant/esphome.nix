{ config, pkgs, ... }:

with pkgs;

let
  port = 6052;
  inherit (config.services.home-assistant) configDir;
  passwordFile = config.age.secrets.esphome-password.path;
in
{
  age.secrets.esphome-password.file = ../../secrets/esphome/password.age;

  services.caddy.virtualHosts."esphome.felschr.com" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      reverse_proxy 127.0.0.1:${toString port}
    '';
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
