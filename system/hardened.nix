{ config, modulesPath, pkgs, lib, ... }:

with lib; {
  imports = [ "${modulesPath}/profiles/hardened.nix" ];

  boot.loader.systemd-boot.editor = mkDefault false;

  # scudo causes Firefox & Tor Browser segfaults
  environment.memoryAllocator.provider = "libc";
}
