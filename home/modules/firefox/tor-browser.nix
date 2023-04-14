{ config, lib, pkgs, ... }:

let common = import ./common.nix { inherit config lib pkgs; };
in common.mkModule {
  name = "tor-browser";
  displayName = "Tor Browser";
  # @TODO is this correct?
  dataConfigPath = ".local/share/tor-browser/TorBrowser/Data/Browser";
  defaultPackage = pkgs.tor-browser-bundle-bin;
  defaultPackageName = "pkgs.tor-browser-bundle-bin";
  isSecure = true;
}
