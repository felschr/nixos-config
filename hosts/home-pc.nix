{ ... }:

{
  imports = [
    ../hardware/base.nix
    ../hardware/gpu-amd.nix
    ../hardware/bluetooth.nix
    ../hardware/xbox.nix
    ../hardware/steam.nix
    ../hardware/ledger.nix
    ../system/desktop.nix
    ../system/printing/home.nix
    ../system/gaming.nix
    ../desktop
    ../virtualisation/libvirt.nix
    ../virtualisation/podman.nix
    ../modules/systemdNotify.nix
    ../services/samba/home-pc.nix
    ../services/restic/home-pc.nix
    ../services/pcscd.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.memtest86.enable = true;

  # running binaries for other architectures
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" "wasm64-wasi" "wasm32-wasi" ];

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
  system.stateVersion = "23.05";
}
