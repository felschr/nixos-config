{
  config,
  pkgs,
  lib,
  ...
}:

let
  isAdguardHost = config.services.adguardhome.enable;

  interfaces.lan = [
    "enp*"
    "eth*"
  ];

  lan = rec {
    IPv4Prefix = "192.168.1";
    IPv4CIDR = "${IPv4Prefix}.0/24";
    IPv6ULAPrefix = "fd1c:ca95:d74d";
    IPv6ULACIDR = "${IPv6ULAPrefix}::/48";
  };

  nameservers = {
    local = [
      "127.0.0.1"
      "::1"
    ];
    remote = [
      # LAN
      "${lan.IPv4Prefix}.102#dns.felschr.com"
      "${lan.IPv6ULAPrefix}::102#dns.felschr.com"

      # Tailnet
      "100.97.32.60#dns.felschr.com"
      "fd7a:115c:a1e0::a0a1:203c#dns.felschr.com"
    ];
  };
in
{
  networking = {
    useNetworkd = true;
    useDHCP = false;
    nameservers = if isAdguardHost then nameservers.local else nameservers.remote;
    nftables.enable = true;
    firewall.allowedUDPPorts = [
      5353 # mDNS
    ];
    networkmanager.dns = "systemd-resolved";
  };

  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "tailscale0" ];
    networks = {
      "10-lan" = {
        matchConfig.Name = interfaces.lan;
        domains = [ "local" ];
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = true;
          UseDomains = true;
        };
        linkConfig = {
          Multicast = true;
        };
      };
    };
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
    extraConfig = ''
      MulticastDNS=yes
      ${lib.optionalString isAdguardHost ''
        DNSStubListener=no
      ''}
    '';
  };

  # mDNS already handled by systemd-resolved
  services.avahi.enable = false;

  programs.mtr.enable = true;
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    dig
    wireguard-tools
  ];
}
