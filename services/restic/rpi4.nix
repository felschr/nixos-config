{ config, lib, pkgs, ... }:

# using the restic cli:
# load credentials into shell via: export $(cat /path/to/credentials/file | xargs)
# useful commands for analysing restic stats [snapshot-id], restic diff [s1] [s2],

with lib;
with builtins;
let resticLib = import ./lib.nix { inherit config lib pkgs; };
in {
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [ restic ];

  services.restic.backups.full = resticLib.resticConfig {
    name = "rpi4";
    # TODO migrate old repository
    # repository = "b2:felschr-rpi4-backup:/full";
    ripgrep = true;
    paths = [ "/etc/nixos" "/var/lib" "/home" ];
    ignorePatterns = [
      "/var/lib/lxcfs"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/var/lib/systemd"
      "/home/*/.local/share/Trash"
      "/home/*/.cache"
      "/var/lib/jellyfin/transcodes"
    ];
    timerConfig.OnCalendar = "0/4:00:00";
    extraPruneOpts = [ "--keep-last 6" ];
  };
}
