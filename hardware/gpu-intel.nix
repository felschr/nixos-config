{ config, lib, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "i915" ];

  # kaby lake
  boot.kernelParams = [ "i915.enable_guc=3" ];

  environment.variables = {
    VDPAU_DRIVER =
      lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.opengl = {
    extraPackages = with pkgs; [
      intel-vaapi-driver
      intel-media-driver
      intel-compute-runtime
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-vaapi-driver
      intel-media-driver
      libvdpau-va-gl
    ];
  };
}
