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
    name = "home-pc";
    dynamicFilesFrom = let
      ignore = builtins.toFile "excludes" ''
        /var/lib/lxcfs
        /var/lib/docker
        /home/*/.local/share/Trash
        /home/*/.cache
        /home/*/Downloads
        /home/*/.npm
        /home/*/.steam
        /home/*/.local/share/Steam
        /home/*/.local/share/lutris
        /home/felschr/sync
        /home/felschr/Sync
        /home/felschr/keybase
      '';
    in ''
      ${pkgs.ripgrep}/bin/rg \
        --files /etc/nixos /var/lib /home \
        --ignore-file ${ignore}
    '';
    timerConfig.OnCalendar = "0/4:00:00";
    extraPruneOpts = [ "--keep-last 6" ];
  };
}
