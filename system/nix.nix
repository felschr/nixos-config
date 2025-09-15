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

  nixpkgs.overlays = [
    (final: prev: {
      inherit (final.lixPackageSets.stable)
        nixpkgs-review
        # nix-direnv # HINT infinite recursion, overwritten in home-manager config instead
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
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
