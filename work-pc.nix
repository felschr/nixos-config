{ config, pkgs, ... }:

{
  imports = [
    ./hardware/base.nix
    ./hardware/gpu-bumblebee.nix
    ./system
    ./desktop
    ./virtualisation/docker.nix
  ];

  # replace with regenerated hardware-configuration.nix
  boot.initrd.luks.devices = {
    enc = {
      device = "/dev/disk/by-partlabel/nixos";
      allowDiscards = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.logitech.enable = true;
  hardware.logitech.enableGraphical = true;

  services.tlp.enable = true;

  programs.adb.enable = true;

  programs.zsh.enable = true;

  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "disk" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.felschr = import ./home/felschr-work.nix;
  };

  # only change this when specified in release notes
  system.stateVersion = "20.03";

  system.autoUpgrade = {
    enable = true;
    dates = "10:00";
  };
}
