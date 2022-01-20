{ config, lib, pkgs, ... }:

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
    pinentryFlavor = "gnome3";
  };
  # https://github.com/nix-community/home-manager/issues/667#issuecomment-902236379
  # https://github.com/nix-community/home-manager/pull/2253
  home.sessionVariables.SSH_AUTH_SOCK =
    "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";

  programs.ssh.enable = true;

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
    tabbed

    # work
    teams

    # development
    postman

    # entertainment
    celluloid
    spotify
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

  home.stateVersion = "21.11";
}
