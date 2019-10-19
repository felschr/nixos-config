{ config, pkgs, ... }:

with pkgs;
let
  unstable = import <nixos-unstable> {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in
{
  imports = [
    ./common/sh.nix
    ./common/mimeapps.nix
    ./common/gui.nix
    ./common/gnome.nix
    ./common/neovim.nix
    ./common/emacs.nix
    ./common/vscode.nix
    ./common/keybase.nix
    ./common/signal.nix
    ./common/chromium.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.redshift = {
    enable = true;
    latitude = "53.2603609";
    longitude = "10.4014691";
  };

  programs.git = {
    enable = true;
    userName = "Felix Tenley";
    userEmail = "dev@felschr.com";
  };

  home.packages = with pkgs; [
    # system
    gparted

    # productivity
    discord

    # development
    haskellPackages.ghc

    # gaming
    unstable.steam
    unstable.linux-steam-integration
    unstable.lutris

    # other
    unstable.ledger-live-desktop
  ];

  home.stateVersion = "19.09";
}
