{ config, lib, ... }:

let
  cfg = config.services.tailscale;
  tailscaleInterface = cfg.interfaceName;
in {
  networking.wireguard.enable = true;
  networking.firewall.trustedInterfaces = [ tailscaleInterface ];

  services.tailscale = {
    enable = true;
    authKeyFile = "/dummy";
    openFirewall = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--reset"
      "--accept-routes"
      "--exit-node=de-ber-wg-004.mullvad.ts.net"
    ];
  };

  # call taiscale up without --auth-key
  systemd.services.tailscaled-autoconnect.script = ''
    status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
    if [[ $status != Connected* ]]; then
      ${cfg.package}/bin/tailscale up ${lib.escapeShellArgs cfg.extraUpFlags}
    fi
  '';
}
