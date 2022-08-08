{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7bb1e67d-8c6f-4ace-b8e7-b09cdfd82cab";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd:1" "noatime" ];
  };

  boot.initrd.luks.devices."enc".device =
    "/dev/disk/by-uuid/d163376b-a038-4196-8ef5-7c7fb5508f0c";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7bb1e67d-8c6f-4ace-b8e7-b09cdfd82cab";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd:1" "noatime" ];
  };

  fileSystems."/.swap" = {
    device = "/dev/disk/by-uuid/7bb1e67d-8c6f-4ace-b8e7-b09cdfd82cab";
    fsType = "btrfs";
    options = [ "subvol=@swap" "nodatacow" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/7bb1e67d-8c6f-4ace-b8e7-b09cdfd82cab";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress-force=zstd:1" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9ECA-C9A7";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/.swap/swapfile";
    size = 4096;
  }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
