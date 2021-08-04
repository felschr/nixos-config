{ config, pkgs, ... }:

{
  # Graphics drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  services.xserver.screenSection = ''
    Option "metamodes" "1920x1080_120 +0+0 {AllowGSYNC=On, AllowGSYNCCompatible=On, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
  '';

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ libvdpau-va-gl vaapiVdpau ];
  };
}
