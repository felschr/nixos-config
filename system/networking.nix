{ config, lib, ... }:

let
  isAdguardHost = config.services.adguardhome.enable;
  nameservers = {
    local = [
      "127.0.0.1"
      "::1"
    ];
    remote = [
      # LAN
      "192.168.1.102#dns.felschr.com"
      "fd1c:ca95:d74d::102#dns.felschr.com"

      # Tailnet
      "100.97.32.60#dns.felschr.com"
      "fd7a:115c:a1e0::a0a1:203c#dns.felschr.com"
    ];
  };
in
{
  networking.nameservers = if isAdguardHost then nameservers.local else nameservers.remote;

  networking.nftables.enable = true;
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "tailscale0" ];
  };

  services.dnsmasq.enable = false;
  services.resolved = {
    enable = true;
    dnsovertls = if isAdguardHost then "opportunistic" else "true";
    fallbackDns = [
      "194.242.2.2#dns.mullvad.net"
      "194.242.2.4#base.dns.mullvad.net"
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    extraConfig = lib.mkIf isAdguardHost ''
      DNSStubListener=no
    '';
  };
}
