{ config, pkgs, ... }:

{
  gtk.enable = true;
  gtk.theme.name = "Adwaita-dark";
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
}
