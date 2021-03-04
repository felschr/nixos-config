{ config, pkgs, ... }:

{
  imports = [ ./firefox.nix ./chromium.nix ];

  home.sessionVariables = { BROWSER = "firefox"; };
}
