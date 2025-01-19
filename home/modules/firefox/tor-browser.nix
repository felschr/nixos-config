{
  config,
  lib,
  pkgs,
  ...
}:

let
  common = import ./common.nix { inherit config lib pkgs; };
in
common.mkModule {
  name = "tor-browser";
  displayName = "Tor Browser";
  dataConfigPath = ".tor project/firefox";
  defaultPackage = pkgs.tor-browser;
  defaultPackageName = "pkgs.tor-browser";
  isSecure = true;
}
