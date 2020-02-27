{ config, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-panel@jderose9.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "chromium-browser.desktop"
        "code.desktop"
      ];
    };
    "org/gnome/shell/extensions/dash-to-panel" = {
      appicon-padding = 4;
      panel-size = 36;
    };
  };
}
