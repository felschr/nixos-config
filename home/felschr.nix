{ inputs, pkgs, ... }:

{
  imports = [
    ./shell
    ./tailscale.nix
    ./editors
    ./desktop
    ./desktop/monitors.nix
    ./git.nix
    ./element.nix
    ./signal.nix
    ./browsers
    ./planck.nix
    ./ausweisapp.nix
    ./gaming
    ./services/easyeffects.nix
    inputs.seven-modules.homeModules.seven
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # use auth subkey's keygrip: gpg2 -K --with-keygrip
    sshKeys = [
      "3C48489F3B0FBB44E72180D4B1D7541C201C9987"
      "70DBD13E3BCAF806D416647D9C51321E2F1312CF"
    ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentry.package = pkgs.pinentry-gnome3;
  };
  programs.zsh.initContent = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  '';

  programs.ssh.enable = true;

  programs.git.defaultProfile = "private";

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware-updater
    resources

    # productivity
    anytype
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
    authenticator
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

  seven.enable = true;

  home.stateVersion = "25.05";
}
