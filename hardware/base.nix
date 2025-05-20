{ lib, pkgs, ... }:

{
  imports = [
    ./firmware.nix
    ./solokeys.nix
    ./zsa.nix
  ];

  boot.supportedFilesystems = lib.mkDefault [ "btrfs" ];
  boot.kernelPackages = lib.mkOverride 800 pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;

  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;
}
