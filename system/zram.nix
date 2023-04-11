{ config, pkgs, lib, ... }:

with lib; {
  zramSwap.enable = mkDefault true;
  zramSwap.memoryPercent = mkDefault 100;
  zramSwap.memoryMax = mkDefault (16 * 1024 * 1024 * 1024);
  boot.kernel.sysctl."vm.swappiness" = mkDefault 100;
}
