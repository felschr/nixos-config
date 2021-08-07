{ config, pkgs, ... }:

{
  programs.gamemode.enable = true;

  # fix for Star Citizen
  boot.kernel.sysctl."vm.max_map_count" = 16777216;
}
