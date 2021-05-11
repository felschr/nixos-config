{ config, pkgs, ... }:

{
  imports = [ ./firefox.nix ./brave.nix ];

  home.sessionVariables = { BROWSER = "firefox"; };
}
