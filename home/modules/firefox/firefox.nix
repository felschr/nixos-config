{ config, lib, pkgs, ... }:

let common = import ./common.nix { inherit config lib pkgs; };
in common.mkModule {
  name = "firefox";
  displayName = "Firefox";
  dataConfigPath = ".mozilla/firefox";
  defaultPackage = pkgs.firefox;
  defaultPackageName = "pkgs.firefox";
  isSecure = false;
}
