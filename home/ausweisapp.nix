{ config, pkgs, ... }:

with pkgs;
{
  home.packages = [ ausweisapp ];
}
