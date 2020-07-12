{ config, pkgs, ... }:

{
  imports = [
    ./shell
    ./editors
    ./dotnet.nix
    ./desktop
    ./desktop/monitors.nix
    ./vpn.nix
    ./git.nix
    ./keybase.nix
    ./signal.nix
    ./browser.nix
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
    enableSshSupport = true;
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
    libreoffice-fresh
    skypeforlinux
    tabbed

    # development
    haskellPackages.ghc
    postman

    # entertainment
    celluloid

    # learning
    anki

    # gaming
    steam
    linux-steam-integration
    lutris

    # privacy
    (tor-browser-bundle-bin.override { pulseaudioSupport = true; })
    onionshare-gui
    transmission-gtk

    # other
    ledger-live-desktop
  ];

  home.stateVersion = "20.03";
}
