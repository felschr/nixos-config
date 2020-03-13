{ config, pkgs, ... }:  

{
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "image/gif" = [ "eog.desktop" ];
    "image/jpeg" = [ "eog.desktop" ];
    "image/jpg" = [ "eog.desktop" ];
    "image/png" = [ "eog.desktop" ];
    "image/webp" = [ "eog.desktop" ];
    "inode/directory" = [ "nautilus.desktop" "org.gnome.Nautilus.desktop" ];
    "text/calendar" = [ "chromium-browser.desktop" ];
    "text/html" = [ "chromium-browser.desktop" ];
    "text/plain" = [ "org.gnome.gedit.desktop" ];
    "x-scheme-handler/about" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/mailto" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/sgnl" = [ "signal-desktop.desktop" ];
    "x-scheme-handler/unknown" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/webcal" = [ "chromium-browser.desktop" ];
  };
}
