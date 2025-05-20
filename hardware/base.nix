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

  # prevents `systemd-vconsole-setup` failing during systemd initrd
  console.earlySetup = true;
  systemd.services.systemd-vconsole-setup.unitConfig.After = "local-fs.target";

  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;
}
