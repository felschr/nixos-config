{ config, lib, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "i915" ];

  # kaby lake
  boot.kernelParams = [ "i915.enable_guc=3" ];

  environment.variables = {
    VDPAU_DRIVER =
      lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    intel-media-driver
    intel-compute-runtime
  ];
}
