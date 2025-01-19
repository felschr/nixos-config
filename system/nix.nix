{ inputs, config, ... }:

let
  inherit (inputs.self.outputs) nixConfig;
in
{
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
  };

  programs.git = {
    enable = true;
    config.safe.directory = [ "/etc/nixos" ];
  };

  systemd.services.nixos-upgrade.preStart = ''
    nix flake update --flake ${config.system.autoUpgrade.flake}
  '';
}
