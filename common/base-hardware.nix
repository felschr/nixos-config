{ config, pkgs, ... }:

{
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-partlabel/nixos";
      preLVM = true;
      allowDiscards = true;
    }
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.extraConfig = "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

  # Sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  # USB devices
  hardware.u2f.enable = true;
}

