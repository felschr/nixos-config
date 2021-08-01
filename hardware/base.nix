{ config, pkgs, ... }:

{
  imports = [ ./planck.nix ];

  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = { Enable = "Source,Sink,Media,Socket"; };
  };
}
