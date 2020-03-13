{ config, pkgs, ... }:

with pkgs;
{
  imports = [
    ./shell
    ./direnv
    ./editors
    ./desktop
    ./keybase.nix
    ./signal.nix
    ./chromium.nix
    ./planck.nix
  ];

  nixpkgs.config.allowUnfree = true;

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

  programs.git = {
    enable = true;
    userName = "Felix Tenley";
    userEmail = "dev@felschr.com";
    ignores = [".direnv"];
    signing = {
      key = "22A6 DD21 EE66 E73D D4B9  3F20 A12D 7C9D 2FD3 4458";
      signByDefault = true;
    };
    extraConfig = {
      pull = { rebase = true; };
      rebase = { autoStash = true; };
    };
  };

  home.packages = with pkgs; [
    # system
    gparted
    gnome-firmware-updater

    # productivity
    discord

    # development
    haskellPackages.ghc

    # gaming
    steam
    linux-steam-integration
    lutris

    # other
    ledger-live-desktop
  ];

  home.stateVersion = "19.09";
}
