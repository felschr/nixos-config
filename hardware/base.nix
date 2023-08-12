{ lib, pkgs, ... }:

{
  imports = [ ./firmware.nix ./planck.nix ];

  boot.supportedFilesystems = lib.mkDefault [ "btrfs" ];
  boot.kernelPackages = lib.mkOverride 800 pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;
}
