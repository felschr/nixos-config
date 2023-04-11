{ config, pkgs, ... }:

{
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;
  zramSwap.memoryMax = 16 * 1024 * 1024 * 1024;
  boot.kernel.sysctl."vm.swappiness" = 100;
}
