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
  imports = [
    # TODO switch to lixFromNixpkgs once 2.93.2 is available
    inputs.lix-module.nixosModules.default
    # inputs.lix-module.nixosModules.lixFromNixpkgs
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [ "@wheel" ];
      substituters = nixConfig.extra-substituters;
      trusted-public-keys = nixConfig.extra-trusted-public-keys;
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "04:00";
      options = "--delete-older-than 30d";
    };
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

  environment.systemPackages = with pkgs; [
    unstable.nix-tree
  ];
}
