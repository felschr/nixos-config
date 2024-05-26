{ config, pkgs, ... }:

with pkgs;
{
  home.packages = [ wally-cli ];
}
