{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./fonts.nix ./sound.nix ./vpn.nix ./printing ];
}
