{ pkgs, ... }:

{
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
  programs.steam.package = pkgs.steam.override {
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/steam/fhsenv.nix
    extraLibraries =
      pkgs: with pkgs; [
        libxcrypt-legacy # Life Is Strange
      ];
  };
  programs.steam.gamescopeSession.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;

  boot.kernel.sysctl."vm.max_map_count" = 2147483642;
}
