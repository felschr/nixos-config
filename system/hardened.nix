{ config, modulesPath, pkgs, lib, ... }:

with lib; {
  imports = [ "${modulesPath}/profiles/hardened.nix" ];

  # @TODO hardened kernel causes Bluetooth issues
  boot.kernelPackages = mkOverride 900 pkgs.linuxPackages;

  # Xbox Controller not working via Bluetooth if enabled
  security.lockKernelModules = mkOverride 900 false;

  boot.loader.systemd-boot.editor = mkDefault false;

  # scudo causes Firefox & Tor Browser segfaults
  environment.memoryAllocator.provider = mkOverride 900 "libc";

  security.allowSimultaneousMultithreading = mkOverride 900 true;
}
