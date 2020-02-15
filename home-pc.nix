{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    ./common/base-hardware.nix
    ./common/gpu-nvidia.nix
    ./common/ledger.nix
    ./common/planck.nix
    ./common/system.nix
    ./common/nix.nix
    ./common/i18n.nix
    ./common/x11.nix
    ./common/gtk.nix
    ./common/gnome.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "felix-nixos";

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  programs.adb.enable = true;

  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ];
    shell = pkgs.fish;
  };

  home-manager.users.felschr = import ./home/felschr.nix;

  # only change this when specified in release notes
  system.stateVersion = "19.09";

  system.autoUpgrade.enable = true;
}
