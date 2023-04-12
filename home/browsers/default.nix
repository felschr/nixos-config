{ config, pkgs, ... }:

{
  imports = [ ./firefox.nix ./tor-browser.nix ];

  home.sessionVariables.BROWSER = "firefox";
}
