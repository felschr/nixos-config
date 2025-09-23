{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}:

{
  imports = [ "${modulesPath}/profiles/hardened.nix" ];

  # @TODO hardened kernel causes Bluetooth issues
  boot.kernelPackages = lib.mkOverride 900 pkgs.linuxPackages;

  security = {
    apparmor.enable = lib.mkOverride 900 false;
    # Xbox Controller not working via Bluetooth if enabled
    lockKernelModules = lib.mkOverride 900 false;

    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
  };

  boot.loader.systemd-boot.editor = lib.mkDefault false;

  # scudo causes Firefox & Tor Browser segfaults
  environment.memoryAllocator.provider = lib.mkOverride 900 "libc";

  security.allowSimultaneousMultithreading = lib.mkOverride 900 true;
}
