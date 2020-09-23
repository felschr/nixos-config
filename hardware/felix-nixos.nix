{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9ef41d63-a7ad-406d-8c2b-5ad3fb4c0ea6";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd" "noatime" ];
  };

  boot.initrd.luks.devices."enc".device =
    "/dev/disk/by-uuid/6f4f3ce1-57fd-4ec3-bb9d-7847853d2dcf";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9ef41d63-a7ad-406d-8c2b-5ad3fb4c0ea6";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/9ef41d63-a7ad-406d-8c2b-5ad3fb4c0ea6";
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
    neededForBoot = true;
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/9ef41d63-a7ad-406d-8c2b-5ad3fb4c0ea6";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5C20-4516";
    fsType = "vfat";
  };

  swapDevices = [ ];

}
