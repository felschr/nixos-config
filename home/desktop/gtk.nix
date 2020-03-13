{ config, pkgs, ... }:

{
  gtk.enable = true;
  gtk.theme.name = "Pop-dark";
  gtk.theme.package = pkgs.pop-gtk-theme;
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
}
