{ config, lib, pkgs, ... }:

# using the restic cli:
# load credentials into shell via: export $(cat /path/to/credentials/file | xargs)
# useful commands for analysing restic stats [snapshot-id], restic diff [s1] [s2],

with lib;
with builtins;
let
  hasAnyAttr = flip (attrset: any (flip hasAttr attrset));

  resticConfig = args@{ name, extraPruneOpts ? [ ], ... }:
    assert !hasAnyAttr [
      "initialize"
      "repository"
      "s3CredentialsFile"
      "passwordFile"
      "pruneOpts"
    ] args;
    (removeAttrs args [ "name" "extraPruneOpts" ]) // {
      initialize = true;
      repository = "b2:felschr-rpi4-backup:/${name}";
      s3CredentialsFile = "/etc/nixos/secrets/restic/b2";
      passwordFile = "/etc/nixos/secrets/restic/password";
      timerConfig = if (args ? timerConfig) then
        args.timerConfig
      else {
        OnCalendar = "daily";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--keep-yearly 1"
      ] ++ extraPruneOpts;
    };
in {
  environment.systemPackages = with pkgs; [ restic ];

  services.restic.backups.full = resticConfig {
    name = "full";
    paths = [ "/home" "/var" "/etc" ];
  };

  services.restic.backups.data = resticConfig {
    name = "data";
    paths = [
      "/etc/nixos"
      "/home/felschr/.config/syncthing"
      "/home/felschr/sync/backups"
      "/var/lib/etebase-server"
      "/var/lib/hass"
      "/var/lib/mosquitto"
      "/var/lib/photoprism"
      "/var/lib/syncthing"
      "/var/lib/jellyfin"
      "/var/lib/owntracks"
    ];
    timerConfig = { OnCalendar = "hourly"; };
    extraPruneOpts = [ "--keep-hourly 24" ];
    extraOptions = [ "--exclude=/var/lib/jellyfin/transcodes" ];
  };
}
