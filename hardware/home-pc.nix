# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules =
    [ "nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5830e9b3-260b-451c-bfee-2028c64c6199";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd:1" "noatime" ];
  };

  boot.initrd.luks.devices."enc".device =
    "/dev/disk/by-uuid/1dd848b6-cd7f-4959-8500-a03ffdaeae66";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/5830e9b3-260b-451c-bfee-2028c64c6199";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd:1" "noatime" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/5830e9b3-260b-451c-bfee-2028c64c6199";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress-force=zstd:1" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/17B2-42C2";
    fsType = "vfat";
  };

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
