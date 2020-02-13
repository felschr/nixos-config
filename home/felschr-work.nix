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
    ./common/planck.nix
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

  programs.ssh = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-gnome}/bin/pinentry-gnome3
    '';
  };

  programs.gpg.enable = true;

  programs.git = {
    enable = true;
    userName = "Felix Schroeter";
    userEmail = "fs@upsquared.com";
    ignores = [".direnv"];
    signing = {
      key = "6DA1 4A05 C6E0 7DBE EB81  BA24 28ED 46BC B881 7B7A";
      signByDefault = true;
    };
    extraConfig = {
      pull = { rebase = true; };
      rebase = { autoStash = true; };
    };
  };

  programs.firefox.enable = true;

  home.file.".envrc".text = ''
    dotenv
  '';

  home.file.".config/nixpkgs/config.nix".text = ''
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
    libreoffice
    skypeforlinux
    pinta
    inkscape

    # development
    unzip
    openssl
    kubectl
    kubernetes-helm
    google-cloud-sdk
    awscli
    postman
    jq
    dos2unix
  ];

  home.stateVersion = "19.09";
}
