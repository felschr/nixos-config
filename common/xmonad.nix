{ config, pkgs, ... }:

{
  # Enable xmonad
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.default = "xmonad";
  services.xserver.windowManager.xmonad.enable = true;
}
