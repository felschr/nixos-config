{ config, pkgs, ... }:

{
  imports = [ ./gtk.nix ./gnome.nix ./mimeapps.nix ];
}
