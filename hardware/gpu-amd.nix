{ pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
    extraPackages32 = with pkgs.driversi686Linux; [ libvdpau-va-gl vaapiVdpau ];
  };

  environment.systemPackages = with pkgs; [ glxinfo vulkan-tools ];
}
