{ config, pkgs, ... }:

with pkgs;
{
  imports = [
    ./shell
    ./editors
    ./desktop
    ./desktop/monitors.nix
    ./vpn.nix
    ./git.nix
    ./keybase.nix
    ./signal.nix
    ./chromium.nix
    ./planck.nix
  ];

  services.redshift = {
    enable = true;
    latitude = "53.2603609";
    longitude = "10.4014691";
    brightness = {
      day = "0.9";
      night = "0.9";
    };
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

  programs.git.custom = {
    defaultProfile = "private";
  };

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware-updater

    # productivity
    discord

    # development
    haskellPackages.ghc

    # entertainment
    celluloid

    # gaming
    steam
    linux-steam-integration
    lutris

    # other
    ledger-live-desktop
  ];

  home.stateVersion = "20.03";
}
