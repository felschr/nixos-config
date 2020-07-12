{ config, pkgs, ... }:

with pkgs;
{
  imports = [
    ./shell
    ./editors
    ./desktop
    ./vpn.nix
    ./git.nix
    ./keybase.nix
    ./signal.nix
    ./browser.nix
    ./dotnet.nix
    ./planck.nix
  ];

  services.redshift = {
    enable = true;
    latitude = "53.2472211";
    longitude = "10.4021562";
  };

  programs.ssh = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "967EC4516D18D0E1211FCFC38B1CAF89FF627FCA" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentryFlavor = "gnome3";
  };

  programs.gpg.enable = true;

  programs.git.custom = {
    defaultProfile = "work";
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

    # entertainment
    celluloid

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

  home.stateVersion = "20.03";
}
