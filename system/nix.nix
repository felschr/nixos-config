{ config, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "04:00";
    options = "--delete-older-than 30d";
  };

  nix.settings = {
    auto-optimise-store = true;
    substituters = [ "https://hydra.iohk.io" "https://shajra.cachix.org" ];
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "shajra.cachix.org-1:V0x7Wjgd/mHGk2KQwzXv8iydfIgLupbnZKLSQt5hh9o="
    ];
  };
}
