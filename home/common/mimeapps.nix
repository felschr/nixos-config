{ config, pkgs, ... }:  

{
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "chromium-browser.desktop" ];
    "text/calendar" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/about" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/unknown" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/mailto" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/webcal" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/sgnl" = [ "signal-desktop.desktop" ];
  };
}
