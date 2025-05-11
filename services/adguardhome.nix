{ config, ... }:

let
  cfg = config.services.adguardhome;
  host = "dns.felschr.com";
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
        port_dns_over_tls = 853;
        port_dns_over_quic = 853;
        port_dnscrypt = 0;
        force_https = false; # handled by nginx
        allow_unencrypted_doh = true;
        strict_sni_check = false;
        certificate_path = "/run/credentials/adguardhome.service/fullchain.pem";
        private_key_path = "/run/credentials/adguardhome.service/key.pem";
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
    };
  };

  systemd.services.adguardhome.serviceConfig = {
    LoadCredential = [
      "fullchain.pem:/var/lib/acme/${host}/fullchain.pem"
      "key.pem:/var/lib/acme/${host}/key.pem"
    ];
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString cfg.port}";
  };

  networking.firewall.allowedTCPPorts = [ 853 ];
  networking.firewall.allowedUDPPorts = [ 853 ];
}
