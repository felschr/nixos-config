{ config, pkgs, ... }:

{
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
}
