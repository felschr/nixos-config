{ config, pkgs, ... }:

{
  imports = [ ./x11.nix ./wayland.nix ./gtk.nix ./gnome.nix ];
}
