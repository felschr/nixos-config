{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.tailscale;
  tailscaleInterface = cfg.interfaceName;
  inherit (config.networking) hostName;
  tailnetHost = "${hostName}.tail05275.ts.net";
in
{
  networking.wireguard.enable = true;
  networking.firewall.trustedInterfaces = [ tailscaleInterface ];

  systemd.network = {
    # Fixes issues with other systemd networks when tailscale exist nodes are used
    config.networkConfig = {
      ManageForeignRoutes = false;
      ManageForeignRoutingPolicyRules = false;
    };
    wait-online.ignoredInterfaces = [ "tailscale0" ];
  };

  services.networkd-dispatcher = {
    enable = true;
    rules = {
      # exclude LANs from tailscale subnet routes (when using `--accept-routes`)
      "50-tailscale-exclude-lan-routes" = {
        onState = [ "routable" ];
        script = ''
          #!${pkgs.runtimeShell}
          # shellcheck disable=SC2010

          lan_interfaces=$(ls /sys/class/net | grep -E '^(enp|eth|wlp)')
          if [[ "$lan_interfaces" == "" ]]; then exit 0; fi
          echo "$lan_interfaces" | while IFS= read -r lan_if; do
            for ipv in 4 6; do
              subnets=$(${pkgs.iproute2}/bin/ip -"$ipv" route show dev "$lan_if" proto kernel | cut -f1 -d' ' | grep '/')
              if [[ "$subnets" == "" ]]; then break; fi
              echo "$subnets" | while IFS= read -r subnet; do
                if ${pkgs.iproute2}/bin/ip -"$ipv" route show table 52 | grep -q "$subnet dev tailscale0"; then
                  ${pkgs.iproute2}/bin/ip -"$ipv" route del "$subnet" dev tailscale0 table 52
                  ${pkgs.iproute2}/bin/ip -"$ipv" route add throw "$subnet" table 52
                fi
              done
            done
          done
        '';
      };
      # UDP throughput improvements
      # https://tailscale.com/kb/1320/performance-best-practices?q=gro#linux-optimizations-for-subnet-routers-and-exit-nodes
      "50-tailscale-rx-udp-gro-forwarding" = {
        onState = [ "routable" ];
        script = ''
          for dev in $(${pkgs.iproute2}/bin/ip route show 0/0 | cut -f5 -d' '); do
            ${lib.getExe pkgs.ethtool} -K "$dev" rx-udp-gro-forwarding on rx-gro-list off
          done
        '';
      };
    };
  };

  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "client";
    extraUpFlags = [
      "--reset"
      "--exit-node-allow-lan-access"
      "--exit-node=de-fra-wg-106.mullvad.ts.net"
    ];
  };

  systemd.services.tailscaled = {
    serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=auto" ];
    after = [
      "network-online.target"
      "systemd-resolved.service"
    ];
  };

  # call taiscale up without --auth-key
  systemd.services.tailscaled-autoconnect = lib.mkIf (cfg.authKeyFile == null) {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script =
      ''
        status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
        if [[ $status != Connected* ]]; then
          ${cfg.package}/bin/tailscale up
        fi

        # some options cannot be set immediately
        ${cfg.package}/bin/tailscale up ${lib.escapeShellArgs cfg.extraUpFlags}

        ${cfg.package}/bin/tailscale cert ${tailnetHost}
      ''
      + lib.optionalString config.services.nginx.enable ''
        chown nginx:nginx /var/lib/tailscale/certs/${tailnetHost}.{key,crt}
      '';
  };

  services.nginx.virtualHosts.${tailnetHost} = {
    sslCertificate = "/var/lib/tailscale/certs/${tailnetHost}.crt";
    sslCertificateKey = "/var/lib/tailscale/certs/${tailnetHost}.key";
  };

  # TODO Tailscale Mullvad exit nodes currently don't support IPv6 and this is
  # causing issues with nginx (proxy pass) requests timing out and high CPU load.
  # Until Mullvad exit nodes support IPv6, we'll just disable IPv6 for nginx.
  services.nginx.resolver.ipv6 = false;
}
