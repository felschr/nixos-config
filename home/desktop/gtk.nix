{ config, pkgs, ... }:

let
  pop-gtk-theme = pkgs.pop-gtk-theme.overrideAttrs (oldAttrs: rec {
    postInstall = ''
      # fix dark gnome-shell theme
      ln -s $out/share/gnome-shell/theme/Pop-dark $out/share/themes/Pop-dark/gnome-shell
    '';
  });
in
{
  gtk.enable = true;
  gtk.theme.name = "Pop-dark";
  gtk.theme.package = pop-gtk-theme;
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
}
