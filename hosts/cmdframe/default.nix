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
    ../../hardware/probe-rs.nix
    ../../system/laptop.nix
    ../../system/printing/home.nix
    ../../desktop
    ../../desktop/cosmic.nix
    ../../virtualisation/containers.nix
    ../../virtualisation/podman.nix
    ../../virtualisation/libvirt.nix
    ../../modules/systemdNotify.nix
    ../../services/pcscd.nix
    ../../services/llm.nix
  ];

  services.fprintd.enable = true;

  # run felschr's user services (herdr server, collie bridge) at boot even
  # when logged out; see home/herdr.nix
  users.users.felschr.linger = true;

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

  age.secrets.firefox-site-data-exceptions = {
    file = ../../secrets/firefox/site-data-exceptions.toml.age;
    owner = "felschr";
    mode = "0400";
  };

  systemd.notify.enable = true;
  systemd.notify.method = "libnotify";
  systemd.notify.libnotify.user = "felschr";

  # only change this when specified in release notes
  system.stateVersion = "25.05";
}
