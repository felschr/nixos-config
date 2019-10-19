{ config, pkgs, ... }:

{
  # Graphics drivers
  hardware.bumblebee.enable = true;
  hardware.opengl.driSupport32Bit = true;
}
