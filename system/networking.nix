{ config, lib, pkgs, ... }:

{
  services.resolved.enable = false;

  networking = {
    nameservers = [ "127.0.0.1" "::1" ];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];

      ipv6_servers = true;
      require_nolog = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key =
          "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      server_names = [
        "mullvad-adblock-doh"
        "dnscrypt-de-blahdns-ipv4"
        "dnscrypt-de-blahdns-ipv6"
        "adfree.usableprivacy.net"
        "adfree.usableprivacy.net-ipv6"
        "controld-block-malware-ad"
      ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = lib.mkForce "dnscrypt-proxy2";
  };

  # prefer IPv6
  environment.etc."gai.conf".text = ''
    label ::1/128       0
    label ::/0          1
    label 2002::/16     2
    label ::/96         3
    label ::ffff:0:0/96 4
  '';
}
