{ config, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk

      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl

      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      amdvlk

      vaapiIntel
      libvdpau-va-gl
      vaapiVdpau
    ];
  };

  environment.variables.AMD_VULKAN_ICD = "RADV";
}
