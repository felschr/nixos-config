{ lib, inputs, ... }:

let flakes = lib.filterAttrs (name: value: value ? outputs) inputs;
in {
  nix.gc = {
    automatic = true;
    dates = "04:00";
    options = "--delete-older-than 30d";
  };

  nix.settings = {
    trusted-users = [ "@wheel" ];
    auto-optimise-store = true;
    substituters = [ "https://felschr.cachix.org" ];
    trusted-public-keys =
      [ "felschr.cachix.org-1:raomy5XA2tsVkBoG6wo70ARIn+V24IXhWaSe3QZo12A=" ];
  };

  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    flake = "/etc/nixos";
    flags = with lib;
      flatten (mapAttrsToList (n: _: [ "--update-input" n ]) flakes);
  };
}
