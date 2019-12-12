{ config, pkgs, ... }:

with pkgs;
{
  imports = [
    ./common/sh.nix
    ./common/direnv.nix
    ./common/mimeapps.nix
    ./common/gui.nix
    ./common/gnome.nix
    ./common/neovim.nix
    ./common/emacs.nix
    ./common/vscode.nix
    ./common/keybase.nix
    ./common/signal.nix
    ./common/chromium.nix
    ./common/dotnet.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.redshift = {
    enable = true;
    latitude = "53.2472211";
    longitude = "10.4021562";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Felix Schroeter";
    userEmail = "fs@upsquared.com";
    ignores = [".direnv"];
  };

  programs.firefox.enable = true;

  home.file.".envrc".text = ''
    dotenv
  '';

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware-updater

    # productivity
    discord
    libreoffice
    skypeforlinux

    # development
    unzip
    kubectl
    kubernetes-helm
    awscli
    postman
  ];

  home.stateVersion = "19.09";
}
