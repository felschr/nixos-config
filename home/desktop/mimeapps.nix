{ config, pkgs, ... }:

{
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.gnome.Evince.desktop" ];
    "image/gif" = [ "org.gnome.eog.desktop" ];
    "image/jpeg" = [ "org.gnome.eog.desktop" ];
    "image/jpg" = [ "org.gnome.eog.desktop" ];
    "image/png" = [ "org.gnome.eog.desktop" ];
    "image/webp" = [ "org.gnome.eog.desktop" ];
    "inode/directory" = [ "nautilus.desktop" "org.gnome.Nautilus.desktop" ];
    "text/calendar" = [ "brave-browser.desktop" ];
    "text/html" = [ "brave-browser.desktop" ];
    "text/plain" = [ "org.gnome.gedit.desktop" ];
    "x-scheme-handler/about" = [ "brave-browser.desktop" ];
    "x-scheme-handler/http" = [ "brave-browser.desktop" ];
    "x-scheme-handler/https" = [ "brave-browser.desktop" ];
    "x-scheme-handler/mailto" = [ "brave-browser.desktop" ];
    "x-scheme-handler/sgnl" = [ "signal-desktop.desktop" ];
    "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    "x-scheme-handler/webcal" = [ "brave-browser.desktop" ];
  };
}
