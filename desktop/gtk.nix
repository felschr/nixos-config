{ config, pkgs, ... }:

{
  services.dbus.packages = with pkgs; [ gnome.dconf ];
}
