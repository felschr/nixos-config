{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    ./common/base-hardware.nix
    ./common/gpu-bumblebee.nix
    ./common/planck.nix
    ./common/system.nix
    ./common/nix.nix
    ./common/i18n.nix
    ./common/x11.nix
    ./common/gtk.nix
    ./common/gnome.nix
    ./common/docker.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "pilot1-nixos"; # Define your hostname.

  virtualisation.virtualbox.host.enable = true;

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.logitech.enable = true;
  hardware.logitech.enableGraphical = true;

  services.tlp.enable = true;

  programs.adb.enable = true;

  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "disk" "vboxusers" ];
    shell = pkgs.fish;
  };

  home-manager.users.felschr = import ./home/felschr-work.nix;
  
  # only change this when specified in release notes
  system.stateVersion = "19.09";

  system.autoUpgrade = {
    enable = true;
    dates = "10:00";
  };
}
