{ config, pkgs, ... }:

{
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
}
