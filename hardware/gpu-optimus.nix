{ config, pkgs, ... }:

{
  # Graphics drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.optimus_prime.enable = true;
  hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:2:0:0";
  hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
}
