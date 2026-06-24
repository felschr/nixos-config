{
  inputs,
  config,
  pkgs,
  ...
}:

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
    ../../services/llm.nix
  ];

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
    package = pkgs.unstable.ollama-rocm;
    rocmOverrideGfx = "11.5.0";
  };

  systemd.notify.enable = true;
  systemd.notify.method = "libnotify";
  systemd.notify.libnotify.user = "felschr";

  # only change this when specified in release notes
  system.stateVersion = "25.05";
}
