{ pkgs, ... }:

{
  gtk = {
    enable = true;
    theme.name = "Adwaita";
    theme.package = pkgs.gnome-themes-extra;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    platformTheme.name = "Adwaita-dark";
    style.name = "Adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };
}
