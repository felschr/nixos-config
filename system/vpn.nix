{ config, pkgs, ... }:

{
  networking.wireguard.enable = true;

  # TODO fix for https://github.com/NixOS/nixpkgs/issues/113589
  networking.firewall.checkReversePath = "loose";

  services.mullvad-vpn.enable = true;

  # set some options after every daemon start
  # to avoid accidentally leaving unsafe settings
  systemd.services."mullvad-daemon".postStart = ''
    while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null; do sleep 1; done
    ${pkgs.mullvad}/bin/mullvad always-require-vpn set on
    ${pkgs.mullvad}/bin/mullvad dns set default \
      --block-ads --block-trackers --block-malware
    ${pkgs.mullvad}/bin/mullvad lan set allow
    ${pkgs.mullvad}/bin/mullvad tunnel ipv6 set on
    ${pkgs.mullvad}/bin/mullvad relay set tunnel-protocol wireguard
    ${pkgs.mullvad}/bin/mullvad relay set location de dus
  '';
}
