{ config, pkgs, ... }:

{
  # Graphics drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.screenSection = ''
    Option "metamodes" "1920x1080_120 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
  '';

  hardware.opengl = {
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
  };
}
