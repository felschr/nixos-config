{ config, ... }:

let
  cfg = config.services.adguardhome;
  cfgAuth = config.services.caddy-authelia;
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
          # Quad9 without threat blocking - filtering is done by AdGuard Home below
          "https://dns10.quad9.net/dns-query"
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
        force_https = false; # handled by caddy
        allow_unencrypted_doh = true;
        strict_sni_check = false;
        certificate_path = "${config.security.acme.certs."${host}".directory}/fullchain.pem";
        private_key_path = "${config.security.acme.certs."${host}".directory}/key.pem";
      };
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
          enabled = true;
        }
        {
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          enabled = true;
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
      "caddy"
    ];
  };

  # Caddy shares the DNS-over-TLS certificate with AdGuard Home (used for port 853),
  # so the cert is issued via security.acme instead of Caddy's automatic HTTPS.
  security.acme.certs."${host}" = {
    group = "caddy";
    dnsProvider = "cloudflare";
    credentialFiles.CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare.path;
    reloadServices = [ "caddy.service" ];
  };

  services.caddy.virtualHosts.${host} = {
    useACMEHost = host;
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      # DoH must stay unauthenticated (used by the routers); only the UI is
      # behind Authelia, so forward_auth lives inside the UI catch-all.
      @doh path /dns-query /dns-query/*
      handle @doh {
        reverse_proxy 127.0.0.1:${toString ports.doh}
      }
      handle {
        forward_auth ${cfgAuth.host}:${toString cfgAuth.port} {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }
        reverse_proxy 127.0.0.1:${toString cfg.port}
      }
    '';
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
