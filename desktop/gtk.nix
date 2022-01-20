{ config, pkgs, ... }:

{
  services.dbus.packages = with pkgs; [ dconf ];
}
