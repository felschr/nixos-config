{ lib, pkgs, ... }:

{
  boot.supportedFilesystems = lib.mkDefault [ "btrfs" ];
  boot.kernelPackages = lib.mkOverride 800 pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;

  boot.plymouth.enable = true;

  # prevents `systemd-vconsole-setup` failing during systemd initrd
  console.earlySetup = true;
  systemd.services.systemd-vconsole-setup.unitConfig.After = "local-fs.target";
}
