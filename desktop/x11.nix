{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "gb";
  services.xserver.xkb.options = "eurosign:e";
}
