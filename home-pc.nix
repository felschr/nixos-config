{ config, pkgs, ... }:

{
  imports = [
    ./hardware/base.nix
    ./hardware/gpu-nvidia.nix
    ./hardware/ledger.nix
    ./system
    ./desktop
    ./virtualisation/docker.nix
    ./services/syncthing/felix-nixos.nix
    ./services/jellyfin.nix
    ./services/pcscd.nix
  ];

  swapDevices = [{ device = "/swap/swapfile"; }];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "p7zip-16.02" # currently used by lutris
  ];

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

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
    users.felschr = import ./home/felschr.nix;
  };

  # only change this when specified in release notes
  system.stateVersion = "20.03";

  system.autoUpgrade.enable = true;
}
