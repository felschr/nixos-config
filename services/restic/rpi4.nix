{ config, lib, pkgs, ... }:

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
      "/var/lib/syncthing"
      "/var/lib/jellyfin"
      "/var/lib/owntracks"
      "/var/lib/owntracks-recorder"
    ];
    timerConfig = { OnCalendar = "hourly"; };
    extraPruneOpts = [ "--keep-hourly 24" ];
  };
}
