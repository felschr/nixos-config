{ pkgs, ... }:

{
  environment.systemPackages =
    with pkgs;
    with gnomeExtensions;
    [
      dconf-editor
      gnome-tweaks
      zenity
      gnome-sound-recorder
      native-window-placement
      appindicator
      pop-shell
      gnome-bedtime
      tailscale-qs
    ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.input-sources]
    sources=[('xkb', 'gb'), ('xkb', 'mozc-jp')]

    [org.gnome.settings-daemon.plugins.color]
    night-light-enabled=true
    night-light-last-coordinates=(53.2593, 10.4)
    night-light-temperature=uint32 3700
  '';
  programs.xwayland.enable = true;

  # exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    gnome-system-monitor
    gnome-weather
    gnome-calendar
    gnome-maps
    gnome-contacts
    gnome-software
    totem
    epiphany
    evince
  ];
  programs.gnome-terminal.enable = false;
  programs.geary.enable = false;
}
