{ lib, pkgs, ... }:

{
  imports = [
    ./shell
    ./tailscale.nix
    ./editors
    ./desktop
    ./desktop/monitors.nix
    ./git.nix
    ./keybase.nix
    ./element.nix
    ./signal.nix
    ./browsers
    ./planck.nix
    ./ausweisapp.nix
    ./gaming
    ./services/easyeffects.nix
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # use auth subkey's keygrip: gpg2 -K --with-keygrip
    sshKeys = [
      "3C48489F3B0FBB44E72180D4B1D7541C201C9987"
      "8A6213DCDAF86BD3A63549FCFDF71B2C92DAE02C"
    ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  programs.zsh.initExtra = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  '';

  programs.ssh.enable = true;

  programs.git.defaultProfile = "private";

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

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

    # work
    teams-for-linux

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
    yubikey-manager-qt
    # yubioath-flutter # TODO conflicts with fluffychat
    magic-wormhole-rs
    warp
    # onionshare-gui
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

  home.stateVersion = "24.11";
}
