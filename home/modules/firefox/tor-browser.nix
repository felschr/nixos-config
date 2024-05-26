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
  defaultPackage = pkgs.tor-browser-bundle-bin;
  defaultPackageName = "pkgs.tor-browser-bundle-bin";
  isSecure = true;
}
