{ config, pkgs, ... }:

{
  imports = [ ./x11.nix ./gtk.nix ./gnome.nix ];
}
