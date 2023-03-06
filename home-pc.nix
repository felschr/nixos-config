{ config, pkgs, ... }:

{
  imports = [
    ./hardware/base.nix
    ./hardware/gpu-amd.nix
    ./hardware/bluetooth.nix
    ./hardware/steam.nix
    ./hardware/ledger.nix
    ./system/desktop.nix
    ./system/gaming.nix
    ./desktop
    ./virtualisation/libvirt.nix
    ./virtualisation/podman.nix
    ./modules/systemdNotify.nix
    ./services/samba/home-pc.nix
    ./services/restic/home-pc.nix
    ./services/pcscd.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.memtest86.enable = true;

  # cross-compilation support
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  programs.adb.enable = true;

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

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

  systemd.notify.enable = true;
  systemd.notify.method = "libnotify";
  systemd.notify.libnotify.user = "felschr";

  # only change this when specified in release notes
  system.stateVersion = "22.11";
}
