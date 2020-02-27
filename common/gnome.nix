{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
    gnome3.gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator
  ];

  # Enable Gnome 3
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  environment.gnome3.excludePackages = with pkgs; [
    gnome3.geary
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.gnome-packagekit
    gnome3.epiphany
  ];
} 
