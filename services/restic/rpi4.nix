{ config, pkgs, ... }:

{
  services.restic.backups.rpi4 = {
    initialize = true;
    repository = "b2:felschr-rpi4-backup:/";
    s3CredentialsFile = "/etc/nixos/secrets/restic/b2";
    passwordFile = "/etc/nixos/secrets/restic/password";
    paths = [
      "/etc/nixos"
      "/home/felschr/.config/syncthing"
      "/home/felschr/sync/backups"
      "/var/lib/etebase-server"
      "/var/lib/hass"
      "/var/lib/mosquitto"
      "/var/lib/syncthing"
      "/var/lib/jellyfin"
      "/var/lib/owntracks"
      "/var/lib/owntracks-recorder"
    ];
    timerConfig = { OnCalendar = "hourly"; };
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 3"
      "--keep-yearly 1"
    ];
  };
}
