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
    substituters = [
      "https://felschr.cachix.org"
      "https://wurzelpfropf.cachix.org" # ragenix
    ];
    trusted-public-keys = [
      "felschr.cachix.org-1:raomy5XA2tsVkBoG6wo70ARIn+V24IXhWaSe3QZo12A="
      "wurzelpfropf.cachix.org-1:ilZwK5a6wJqVr7Fyrzp4blIEkGK+LJT0QrpWr1qBNq0="
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
