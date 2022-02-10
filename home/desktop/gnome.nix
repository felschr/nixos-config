{ config, lib, pkgs, ... }:

let
  left = "h";
  down = "j";
  up = "k";
  right = "l";
in {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "pop-shell@system76.com"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com" # works better with pop-shell
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" ];
    };
    "org/gnome/shell/extensions/user-theme" = { name = "Adwaita-dark"; };
    "org/gnome/shell/extensions/pop-shell" = {
      tile-by-default = true;
      snap-to-grid = true;
      smart-gaps = true;
      show-title = false;
      active-hint = false;
    };
    "org/gnome/desktop/sound" = { theme-name = "freedesktop"; };
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
      toggle-overview = [ ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      minimize = [ "<Super>comma" ];
      maximize = [ ];
      unmaximize = [ ];
      toggle-maximized = [ "<Super>m" ];
      toggle-fullscreen = [ "<Super>f" ];
      toggle-on-all-workspaces = [ "<Super>p" ];

      switch-to-workspace-left =
        [ "<Primary><Super>Left" "<Primary><Super>${left}" ];
      switch-to-workspace-right =
        [ "<Primary><Super>Right" "<Primary><Super>${right}" ];
      switch-to-workspace-down = [ ];
      switch-to-workspace-up = [ ];

      move-to-workspace-left = [ "<Shift><Super>Left" "<Shift><Super>${left}" ];
      move-to-workspace-right =
        [ "<Shift><Super>Right" "<Shift><Super>${right}" ];
      move-to-workspace-down = [ ];
      move-to-workspace-up = [ ];

      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-monitor-down = [ ];
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ ];
      toggle-tiled-right = [ ];
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-last-coordinates = mkTuple [ 53.2593 10.4 ];
      night-light-temperature = mkUint32 3700;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Super>Escape" ];
      home = [ "<Super>f" ];
      email = [ "<Super>e" ];
      www = [ "<Super>b" ];
      terminal = [ "<Super>t" ];
      rotate-video-lock-static = [ ];
    };
  };
}
