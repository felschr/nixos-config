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
    ./browsers
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
    sshKeys = [ "4AE1DDE05F4BB6C8E220501F1336A98E89836D90" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentryFlavor = "gnome3";
  };

  programs.gpg.enable = true;

  programs.git = {
    defaultProfile = "private";
  };

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
    lutris

    # privacy
    onionshare-gui
    transmission-gtk

    # other
    ledger-live-desktop
  ];

  home.stateVersion = "20.03";
}
