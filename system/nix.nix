{ inputs, lib, ... }:

let
  flakes = lib.filterAttrs (name: value: value ? outputs) inputs;
  inherit (inputs.self.outputs) nixConfig;
in {
  nix.gc = {
    automatic = true;
    dates = "04:00";
    options = "--delete-older-than 30d";
  };

  nix.settings = {
    trusted-users = [ "@wheel" ];
    auto-optimise-store = true;
    substituters = nixConfig.extra-substituters;
    trusted-public-keys = nixConfig.extra-trusted-public-keys;
  };

  system.autoUpgrade = {
    enable = true;
    dates = "03:00";
    flake = "/etc/nixos";
    flags = with lib;
      flatten (mapAttrsToList (n: _: [ "--update-input" n ]) flakes);
  };
}
