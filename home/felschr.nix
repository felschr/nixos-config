{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in
{
  nixpkgs.config.allowUnfree = true;

  # xsession.enable = true;

  gtk.enable = true;
  gtk.theme.name = "Adwaita-dark";
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  services.redshift = {
    enable = true;
    latitude = "53.2603609";
    longitude = "10.4014691";
  };

  programs.fish = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.termite = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Felix Tenley";
    userEmail = "dev@felschr.com";
  };

  programs.emacs = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    # userSettings = {}
  };

  services.keybase.enable = true;
  services.kbfs.enable = true;

  programs.chromium = {
    enable = true;
  };

  programs.firefox.enable = true;

  home.packages = with pkgs; [
    gparted

    # development
    haskellPackages.ghc

    signal-desktop
    discord
    keybase-gui
    unstable.steam
    unstable.linux-steam-integration
    unstable.lutris
    unstable.ledger-live-desktop
  ];

  home.stateVersion = "19.09";
}
