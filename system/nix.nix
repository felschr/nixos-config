{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (inputs.self.outputs) nixConfig;
in
{
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.lix;

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

  systemd.services.nixos-upgrade.preStart =
    let
      inputsToIgnore = [
        "self"
        "seven-modules"
      ];
      inputsToUpdate = lib.filter (i: !(lib.elem i inputsToIgnore)) (lib.attrNames inputs);
      inputsToUpdateStr = lib.concatStringsSep " " inputsToUpdate;
    in
    ''
      nix flake update ${inputsToUpdateStr} --flake ${config.system.autoUpgrade.flake}
    '';
}
