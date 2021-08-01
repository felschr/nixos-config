{ config, pkgs, nixosConfig, ... }:

{
  imports = [ ./steam.nix ./lutris.nix ];

  programs.gamemode.enable = true;
}
