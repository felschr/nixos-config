{ config, pkgs, ... }:

{
  # Graphics drivers
  hardware.bumblebee.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.opengl = {
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
