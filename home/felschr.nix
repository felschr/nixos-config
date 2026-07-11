{ inputs, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./shell
    ./tailscale.nix
    ./editors
    ./ai.nix
    ./desktop
    ./desktop/monitors.nix
    ./ssh.nix
    ./git.nix
    ./element.nix
    ./signal.nix
    ./browsers
    ./planck.nix
    ./ausweisapp.nix
    ./gaming
    ./services/easyeffects.nix
  ];

  programs.git.defaultProfile = "private";

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware
    resources

    # productivity
    obsidian
    libreoffice-fresh
    tabbed
    curtail

    # dev & admin
    pods
    # gaphor

    # game dev
    ldtk
    pixelorama

    # entertainment
    celluloid
    spot
    spotify
    unstable.calibre
    foliate

    # security & privacy
    unstable.proton-pass
    unstable.proton-authenticator
    collision
    metadata-cleaner
    raider
    gnome-obfuscate
    yubikey-manager
    yubioath-flutter
    magic-wormhole-rs
    localsend
    onionshare-gui
    transmission_4-gtk
    unstable.qbittorrent
    fragments

    # other
    ledger-live-desktop
    unstable.portfolio
    bottles
    zotero
    newsflash
    emblem
  ];

  home.stateVersion = "25.05";
}
