{ config, ... }:

let
  cfg = config.services.adguardhome;
  host = "dns.felschr.com";

  ports = {
    plain = 53;
    tls = 853;
    doh = 10443;
  };
in
{
  services.adguardhome = {
    enable = true;
    settings = {
      dns = {
        upstream_dns = [
          "https://dns.mullvad.net/dns-query"
        ];
        fallback_dns = [
          "https://1.1.1.1/dns-query"
        ];
        enable_dnssec = true;
      };
      # encryption
      tls = {
        enabled = true;
        server_name = host;
        port_https = 0;
        port_dns_over_tls = ports.tls;
        port_dns_over_quic = ports.tls;
        port_dnscrypt = 0;
        force_https = false; # handled by nginx
        allow_unencrypted_doh = true;
        strict_sni_check = false;
        certificate_path = "${config.security.acme.certs."${host}".directory}/fullchain.pem";
        private_key_path = "${config.security.acme.certs."${host}".directory}/key.pem";
      };
      # HINT: users needs to be set up manually:
      # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#password-reset
      # users = [ { name = "felschr"; } ];
      querylog = {
        enabled = true;
        interval = "24h";
      };
      statistics = {
        enabled = true;
        interval = "24h";
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        safe_search.enabled = true;
      };
      filters = [
        {
          name = "HaGeZi Multi Pro";
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          enabled = true;
        }
        {
          name = "OISD (Big)";
          url = "https://big.oisd.nl";
          enabled = false;
        }
        {
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          enabled = false;
        }
      ];
      whitelist_filters = [
        {
          name = "HaGeZi Whitelist-Referral";
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-referral.txt";
          enabled = true;
        }
        {
          name = "Hagezi Whitelist-UrlShortener";
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-urlshortener.txt";
          enabled = true;
        }
      ];
      log.verbose = true;
    };
  };

  # AdGuardHome's built-in DoH gives me Bad Request responses for some reason
  # So, I instead use `doh-server` as a proxy for now.
  services.doh-server = {
    enable = true;
    settings = {
      listen = [ ":${toString ports.doh}" ];
      upstream = [ "udp:127.0.0.1:${toString ports.plain}" ];
    };
  };

  systemd.services.adguardhome.serviceConfig = {
    SupplementaryGroups = [
      "acme"
      "nginx"
    ];
  };

  services.nginx = {
    virtualHosts."${host}" = {
      enableACME = true;
      forceSSL = true;
      http3 = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
          proxyWebsockets = true;
        };
        "/dns-query" = {
          proxyPass = "http://localhost:${toString ports.doh}";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    53 # Plain DNS
    853 # DNS over TLS / QUIC
  ];
  networking.firewall.allowedUDPPorts = [
    53 # Plain DNS
    853 # DNS over TLS / QUIC
  ];
}
