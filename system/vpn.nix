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
  certDir = "/var/lib/tailscale-certs";
  certFile = "${certDir}/${tailnetHost}.crt";
  keyFile = "${certDir}/${tailnetHost}.key";

  # subnets:
  tailnet = {
    v4 = "100.64.0.0/10";
    v6 = "fd7a:115c:a1e0::/48";
  };
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
    permitCertUid = lib.mkIf config.services.caddy.enable "caddy";
    extraUpFlags = [
      "--reset"
      "--exit-node-allow-lan-access"
      "--exit-node=de-fra-wg-103.mullvad.ts.net."
    ];
  };

  systemd.services.tailscaled = {
    serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=auto" ];
    # NixOS warns when a service is ordered after network-online.target
    # but doesn't depend on it
    wants = [ "network-online.target" ];
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
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "5min";
      Restart = "on-failure";
      RestartSec = "30s";
    };
    script = ''
      status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
      if [[ $status != Connected* ]]; then
        ${cfg.package}/bin/tailscale up --timeout=20s || true
      fi

      # some options cannot be set immediately
      # retry because tailscaled may still be starting up (e.g. an exit node
      # hostname cannot be resolved until tailscaled has loaded the netmap)
      attempt=0
      while ! ${cfg.package}/bin/tailscale up --timeout=20s ${lib.escapeShellArgs cfg.extraUpFlags}; do
        attempt=$((attempt + 1))
        if [[ $attempt -ge 10 ]]; then
          echo "tailscaled-autoconnect: giving up after $attempt attempts"
          exit 1
        fi
        sleep 2
      done
    '';
  };

  # Tailscale certificates are publicly trusted but the ts.net hostname has no
  # public DNS record, so Caddy's default ACME issuance can never validate it.
  # Issue the cert via the tailscale daemon instead and let the vhost use it.
  systemd.services.tailscale-cert = lib.mkIf config.services.caddy.enable {
    after = [
      "tailscaled.service"
      "tailscaled-autoconnect.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "tailscale-certs";
      StateDirectoryMode = "0750";
      # root:caddy so the caddy service can read the key
      Group = "caddy";
      UMask = "0027";
      Restart = "on-failure";
      RestartSec = "30s";
    };
    script = ''
      # remove stray certs the old autoconnect script wrote to /
      rm -f /${tailnetHost}.crt /${tailnetHost}.key
      ${cfg.package}/bin/tailscale cert \
        --cert-file=${certFile} \
        --key-file=${keyFile} \
        ${tailnetHost}
      # tailscale writes the key 0600; make it group-readable for caddy
      chmod 0640 ${keyFile}
      # certmagic reloads changed cert files, but refresh caddy's view of the
      # renewed cert right away. --no-block queues the reload without waiting
      # for it (a plain reload here deadlocked this service against caddy's
      # After= dependency on us); try-reload fails fast when caddy is stopped;
      # the timeout guards against a wedged caddy process.
      ${pkgs.coreutils}/bin/timeout 30 ${config.systemd.package}/bin/systemctl --no-block try-reload caddy.service || true
    '';
  };

  # let caddy start (and get restarted during activation) after the cert exists
  systemd.services.caddy = lib.mkIf config.services.caddy.enable {
    after = [ "tailscale-cert.service" ];
    wants = [ "tailscale-cert.service" ];
  };

  systemd.timers.tailscale-cert = lib.mkIf config.services.caddy.enable {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  services.caddy.virtualHosts.${tailnetHost} = lib.mkIf config.services.caddy.enable {
    extraConfig = ''
      tls ${certFile} ${keyFile}
      respond 404
    '';
  };
}
