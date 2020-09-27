{ config, pkgs, ... }:

{
  imports = [
    # ./hardware/base.nix
    # ./system
    ./system/nix.nix
    ./system/i18n.nix
    ./services/jellyfin.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # rpi4 base config
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = [
    "console=ttyAMA0,115200"
    "console=tty1"
  ];
  hardware.enableAllFirmware = true;

  programs.zsh.enable = true;

  services.openssh.enable = true;

  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "disk" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.felschr = import ./home/felschr-rpi4.nix;
  };

  # only change this when specified in release notes
  system.stateVersion = "20.09";

  system.autoUpgrade.enable = true;
}
