{ config, pkgs, ... }:

{
  gtk.enable = true;
  gtk.theme.name = "Adwaita";
  gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
}
