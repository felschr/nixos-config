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
    name = "home-pc";
    ripgrep = true;
    paths = [ "/etc/nixos" "/var/lib" "/home" ];
    ignorePatterns = [
      "/var/lib/systemd"
      "/var/lib/containers"
      "/var/lib/lxcfs"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/home/*/.local/share/Trash"
      "/home/*/.cache"
      "/home/*/Downloads"
      "/home/*/.npm"
      "/home/*/Games"
      "/home/*/.steam"
      "/home/*/.local/share/Steam"
      "/home/*/.local/share/lutris"
      "/home/felschr/media"
      "/home/felschr/sync"
      "/home/felschr/keybase"
    ];
    timerConfig.OnCalendar = "0/4:00:00";
    extraPruneOpts = [ "--keep-last 6" ];
  };
}
