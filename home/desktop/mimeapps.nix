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
    "text/calendar" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "text/plain" = [ "org.gnome.gedit.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/mailto" = [ "firefox.desktop" ];
    "x-scheme-handler/sgnl" = [ "signal-desktop.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    "x-scheme-handler/webcal" = [ "firefox.desktop" ];
  };
}
