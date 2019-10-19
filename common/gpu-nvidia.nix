{ config, pkgs, ... }:

{
  # Graphics drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;
}
