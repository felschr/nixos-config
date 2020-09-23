{ config, pkgs, ... }:

{
  # for flakes support
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "10:00";
    options = "--delete-older-than 30d";
  };
}
