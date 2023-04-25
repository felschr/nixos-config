{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gamemode ];

  programs.gamemode = {
    enable = true;
    settings = {
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode stopped'";
      };
    };
  };

  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;

  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;

  boot.kernel.sysctl."vm.max_map_count" = 2147483642;
}
