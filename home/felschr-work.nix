{ config, pkgs, ... }:

with pkgs;
{
  imports = [
    ./shell
    ./editors
    ./desktop
    ./keybase.nix
    ./signal.nix
    ./chromium.nix
    ./dotnet.nix
    ./planck.nix
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
