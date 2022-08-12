{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  # use xserver without display manager
  services.xserver.displayManager.startx.enable = true;
}
