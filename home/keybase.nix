{ config, pkgs, ... }:

{
  services.keybase.enable = true;
  services.kbfs.enable = true;

  home.packages = [ pkgs.keybase-gui ];
}
