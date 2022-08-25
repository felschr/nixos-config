{ config, pkgs, ... }:

{
  programs.gamemode.enable = true;

  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;

  # fix for Star Citizen
  boot.kernel.sysctl."vm.max_map_count" = 16777216;
}
