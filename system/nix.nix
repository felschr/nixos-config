{ config, pkgs, ... }:

{
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "10:00";
    options = "--delete-older-than 30d";
  };

  nix.binaryCaches = [ "https://hydra.iohk.io" "https://shajra.cachix.org" ];
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "shajra.cachix.org-1:V0x7Wjgd/mHGk2KQwzXv8iydfIgLupbnZKLSQt5hh9o="
  ];
}
