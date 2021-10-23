{ config, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    setLdLibraryPath = true;
    package = pkgs.mesa_drivers;
  };
  hardware.raspberry-pi."4".fkms-3d.enable = true;
}
