{
  config,
  lib,
  pkgs,
  ...
}:

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
  ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # use auth subkey's keygrip: gpg2 -K --with-keygrip
    sshKeys = [ "8A6213DCDAF86BD3A63549FCFDF71B2C92DAE02C" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentry.package = pkgs.pinentry-gnome3;
  };
  programs.zsh.initContent = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  '';

  programs.ssh.enable = true;

  programs.git = {
    defaultProfile = "work";
  };

  home.packages = with pkgs; [
    fh

    # system
    gparted
    gnome-firmware-updater
    mission-center

    # productivity
    libreoffice-fresh

    # dev & admin
    pods
    # gaphor

    # security & privacy
    unstable.proton-pass
    authenticator
    collision
    metadata-cleaner
    raider

    # entertainment
    celluloid

    # other
    emblem
  ];

  home.stateVersion = "25.05";
}
