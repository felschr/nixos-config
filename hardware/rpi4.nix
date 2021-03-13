{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."enc-media".device =
    "/dev/disk/by-uuid/47158a41-995a-45d5-b7e1-1dc6e1868be7";

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/2441d724-7f8e-4bbb-a50f-9074f3d0d3f1";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/media/.snapshots" = {
    device = "/dev/disk/by-uuid/2441d724-7f8e-4bbb-a50f-9074f3d0d3f1";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress-force=zstd" "noatime" ];
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
