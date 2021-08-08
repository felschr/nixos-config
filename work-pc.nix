{ config, pkgs, ... }:

{
  imports = [
    ./hardware/base.nix
    ./hardware/gpu-bumblebee.nix
    ./system
    ./desktop
    ./virtualisation/docker.nix
  ];

  # replace with regenerated hardware-configuration.nix
  boot.initrd.luks.devices = {
    enc = {
      device = "/dev/disk/by-partlabel/nixos";
      allowDiscards = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.logitech.enable = true;
  hardware.logitech.enableGraphical = true;

  services.tlp.enable = true;

  programs.adb.enable = true;

  programs.zsh.enable = true;

  services.printing.drivers = with pkgs; [ epson-escpr ];

  # only change this when specified in release notes
  system.stateVersion = "21.05";
}
