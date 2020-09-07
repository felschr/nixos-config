{ config, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./chromium.nix
  ];
}
