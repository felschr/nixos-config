{ config, pkgs, ... }:

{
  imports = [
    ./shell
    ./editors
    ./desktop
    ./desktop/monitors.nix
    ./vpn.nix
    ./git.nix
    ./syncthing.nix
    ./keybase.nix
    ./signal.nix
    ./browsers
    ./planck.nix
    ./ausweisapp.nix
    ./gaming
  ];

  services.gammastep = {
    enable = true;
    latitude = "53.2603609";
    longitude = "10.4014691";
    settings = {
      general = {
        brightness-day = "0.9";
        brightness-night = "0.9";
      };
    };
  };

  programs.ssh = { enable = true; };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "4AE1DDE05F4BB6C8E220501F1336A98E89836D90" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentryFlavor = "gnome3";
  };

  programs.gpg.enable = true;

  programs.git = { defaultProfile = "private"; };

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware-updater

    # productivity
    discord
    libreoffice-fresh
    xournalpp
    skypeforlinux
    tabbed

    # development
    postman

    # entertainment
    celluloid
    google-play-music-desktop-player
    # audiotube

    # learning
    anki

    # privacy
    onionshare-gui
    transmission-gtk

    # media backups
    makemkv
    handbrake
    # filebot # TODO fails atm

    # other
    bitwarden
    ledger-live-desktop
    portfolio
  ];

  home.stateVersion = "21.05";
}
