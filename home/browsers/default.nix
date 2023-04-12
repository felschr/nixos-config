{ config, pkgs, ... }:

{
  imports = [ ./mullvad-browser.nix ./tor-browser.nix ./firefox.nix ];

  home.sessionVariables.BROWSER = "mullvad-browser";
}
