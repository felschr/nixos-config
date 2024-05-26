{ config, pkgs, ... }:

with pkgs;
{
  home.packages = [ AusweisApp2 ];
}
