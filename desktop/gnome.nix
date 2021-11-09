{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    with gnomeExtensions; [
      gnome.dconf-editor
      gnome.gnome-tweaks
      gnome.gnome-shell-extensions # required for user-theme
      appindicator
      pop-shell
    ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;
  # services.xserver.displayManager.defaultSession = "gnome-xorg";
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org/gnome/desktop/input-sources]
    sources=[('xkb', 'gb'), ('xkb', 'mozc-jp')]

    [org/gnome/mutter]
    experimental-features=['kms-modifiers']
  '';
  programs.xwayland.enable = true;

  # exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-weather
    gnome.gnome-calendar
    gnome.gnome-maps
    gnome.gnome-contacts
    gnome.gnome-software
    gnome.totem
    gnome.epiphany
  ];
  programs.gnome-terminal.enable = false;
  programs.geary.enable = false;
}
