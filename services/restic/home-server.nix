{ config, lib, pkgs, ... }:

# using the restic cli:
# load credentials into shell by adding B2 secrets to .env (see .env.example).
# useful commands for analysing restic stats [snapshot-id], restic diff [s1] [s2],

with lib;
with builtins;
let resticLib = import ./lib.nix { inherit config lib pkgs; };
in {
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [ restic ];

  services.restic.backups.full = resticLib.resticConfig {
    name = "home-server";
    paths = [ "/etc/nixos" "/var/lib" "/home" ];
    ignorePatterns = [
      "/var/lib/systemd"
      "/var/lib/containers"
      "/var/lib/nixos-containers"
      "/var/lib/lxcfs"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/home/*/ignore"
      "/home/*/.cache"
      "/home/*/.local/share/containers"
      "/home/*/.local/share/Trash"
      "/var/lib/jellyfin/transcodes"

      # general
      ".cache"
      "cache"
      ".tmp"
      ".temp"
      "tmp"
      "temp"
      ".log"
      "log"
      ".Trash"
    ];
    timerConfig.OnCalendar = "0/6:00:00";
    extraPruneOpts = [ "--keep-last 4" ];
    backupPrepareCommand = ''
      # remove stale locks
      ${pkgs.restic}/bin/restic unlock || true
    '';
  };
}
