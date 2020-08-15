{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    ./hardware/base.nix
    ./hardware/gpu-bumblebee.nix
    ./system
    ./desktop
    ./virtualisation/docker.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "pilot1-nixos"; # Define your hostname.

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
    users.felschr = import ./home/felschr-work.nix;
  };

  # only change this when specified in release notes
  system.stateVersion = "20.03";

  system.autoUpgrade = {
    enable = true;
    dates = "10:00";
  };
}
