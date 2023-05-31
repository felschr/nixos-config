{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
    "rtsx_usb_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/70f03d67-e248-42f6-a204-c02e4f180531";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd:1" "noatime" ];
  };

  boot.initrd.luks.devices."enc".device =
    "/dev/disk/by-uuid/d3b12d0e-7e8e-4130-9a8f-680abcdc9682";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/70f03d67-e248-42f6-a204-c02e4f180531";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd:1" "noatime" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/70f03d67-e248-42f6-a204-c02e4f180531";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress-force=zstd:1" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/95FC-D4E5";
    fsType = "vfat";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
