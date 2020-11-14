{ config, pkgs, ... }:

{
  networking.wireguard.enable = true;
  networking.iproute2.enable = true;

  services.mullvad-vpn.enable = true;
}
