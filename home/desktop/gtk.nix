{ pkgs, ... }:

let
  theme = {
    name = "Adwaita";
    package = pkgs.gnome-themes-extra;
  };
in
{
  gtk = {
    enable = true;
    inherit theme;
    # pin legacy default (changed to null in home-manager 26.05)
    gtk4.theme = theme;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    platformTheme.name = "Adwaita-dark";
    style.name = "Adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };
}
