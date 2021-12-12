{ config, pkgs, ... }:

{
  imports = [
    ./hardware/base.nix
    ./hardware/gpu-nvidia.nix
    ./hardware/steam.nix
    ./hardware/ledger.nix
    ./system
    ./system/gaming.nix
    ./desktop
    ./virtualisation/docker.nix
    ./services/syncthing/felix-nixos.nix
    ./services/pcscd.nix
  ];

  # declarative config broken atm: https://github.com/NixOS/nixpkgs/issues/91986
  swapDevices = [{
    device = "/swap/swapfile";
    size = 8192;
  }];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.memtest86.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "p7zip-16.02" # currently used by lutris
  ];

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  programs.adb.enable = true;

  programs.zsh.enable = true;

  networking.firewall.allowedTCPPorts = [
    54950 # transmission
  ];
  networking.firewall.allowedUDPPorts = [
    24727 # AusweisApp2
  ];
  networking.hosts = {
    # force IPv4, see: https://github.com/transmission/transmission/issues/407
    "87.98.162.88" = [ "portcheck.transmissionbt.com" ];
  };

  services.printing.drivers = with pkgs; [ epson-escpr ];

  # only change this when specified in release notes
  system.stateVersion = "21.11";
}
