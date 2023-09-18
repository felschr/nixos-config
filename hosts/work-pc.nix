{ ... }:

{
  imports = [
    ../hardware/base.nix
    ../hardware/gpu-intel.nix
    ../hardware/bluetooth.nix
    ../system/desktop.nix
    ../system/printing/home.nix
    ../desktop
    ../virtualisation/containers.nix
    ../virtualisation/podman.nix
  ];

  # replace with regenerated hardware-configuration.nix
  boot.initrd.luks.devices = {
    enc = {
      device = "/dev/disk/by-partlabel/nixos";
      allowDiscards = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  programs.adb.enable = true;

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # only change this when specified in release notes
  system.stateVersion = "22.05";
}
