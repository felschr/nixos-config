{ inputs, config, ... }:

{
  imports = [
    ./disk-config.nix
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
    ../../services/llm.nix
    inputs.seven-modules.nixosModules.seven
  ];

  age.secrets.wireguard-seven-home-pc-key = {
    file = ../../secrets/wireguard/seven/home-pc.key.age;
    owner = "systemd-network";
  };

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

  services.ollama = {
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.1";
  };

  seven = {
    enable = true;
    wireguard = {
      addresses = [
        "198.18.1.239/15"
        "fd00:5ec::1ef/48"
      ];
      privateKeyFile = config.age.secrets.wireguard-seven-home-pc-key.path;
    };
  };

  systemd.notify.enable = true;
  systemd.notify.method = "libnotify";
  systemd.notify.libnotify.user = "felschr";

  # only change this when specified in release notes
  system.stateVersion = "24.11";
}
