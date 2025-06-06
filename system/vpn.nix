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
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        for dev in $(${pkgs.iproute2}/bin/ip route show 0/0 | cut -f5 -d' '); do
          ${lib.getExe pkgs.ethtool} -K "$dev" rx-udp-gro-forwarding on rx-gro-list off
        done
      '';
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
