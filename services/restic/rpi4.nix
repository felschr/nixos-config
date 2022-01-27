{ config, lib, pkgs, ... }:

# using the restic cli:
# load credentials into shell via: export $(cat /path/to/credentials/file | xargs)
# useful commands for analysing restic stats [snapshot-id], restic diff [s1] [s2],

with lib;
with builtins;
let common = import ./common.nix { inherit config lib pkgs; };
in {
  environment.systemPackages = with pkgs; [ restic ];

  services.restic.backups.full = common.resticConfig {
    name = "rpi4";
    paths = [ "/etc/nixos" "/var/lib" "/home" ];
    timerConfig.OnCalendar = "0/4:00:00";
    extraPruneOpts = [ "--keep-last 6" ];
    extraOptions = let
      exclude = ''
        /var/lib/lxcfs
        /var/lib/docker
        /home/*/.local/share/Trash
        /home/*/.cache
        /var/lib/jellyfin/transcodes
      '';
    in [ "--exclude=/var/lib/jellyfin/transcodes" ];
  };
}
