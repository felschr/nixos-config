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
    # inspiration: https://github.com/rubo77/rsync-homedir-excludes
    ignorePatterns = [
      "/var/lib/systemd"
      "/var/lib/libvirt"
      "/var/lib/containers"
      "/var/lib/nixos-containers"
      "/var/lib/lxcfs"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/home/*/Downloads"
      "/home/*/Pictures"
      "/home/*/Videos"
      "/home/*/Music"
      "/home/*/Games"
      "/home/*/.android"
      "/home/*/.AndroidStudio*"
      "/home/*/.cache"
      "/home/*/.cargo"
      "/home/*/.compose-cache"
      "/home/*/.dotnet"
      "/home/*/.gradle"
      "/home/*/.mozilla"
      "/home/*/.npm"
      "/home/*/.nuget"
      "/home/*/.rustup"
      "/home/*/.steam"
      "/home/*/.templateengine"
      "/home/*/.var"
      "/home/*/.wine"
      "/home/*/.local/share/containers"
      "/home/*/.local/share/docker"
      "/home/*/.local/share/flatpak"
      "/home/*/.local/share/bottles"
      "/home/*/.local/share/Steam"
      "/home/*/.local/share/keybase"
      "/home/*/.local/share/libvirt"
      "/home/*/.local/share/lutris"
      "/home/*/.local/share/NuGet"
      "/home/*/.local/share/tor-browser"
      "/home/*/.local/share/Trash"
      "/home/*/.config/BraveSoftware"
      "/home/*/.config/chromium"
      "/home/*/.config/gatsby"
      "/home/*/.config/libvirt"
      "/home/*/.config/spotify/Users"
      "/home/felschr/media"
      "/home/felschr/keybase"
      "/home/felschr/dev" # backup ~/dev-backup instead

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

      # electron apps
      "/home/*/.config/**/blob_storage"
      "/home/*/.config/**/Application Cache"
      "/home/*/.config/**/Cache"
      "/home/*/.config/**/CachedData"
      "/home/*/.config/**/Code Cache"
      "/home/*/.config/**/GPUCache"
      "/home/*/.var/app/**/blob_storage"
      "/home/*/.var/app/**/Application Cache"
      "/home/*/.var/app/**/Cache"
      "/home/*/.var/app/**/CachedData"
      "/home/*/.var/app/**/Code Cache"
      "/home/*/.var/app/**/GPUCache"
    ];
    timerConfig.OnCalendar = "0/6:00:00";
    extraPruneOpts = [ "--keep-last 4" ];
  };

  # Extra handling for dev folder to respect .gitignore files.
  # Do not delete `~/dev-backup` since this leads to changing ctimes
  # which would cause otherwise unchanged files to be backed up again.
  # Since `--link-dest` is used, file contents won't be duplicated on disk.
  systemd.services."restic-backups-full" = {
    preStart = ''
      rm -rf /home/felschr/dev-backup
      ${pkgs.rsync}/bin/rsync \
        -a --delete \
        --filter=':- .gitignore' \
        --exclude 'nixpkgs' \
        --link-dest=/home/felschr/dev \
        /home/felschr/dev/ /home/felschr/dev-backup
    '';
  };
}
