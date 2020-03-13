{ config, pkgs, ... }:

{
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "10:00";
    options = "--delete-older-than 30d";
  };
}
