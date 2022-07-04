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
    paths = [ "/etc/nixos" "/var/lib" "/home" ];
    ignorePatterns = [
      "/var/lib/systemd"
      "/var/lib/libvirt"
      "/var/lib/containers"
      "/var/lib/lxcfs"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/home/*/Downloads"
      "/home/*/Games"
      "/home/*/.cache"
      "/home/*/.cargo"
      "/home/*/.npm"
      "/home/*/.nuget"
      "/home/*/.steam"
      "/home/*/.var"
      "/home/*/.local/share/Trash"
      "/home/*/.local/share/libvirt"
      "/home/*/.local/share/containers"
      "/home/*/.local/share/docker"
      "/home/*/.local/share/flatpak"
      "/home/*/.local/share/bottles"
      "/home/*/.local/share/Steam"
      "/home/*/.local/share/lutris"
      "/home/*/.local/share/NuGet"
      "/home/*/.config/libvirt"
      "/home/felschr/media"
      "/home/felschr/sync"
      "/home/felschr/keybase"
      "/home/felschr/dev" # backup ~/dev-backup instead
    ];
    timerConfig.OnCalendar = "0/4:00:00";
    extraPruneOpts = [ "--keep-last 6" ];
  };

  # extra handling for dev folder to respect .gitignore files:
  systemd.services."restic-backups-full" = {
    preStart = ''
      rm -rf /home/felschr/dev-backup
      ${pkgs.rsync}/bin/rsync -a \
        --filter=':- .gitignore' \
        --exclude 'nixpkgs' \
        /home/felschr/dev/* /home/felschr/dev-backup
    '';
    postStart = ''
      rm -rf /home/felschr/dev-backup
    '';
  };
}
