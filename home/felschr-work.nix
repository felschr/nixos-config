{ config, lib, pkgs, ... }:

with pkgs; {
  imports = [
    ./shell
    ./editors
    ./desktop
    ./git.nix
    ./keybase.nix
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
    pinentryFlavor = "gnome3";
  };
  programs.zsh.initExtra = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  '';

  programs.ssh.enable = true;

  programs.git = { defaultProfile = "work"; };

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.packages = with pkgs; [
    fh

    # system
    gparted
    gnome-firmware-updater

    # productivity
    libreoffice-fresh

    # entertainment
    celluloid

    # development
    unzip
    jq
    dos2unix
  ];

  home.stateVersion = "23.05";
}
