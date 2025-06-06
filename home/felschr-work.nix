{ inputs, pkgs, ... }:

with pkgs;
{
  imports = [
    ./shell
    ./tailscale.nix
    ./editors
    ./desktop
    ./git.nix
    ./element.nix
    ./signal.nix
    ./browsers
    ./planck.nix
    ./services/easyeffects.nix
    inputs.seven-modules.homeModules.seven
  ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # use auth subkey's keygrip: gpg2 -K --with-keygrip
    sshKeys = [ "70DBD13E3BCAF806D416647D9C51321E2F1312CF" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentry.package = pkgs.pinentry-gnome3;
  };
  programs.zsh.initContent = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  '';

  programs.ssh.enable = true;

  programs.git.defaultProfile = "work";

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware-updater
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
    authenticator
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

    # ai
    unstable.alpaca

    # other
    zotero
    emblem
  ];

  seven.enable = true;

  home.stateVersion = "25.05";
}
