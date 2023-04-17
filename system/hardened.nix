{ config, modulesPath, pkgs, lib, ... }:

with lib; {
  imports = [ "${modulesPath}/profiles/hardened.nix" ];

  # Xbox Controller not working via Bluetooth if enabled
  security.lockKernelModules = mkOverride 0 false;

  boot.loader.systemd-boot.editor = mkDefault false;

  # scudo causes Firefox & Tor Browser segfaults
  environment.memoryAllocator.provider = "libc";

  security.allowSimultaneousMultithreading = mkOverride 0 true;
}
