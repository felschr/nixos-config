{ lib, ... }:

{
  imports = [
    ../../hardware/base.nix
    ../../hardware/bluetooth.nix
    ../../hardware/xbox.nix
    ../../hardware/steam.nix
    ../../hardware/ledger.nix
    ../../system/desktop.nix
    ../../system/printing/home.nix
    ../../system/gaming.nix
    ../../desktop
    ../../desktop/cosmic.nix
    ../../virtualisation/containers.nix
    ../../virtualisation/podman.nix
    ../../virtualisation/libvirt.nix
    ../../modules/systemdNotify.nix
    ../../services/samba/home-pc.nix
    ../../services/restic/home-pc.nix
    ../../services/pcscd.nix
    ../../services/open-webui.nix
  ];

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

  services.tailscale.extraUpFlags = [
    "--accept-routes"
    "--operator=felschr"
    "--advertise-routes=192.168.1.0/24"
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
  system.stateVersion = "24.11";
}
