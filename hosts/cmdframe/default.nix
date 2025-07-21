{ inputs, config, ... }:

{
  imports = [
    ./disk-config.nix
    ../../hardware/base.nix
    ../../hardware/bluetooth.nix
    ../../system/laptop.nix
    ../../system/printing/home.nix
    ../../desktop
    ../../desktop/cosmic.nix
    ../../virtualisation/containers.nix
    ../../virtualisation/podman.nix
    ../../virtualisation/libvirt.nix
    ../../modules/systemdNotify.nix
    ../../services/open-webui.nix
    inputs.seven-modules.nixosModules.seven
  ];

  age.secrets.wireguard-seven-cmdframe-key = {
    file = ../../secrets/wireguard/seven/cmdframe.key.age;
    owner = "systemd-network";
  };

  services.fprintd.enable = true;

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
  ];

  services.ollama = {
    acceleration = "rocm";
    rocmOverrideGfx = "11.5.0";
  };

  seven = {
    enable = true;
    wireguard = {
      addresses = [
        "198.18.1.241/15"
        "fd00:5ec::1f1/48"
      ];
      privateKeyFile = config.age.secrets.wireguard-seven-cmdframe-key.path;
    };
  };

  systemd.notify.enable = true;
  systemd.notify.method = "libnotify";
  systemd.notify.libnotify.user = "felschr";

  # only change this when specified in release notes
  system.stateVersion = "25.05";
}
