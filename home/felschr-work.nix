{ inputs, pkgs, ... }:

with pkgs;
{
  imports = [
    ./base.nix
    ./shell
    ./tailscale.nix
    ./editors
    ./ai.nix
    ./desktop
    ./ssh.nix
    ./git.nix
    ./element.nix
    ./signal.nix
    ./browsers
    ./planck.nix
    ./services/easyeffects.nix
  ];

  programs.git.defaultProfile = "work";

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware
    mission-center

    # productivity
    obsidian
    libreoffice-fresh
    curtail

    # dev & admin
    pods
    # gaphor

    # security & privacy
    unstable.proton-pass
    unstable.proton-authenticator
    collision
    metadata-cleaner
    raider
    gnome-obfuscate
    yubikey-manager
    yubioath-flutter
    localsend
    onionshare-gui

    # entertainment
    celluloid
    spotify

    # ai
    unstable.alpaca

    # other
    zotero
    emblem
  ];

  home.stateVersion = "25.05";
}
