{ config, pkgs, lib, inputs, ... }:

let flakes = lib.filterAttrs (name: value: value ? outputs) inputs;
in {
  nix.gc = {
    automatic = true;
    dates = "04:00";
    options = "--delete-older-than 30d";
  };

  nix.trustedUsers = [ "@wheel" ];

  nix.settings = {
    auto-optimise-store = true;
    substituters = [ "https://hydra.iohk.io" "https://shajra.cachix.org" ];
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "shajra.cachix.org-1:V0x7Wjgd/mHGk2KQwzXv8iydfIgLupbnZKLSQt5hh9o="
    ];
  };

  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    flake = "/etc/nixos";
    flags = with lib;
      flatten (mapAttrsToList (n: _: [ "--update-input" n ]) flakes);
  };
}
