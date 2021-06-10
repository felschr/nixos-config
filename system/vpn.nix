{ config, pkgs, ... }:

{
  networking.wireguard.enable = true;

  # TODO fix for https://github.com/NixOS/nixpkgs/issues/113589
  networking.firewall.checkReversePath = "loose";

  services.mullvad-vpn.enable = true;
}
