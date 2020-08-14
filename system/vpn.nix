{ config, pkgs, ... }:

{
  # workaround for https://github.com/NixOS/nixpkgs/issues/91923
  networking.iproute2.enable = true;

  services.mullvad-vpn.enable = true;
}
