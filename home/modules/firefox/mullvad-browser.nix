{ config, lib, pkgs, ... }:

let common = import ./common.nix { inherit config lib pkgs; };
in common.mkModule {
  name = "mullvad-browser";
  displayName = "Mullvad Browser";
  dataConfigPath = ".mullvad/mullvadbrowser";
  defaultPackage = pkgs.mullvad-browser;
  defaultPackageName = "pkgs.mullvad-browser";
  isSecure = true;
}
