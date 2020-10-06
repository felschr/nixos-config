{ config, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    setLdLibraryPath = true;
    package = pkgs.mesa_drivers;
  };
  hardware.deviceTree = {
    overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
  };
  services.xserver = {
    enable = false;
    videoDrivers = [ "modesetting" ];
  };
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=192
  '';
}
