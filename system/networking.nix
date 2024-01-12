{ lib, ... }:

{
  networking.nameservers = [ "127.0.0.1" "::1" ];

  services.resolved = {
    enable = true;
    # don't use fallback resolvers
    fallbackDns = [ "127.0.0.1" "::1" ];
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];

      ipv6_servers = true;
      require_nolog = true;
      require_dnssec = true;
      http3 = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key =
          "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      server_names = [ "mullvad-doh" "controld-unfiltered" ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = lib.mkForce "dnscrypt-proxy2";
  };
}
