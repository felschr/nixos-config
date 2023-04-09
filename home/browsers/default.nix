{ config, pkgs, ... }:

{
  imports = [ ./firefox.nix ];

  home.sessionVariables.BROWSER = "firefox";
}
