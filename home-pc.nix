{ config, pkgs, ... }:

{
  imports = [
    ./hardware/base.nix
    ./hardware/gpu-amd.nix
    ./hardware/steam.nix
    ./hardware/ledger.nix
    ./system
    ./system/gaming.nix
    ./desktop
    ./virtualisation/libvirt.nix
    ./virtualisation/docker.nix
    ./services/samba/home-pc.nix
    ./services/syncthing/home-pc.nix
    ./services/restic/home-pc.nix
    ./services/pcscd.nix
  ];

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
    58324 # transmission
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
