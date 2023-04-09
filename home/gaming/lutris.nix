{ config, pkgs, lib, ... }:

{
  # TODO move into heroic.nix or rename lutris.nix
  home.packages = with pkgs; [ lutris heroic ];
}
