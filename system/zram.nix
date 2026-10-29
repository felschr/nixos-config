{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
{
  zramSwap.enable = mkDefault true;
  zramSwap.memoryPercent = mkDefault 100;
  zramSwap.memoryMax = mkDefault (16 * 1024 * 1024 * 1024);

  # zram is the only swap; 8 pages per fault is overhead
  boot.kernel.sysctl."vm.page-cluster" = mkDefault 0;
}
