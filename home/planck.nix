{ config, pkgs, ... }:

with pkgs;
{
  # udev rules for flashing the Planck (STM32F303CC) with probe-rs/RMK live
  # system-wide in ../hardware/probe-rs.nix
  home.packages = [ wally-cli ];
}
