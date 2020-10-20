{ config, lib, pkgs, ... }:

let
  left = "h";
  down = "j";
  up = "k";
  right = "l";
in {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "pop-shell@system76.com"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com" # works better with pop-shell
        "dash-to-panel@jderose9.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" ];
    };
    "org/gnome/shell/extensions/user-theme" = { name = "Pop-dark"; };
    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = true;
      snap-to-grid = true;
      tile-by-default = true;
    };
    "org/gnome/shell/extensions/dash-to-panel" = {
      appicon-padding = 4;
      panel-size = 36;
    };
    "org/gnome/desktop/sound" = { theme-name = "Pop"; };
    "org/gnome/desktop/input-sources" = {
      sources = map mkTuple [ [ "xkb" "gb" ] [ "ibus" "mozc-jp" ] ];
      xkb-options = [ "compose:ralt" ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Office" "Utilities" ];
    };
    "org/gnome/desktop/app-folders/folders/Office" = {
      name = "Office";
      translate = true;
      categories = [ "Office" ];
    };
    "org/gnome/desktop/app-folders/folders/Utilities" = {
      name = "Utilities";
      translate = true;
      categories = [ "Utility" "X-GNOME-Utilities" "System" ];
    };

    # key bindings for pop-shell
    "org/gnome/mutter/wayland/keybindings" = { restore-shortcuts = [ ]; };
    "org/gnome/shell/keybindings" = {
      open-application-menu = [ ];
      toggle-message-tray = [ "<Super>v" ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      minimize = [ "<Super>comma" ];
      toggle-maximized = [ "<Super>m" ];

      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];

      move-to-monitor-left = [ "<Shift><Super>Left" "<Shift><Super>${left}" ];
      move-to-workspace-down = [ "<Shift><Super>Down" "<Shift><Super>${down}" ];
      move-to-workspace-up = [ "<Shift><Super>Up" "<Shift><Super>${up}" ];
      move-to-monitor-right =
        [ "<Shift><Super>Right" "<Shift><Super>${right}" ];

      switch-to-workspace-down =
        [ "<Primary><Super>Down" "<Primary><Super>${down}" ];
      switch-to-workspace-up =
        [ "<Primary><Super>Down" "<Primary><Super>${up}" ];
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ ];
      toggle-tiled-right = [ ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Super>Escape" ];
      home = [ "<Super>f" ];
      email = [ "<Super>e" ];
      www = [ "<Super>b" ];
      rotate-video-lock-static = [ ];
    };
  };
}
