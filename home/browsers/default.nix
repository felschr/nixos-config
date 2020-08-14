{ config, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./brave.nix
    ./chromium.nix
  ];
}
