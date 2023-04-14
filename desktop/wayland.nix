{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ wl-clipboard ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
